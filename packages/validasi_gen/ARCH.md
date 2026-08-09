# `validasi_gen` — Architecture & Extension Guide

`validasi_gen` is the code generator that turns `@ValidateClass()`, field-level `@Validate<T>(...)`, `@RefineFn`, and the cross-field sugar annotations (`@RequiredAny`, `@MatchesField`, etc.) on a user model into a sealed `XFields<V>` hierarchy, a `validate()` / `validateAsync()` extension, and (optionally) a schema and a form-aware `validateForm_X(ctrl)`. This document describes the pipeline end-to-end, then gives step-by-step instructions for the most common extensions.

---

## 1. Pipeline at a glance

```
┌───────────────────────────────┐
│ Source: user.dart              │
│   @ValidateClass()              │
│   @RequiredAny(['email','phone'])
│   class User {                  │
│     @Validate<String>([…])      │
│     final String email;         │
│     @RefineFn(dependsOn: […])   │
│     static void check(…) { … }  │
│   }                             │
└──────────────┬─────────────────┘
               │  build_runner reads file
               ▼
┌───────────────────────────────┐
│ _ValidasiBuilder                │  builder.dart
│  - reads build.yaml cfg         │
│  - parses library               │
│  - calls Generator               │
│  - DartFormatter                 │  ◄── final pass: pretty-prints
└──────────────┬─────────────────┘
               │
               ▼
┌───────────────────────────────────────────────┐
│ ValidasiGenerator                               │  generator.dart
│  1. collect @ValidateClass classes               │
│  2. detect cycles (nested @ValidateClass fields) │
│  3. for each class:                              │
│     a. extractValidateFields    → FieldRules     │  parsers/rules.dart
│     b. extractRefineMethods     → RefineMethodInfo[]
│     c. extractCrossFieldRules   → CrossFieldRuleInfo[]  parsers/cross_field_rules.dart
│     d. desugarCrossFieldRules   → merge into refines    generators/cross_field_sugar.dart
│     e. emit fields class          (if generateFields)    generators/fields_class.dart
│     f. emit schema class          (if generateFields && generateSchema)  generators/cross_fields.dart
│     g. emit validate()/validateAsync() extension          generators/extension.dart
│     h. emit validateForm_X()      (if generateFields && generateValidateForm)  generators/form_validator.dart
│     i. emit cross-field helper class (if any sugar used)  generators/cross_field_sugar.dart
│  4. scan output for used `_Errors.*` helpers, emit `_Errors` class
│  5. emit shared `_Result` helper                          generators/error_helpers.dart
└──────────────┬─────────────────────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ Output: user.validasi.dart             │
│   sealed class UserFields<V> …  │
│   class _UserSchema … { … }     │
│   extension $UserValidasi on User {
│     ValidasiResult<User> validate() { … }
│   }                             │
│   abstract final class _Errors { … }
│   abstract final class _Result { … }
└───────────────────────────────┘
```

`build.yaml` (at the package root) registers the builder so `auto_apply: dependents` fires for every package that depends on `validasi_gen`.

Every rule/refine that's async — an `AsyncInline`/`AsyncCustomRule` field rule, or an async `@RefineFn` method, or a desugared cross-field rule wrapping one — poisons the whole class: `validate()`'s generated body becomes nothing but a `throw StateError(...)`, and callers must use `validateAsync()` instead. See §4 of the extension.dart section below.

---

## 2. The layers

| Layer | Lives in | Knows about |
|---|---|---|
| **Builder** | `lib/src/builder.dart` | `build_runner`, `source_gen`, `dart_style` |
| **Generator (orchestrator)** | `lib/src/generator.dart` | Cycle detection, per-class orchestration across every sub-generator |
| **Parsers** | `lib/src/parsers/rules.dart`, `lib/src/parsers/cross_field_rules.dart` | Reading `@Validate`, `@ValidateClass`, `@RefineFn`, and the six cross-field sugar annotations from the AST |
| **Emitters** | `lib/src/generators/*.dart` | `code_builder` — how to render each artifact (fields class, schema, extension, form validator, cross-field helpers, error helpers) |
| **Rule handlers** | `lib/src/handlers/*.dart` + the `lib/src/handlers.dart` registry | Per-rule emit: condition, default message, error expression, supported-type validation |

The rule of thumb: **one file, one job**. If you find yourself reaching into another layer to fix a bug, the layers are probably mis-split.

---

## 3. File-by-file

### 3.1 `lib/src/builder.dart`

The `build_runner` entry point. It:

1. Reads four build-config booleans via `boolOption(options.config, '<key>')`, each defaulting when absent: `generateFields` (default `true`), `generateSchema` (default `true`), `generateValidateForm` (default `false`), `generateIndexedFields` (default `false`).
2. Instantiates `ValidasiGenerator` with those four as its `*Default` constructor parameters.
3. Reads the source library and runs the generator.
4. If the generator returns non-empty output, wraps it in the `part of '…';` header and runs it through `DartFormatter` (page width 80, latest language version) — falling back to the unformatted source if formatting throws.
5. Writes to `*.validasi.dart` next to the source.

### 3.2 `lib/src/generator.dart`

`class ValidasiGenerator extends Generator` from `source_gen`, holding the four `*Default` flags.

Orchestration per `@ValidateClass` class (abridged, see the real file for the exact buffer writes):

```dart
for (final cls in validateClasses.values) {
  final fields = extractValidateFields(cls, library);
  final refines = extractRefineMethods(cls);
  final crossFieldInfos = extractCrossFieldRules(cls);
  if (fields.isEmpty && refines.isEmpty && crossFieldInfos.isEmpty) continue;

  final generateFields = readGenerateFieldsOverride(cls) ?? generateFieldsDefault;
  final generateSchema = readGenerateSchemaOverride(cls) ?? generateSchemaDefault;
  final generateIndexedFields =
      readGenerateIndexedFieldsOverride(cls) ?? generateIndexedFieldsDefault;
  final desugaredCrossField = desugarCrossFieldRules(cls.name!, cls, crossFieldInfos);
  final allRefines = [...refines, ...desugaredCrossField.map((d) => d.refine)];
  final shouldEmitValidateForm = generateFields && generateValidateFormDefault;

  if (generateFields) {
    buffer.write(generateFieldsClass(cls.name!, fields,
        generateIndexedFields: generateIndexedFields, generateSchema: generateSchema));
    if (generateSchema) {
      buffer.write(generateSchemaClass(cls.name!, fields,
          implementFormValidator: shouldEmitValidateForm));
    }
  }

  buffer.write(generateValidateExtension(cls.name!, fields,
      includeValidateField: generateFields, refines: allRefines,
      allFieldNames: cls.fields.where((f) => !f.isStatic).map((f) => f.name!).toList()));

  if (shouldEmitValidateForm) {
    buffer.write(generateValidateForm(cls.name!, fields, refines: allRefines));
  }
  if (desugaredCrossField.isNotEmpty) {
    buffer.write(generateCrossFieldHelperClass(cls.name!, desugaredCrossField));
  }
}
```

Note the real gating: `generateSchema` only ever emits **inside** the `if (generateFields)` branch, and `generateValidateForm` is gated by both `generateFields` *and* the build-level default (there is no per-class override key for it — only `readGenerateFieldsOverride`, `readGenerateSchemaOverride`, and `readGenerateIndexedFieldsOverride` exist).

Before the loop, `_detectCycles(...)` walks nested `@ValidateClass` references (e.g. `User { Car car; }`) and throws `InvalidGenerationSourceError` with a readable `A -> B -> A` path.

After the per-class loop, the generator scans the accumulated source for `_Errors.<name>(` call patterns, collects each handler's `helperMethods` map plus `RequiredHelper.helperMethods`, and emits only the `_Errors` static methods actually referenced — then always appends the shared `_Result` helper (`generators/error_helpers.dart:generateResultHelper()`).

### 3.3 `lib/src/parsers/rules.dart`

Reads annotations off a class and produces the data the generators consume. Declares:

- `FieldRules` — a field's `FieldElement`, its `List<RuleInfo>`, its `FieldContext context` (string/iterable/generic — derived from the `@Validate<T>` type argument), whether it's nested (`nestedClassName`/`isNestedIterable`), plus derived getters: `hasAsyncRule`, `accessorName` (the `name`/`extract`/`validate`/`validateAsync` collision-dodging suffix), `isTypeRequired`, `isRequired`, `requiredMessage`.
- `RefineParamInfo` (`name`, `type`) and `RefineMethodInfo` (`methodName`, `dependsOn`, `parameters`, `isAsync`, `ruleName` — default `'Refine'`).
- `extractValidateFields(ClassElement, LibraryReader) → List<FieldRules>` — for every non-static field, tries `_extractRules` (reads the `@Validate<T>` annotation, computes `FieldContext` via `fieldContextFromType` on the type argument, parses each rule via `_parseRule`, and calls each matched handler's `validateType(context, field)`), then falls back to `detectNestedField`.
- `extractRefineMethods(ClassElement) → List<RefineMethodInfo>` — for every method annotated `@RefineFn`, **throws `InvalidGenerationSourceError` if the method isn't `static`** (the generator needs to call it from both `validate()`/`validateAsync()` and, when enabled, `validateForm_X(ctrl)`, so it can't rely on an implicit instance receiver).
- `_parseRule` — `Required`/`Nullable` are special-cased directly here (not routed through the `ruleGens` registry); everything else is looked up in `ruleGens[name]`, with a fallback that walks `allSupertypes` for user-defined `CustomRule`/`AsyncCustomRule` subclasses; anything still unmatched becomes `RuleInfo(name, const {}, message, isUnknown: true)` and is **silently dropped downstream** (see §8).

**Correction from an earlier version of this doc**: `RuleInfo` and `RuleGen` are *not* defined in this file — they live in `handlers/handler.dart` (§3.5). This file only consumes them. There is also no `typeArg` field on `RuleInfo` — the type-dispatch context lives on `FieldRules.context` (a `FieldContext`) and is passed as a parameter to `RuleGen.check`/`emitError`/`defaultMessage`/`validateType`, not stored on the rule itself.

### 3.4 `lib/src/parsers/cross_field_rules.dart`

```dart
class CrossFieldRuleInfo {
  final String kind;          // 'RequiredAny' | 'RequiredOneOf' | 'RequiredAll' |
                               // 'DependsOn' | 'MutuallyExclusive' | 'MatchesField'
  final List<String> fields;
  final String? message;
}

List<CrossFieldRuleInfo> extractCrossFieldRules(ClassElement element)
```

Scans class-level metadata for the six cross-field sugar annotation constructors and reads their arguments into a uniform `fields` list per kind (`DependsOn` → `[field, dependsOn]`, `MutuallyExclusive` → `[fieldA, fieldB]`, `MatchesField` → `[field, matchesField]`, the `RequiredAny/OneOf/All` trio → their `fields` list argument directly). Feeds `generators/cross_field_sugar.dart:desugarCrossFieldRules`.

### 3.5 `lib/src/handlers/handler.dart`

The canonical home of the per-rule contract and its supporting types — **not** `parsers/rules.dart`:

```dart
enum FieldContext { string, iterable, generic }

FieldContext fieldContextFromType(DartType? type) { ... } // String → string; List/Iterable/Set → iterable; else generic

class RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  final bool isAsync;
  final String? functionName;
  RuleInfo(this.name, this.params, this.message,
      {this.isUnknown = false, this.isAsync = false, this.functionName});
}

abstract class RuleGen {
  bool get isControl => false;
  bool get isAsync => false;
  String get name;
  RuleInfo parse(ConstantReader rule);
  String check(RuleInfo info, String fieldName, {bool nullable = true});
  String defaultMessage(RuleInfo info, [FieldContext context = FieldContext.string]);
  String? asyncCall(RuleInfo info, String fieldName) => null;
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]);
  Map<String, String> get helperMethods;
  Set<FieldContext> get supportedContexts => {FieldContext.generic};
  void validateType(FieldContext context, FieldElement field) {}
}
```

- `check(...)` returns the boolean guard expression used in `if (check) { $errors.add(emitError(...)); }`. The `nullable` parameter lets a handler tighten its own null-guard (e.g. when `runOnNull` is set on the rule instance).
- `asyncCall(...)` returns `null` for sync rules; async handlers (`AsyncInline`, `AsyncCustomRule`) override it to return the awaited expression, and their `check(...)` simply returns the literal `'false'` so the sync path never runs them.
- `emitError(...)` returns the full `_Errors.<helper>(...)` call expression.
- `helperMethods` maps a helper name to the Dart source of a static method that gets spliced into the generated `_Errors` class — only for helpers actually referenced in the output (see §3.2's post-loop scan).
- `supportedContexts`/`validateType` let a handler reject being applied to an unsupported field kind (e.g. a string-only rule on a `List<String>` field) at build time.

### 3.6 `lib/src/handlers.dart`

Re-exports `RuleGen`, `RuleInfo`, `FieldContext`, `fieldContextFromType` from `handlers/handler.dart`, and builds the registry:

```dart
final Map<String, RuleGen> ruleGens = {
  for (final g in [
    MinLengthGen(), MaxLengthGen(), OneOfGen(), AsyncInlineGen(),
    CustomRuleGen(), AsyncCustomRuleGen(), InlineGen(), AlphaGen(),
    AlphanumericGen(), NumericGen(), LowercaseGen(), UppercaseGen(),
    StartsWithGen(), EndsWithGen(), RegexGen(), UlidGen(), UuidGen(),
    UrlGen(), Ipv4Gen(), Ipv6Gen(), IpGen(), EmailGen(), ContainsGen(),
    BetweenGen(), LessThanGen(), LessThanEqualGen(), MoreThanGen(),
    MoreThanEqualGen(), NegativeGen(), NonNegativeGen(), NonPositiveGen(),
    PositiveGen(), FiniteGen(), ExactLengthGen(), IsEmptyGen(),
    IsNotEmptyGen(), UniqueGen(), ContainsAllGen(), NotContainsGen(),
    EqualsGen(), NotEqualsGen(), HavingGen(),
    // ...add new handlers here (see §4)
  ])
    g.name: g,
};
```

41 handlers today. `Required`/`Nullable` are deliberately **not** in this map — they're control annotations special-cased directly in `parsers/rules.dart:_parseRule` and rendered via `handlers/required.dart`'s `RequiredHelper`, imported separately by `field_snippets.dart` and `fields_class.dart`.

### 3.7 `lib/src/utils.dart`

- `hasValidateClassAnnotation` — name-based check.
- `detectNestedField` — recognizes direct `@ValidateClass` and `List`/`Iterable`/`Set<@ValidateClass>`, rejects `Map`.
- `boolOption` — read a boolean builder-config key, throwing a clear error for a non-bool value.
- `escapeDartString` — shared string-literal escaping.
- `qualifiedFunctionName(ExecutableElement?)` — returns the Dart expression that calls a torn-off function from generated code: a static method needs its enclosing class name prefixed (`User._checkThing`), a top-level function is called bare. Used by `Inline`/`AsyncInline`.
- `literalForConstant(ConstantReader)` — renders a constant (bool/int/double/String) as a Dart literal; used by `CustomRule`/`AsyncCustomRule` to thread named config values through to the generated `ClassName.check(value, config: <literal>)` call.

### 3.8 `lib/src/generators/field_snippets.dart`

`FieldRuleSnippets.emitInline(...)` is the sole `StringBuffer`-based emitter — it produces the *body* of a field's `validate()`/`validateAsync()`: the required-check, then one `if (check) { $errors.add(...); }` (or, for a rule with an `asyncCall`, a `try { ... } catch (e) { ... }` block) per rule. Consumed by both `fields_class.dart` (leaf field classes) and `extension.dart` (`_generateFieldBody`).

- `Nullable` rules are stripped up front — they emit no code, they only suppress the automatic `Required` check.
- Unknown rules (`isUnknown: true`) and async rules (when `async: false`) are silently skipped.
- The required-check uses `handlers/required.dart`'s `RequiredHelper`, passing `ctx.context` (the field's `FieldContext`) through to `emitError`.

### 3.9 `lib/src/generators/fields_class.dart`

```dart
String generateFieldsClass(
  String className,
  List<FieldRules> fields, {
  bool generateIndexedFields = false,
  bool generateSchema = false,
})
```

Builds (via `code_builder`, `Allocator.none`, no imports since this is a `part of` file):

- The sealed base class `${className}Fields<V> extends ValidasiKey<$className> implements ValidasiField<$className, V>` with a private const constructor.
- If `generateSchema`, a static const `schema` field referring to `_${className}Schema()` (from `cross_fields.dart`).
- One static const accessor per field (name from `FieldRules.accessorName`) plus a generated leaf class `${className}${Field}Field` implementing `name`/`extract(owner)`/`validate`/`validateAsync` — either flat (`_addLeafValidate`, using `field_snippets.dart`) or delegating to a nested object/iterable's own `validate()`/`validateAsync()` (`_addNestedValidate`).
- If `generateIndexedFields`, three additional static methods on the sealed class for list-backed/repeatable form sections: `indexedFields<FormType>(parentPath, index)`, `reconstructItem<FormType>(ctrl, field, index)`, `reconstructAll<FormType>(ctrl, field)` — all referencing `IndexedField` from `validasi_ui`.

### 3.10 `lib/src/generators/extension.dart`

```dart
String generateValidateExtension(
  String className,
  List<FieldRules> fields, {
  bool includeValidateField = true,
  List<RefineMethodInfo> refines = const [],
  List<String>? allFieldNames,
})
```

Emits `extension $${className}Validasi on $className`. The critical line:

```dart
final classHasAsync = fields.any((f) => f.hasAsyncRule) || refines.any((r) => r.isAsync);
```

- **`validate()`**: if `classHasAsync`, the entire method body is `throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');` — no partial sync validation is attempted. Otherwise it accumulates `$errors` across every field (`_generateFieldBody(isAsync: false)`) and every refine (`emitRefineInvocation(isFormContext: false, isAsync: false)`), then returns a `ValidasiResult`.
- **`validateAsync()`**: always emitted, always async, always runs the full body — fields with `isAsync: true` and refines with `isAsync: r.isAsync` per refine (so sync and async refines can coexist inside the async method).
- If `includeValidateField`, also emits generic `validateField<V>(field)`/`validateFieldAsync<V>(field)` delegating to `field.validate(field.extract(this))`.
- `objectAccessors` — the field-name → accessor-expression map passed to refines — is built from **every** field on the class (`allFieldNames`, not just validated ones), since a cross-field rule may reference a plain sibling field that has no `@Validate<T>` rules of its own.
- Nested object/iterable fields prefix child error paths with the field name (`_generateNestedObjectBody`/`_generateNestedIterableBody`).

### 3.11 `lib/src/generators/refine.dart`

```dart
String emitRefineInvocation({
  required RefineMethodInfo info,
  required Map<String, String> fieldAccessors,
  required bool isFormContext,
  required bool isAsync,
})
```

Shared by both `extension.dart` and `form_validator.dart`. Emits a uniquely-named `$fail_<method>` closure (derived from the refine's qualified method name, so multiple refines on one class don't collide) that appends a `ValidationError(rule: info.ruleName, ...)` to `$errors`, then calls the refine method with that closure plus named arguments resolved from `fieldAccessors` for each name in `info.dependsOn` (or every accessor, if `dependsOn` is empty). Prefixes the call with `await` when `isAsync`.

### 3.12 `lib/src/generators/cross_fields.dart`

```dart
String generateSchemaClass(
  String className,
  List<FieldRules> allFields, {
  bool implementFormValidator = false,
})
```

Emits a private `_${className}Schema extends ValidasiSchema<$className>` — optionally `implements ValidasiFormValidatorSchema<$className>` when `implementFormValidator` is true — with a const constructor, an `allocate(ValidasiFieldReader<$className> reader)` override that reconstructs the object from field-reader values (non-nested fields only), and, when form-validator wiring is on, a `formValidator` getter returning the free function generated by `form_validator.dart`. There is no `assemble_X` function anymore — this replaced it.

### 3.13 `lib/src/generators/cross_field_sugar.dart`

```dart
class DesugaredCrossFieldRule {
  final RefineMethodInfo refine;
  final String helperMethodSource;
}

List<DesugaredCrossFieldRule> desugarCrossFieldRules(
    String className, ClassElement cls, List<CrossFieldRuleInfo> infos)

String generateCrossFieldHelperClass(
    String className, List<DesugaredCrossFieldRule> desugared)
```

For each parsed `CrossFieldRuleInfo`, validates the referenced field names exist on the class (throwing `InvalidGenerationSourceError` for an unknown field, non-distinct fields where distinctness is required, or too few fields for the `RequiredAny`/`RequiredOneOf`/`RequiredAll` kinds), generates a uniquely-named static method (e.g. `requiredAny_0`) on a synthetic `_${className}CrossFieldRules` helper class, and wraps it in a `RefineMethodInfo` (`ruleName` = the sugar kind) pointing at that qualified method. These desugared refines are merged into the same `List<RefineMethodInfo>` consumed by `extension.dart` and `form_validator.dart` — cross-field sugar and hand-written `@RefineFn` share the exact same downstream code path via `emitRefineInvocation`.

### 3.14 `lib/src/generators/form_validator.dart`

```dart
String generateValidateForm(
  String className,
  List<FieldRules> fields, {
  List<RefineMethodInfo> refines = const [],
})
```

Emits a free top-level function `validateForm_$className(ValidasiFormController<$className> ctrl)` (async if any field/refine is async) that mirrors `validate()`/`validateAsync()` but reads each field's current value via `ctrl.getValue($fieldsClassName.accessor)` instead of `this.field`, recurses into nested objects/iterables via their own `validateForm`/`validateFormAsync`, and runs refines via `emitRefineInvocation(isFormContext: true, ...)`. This is the function `cross_fields.dart`'s `generateSchemaClass(implementFormValidator: true)` wires up as the schema's `formValidator` getter.

### 3.15 `lib/src/generators/error_helpers.dart`

```dart
String generateResultHelper()
```

Emits (as a raw string literal, not `code_builder`) a shared `abstract final class _Result` with two static factories — `from<T>(errors, value)` and `invalidSingle<T>(error)` — used throughout the generated leaf `validate`/`validateAsync` bodies. Always appended once per file, after the per-handler `_Errors` class (see §3.2).

---

## 4. Adding a new rule

Concrete example: adding a `Palindrome` check (a string-format rule; pick any name not already in the registry — check `handlers.dart`'s list first).

### 4.1 Define the annotation class

`packages/validasi_annotation/lib/src/rules/palindrome.dart`:

```dart
import 'package:validasi_annotation/src/base.dart';

class Palindrome<T> extends Rule<T> {
  const Palindrome({super.message});
}
```

Re-export it from `packages/validasi_annotation/lib/validasi_annotation.dart`:

```dart
export 'src/rules/palindrome.dart';
```

Bump the version, update the annotation `CHANGELOG.md`.

### 4.2 Write a `RuleGen`

`packages/validasi_gen/lib/src/handlers/palindrome.dart`:

```dart
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class PalindromeGen extends RuleGen {
  @override
  String get name => 'Palindrome';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Palindrome', const {}, rule.peek('message')?.stringValue);
  }

  @override
  void validateType(FieldContext context, FieldElement field) {
    if (context != FieldContext.string) {
      throw InvalidGenerationSourceError(
        'Palindrome only supports String fields.',
        element: field,
      );
    }
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    return "$guard$fieldName != $fieldName.split('').reversed.join()";
  }

  @override
  String defaultMessage(RuleInfo info, [FieldContext context = FieldContext.string]) =>
      'Must be a palindrome';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final message = info.message != null
        ? escapeDartString(info.message!)
        : escapeDartString(defaultMessage(info, context));
    return "_Errors.inline($pathExpr, 'Palindrome', $message)";
  }

  @override
  Map<String, String> get helperMethods => {
        'inline':
            "static ValidationError inline(List<String> path, String rule, String message) =>\n"
                '      ValidationError(rule: rule, message: message, path: path);',
      };
}
```

### 4.3 Register it

`packages/validasi_gen/lib/src/handlers.dart` — add the import and add `PalindromeGen()` to the list literal alongside the other ~41 entries.

### 4.4 Tests

- `packages/validasi_gen/test/handlers/palindrome_test.dart` — unit test `RuleInfo` parsing and the `check`/`emitError` strings.
- `packages/validasi_gen/test/generator/src/palindrome_source.dart` — fixture with a `@Validate<String>([Palindrome()])` field.
- `packages/validasi_gen/test/generator/palindrome_test.dart` — assert the generated output contains the expected check and default message.

### 4.5 Verify

```bash
cd packages/validasi_gen
dart pub get
dart test
dart run build_runner build --delete-conflicting-outputs
```

---

## 5. Adding a parameter to an existing rule

`MinLength` currently takes `(this.length, {super.message})`. Suppose we want to add `inclusive: bool = true` to control whether the bound is `<` or `<=`.

### 5.1 Annotation

`packages/validasi_annotation/lib/src/rules/min_length.dart`:

```dart
class MinLength<T> extends Rule<T> {
  final int length;
  final bool inclusive;
  const MinLength(this.length, {super.message, this.inclusive = true});
}
```

### 5.2 Handler

`packages/validasi_gen/lib/src/handlers/min_length.dart`:

```dart
@override
RuleInfo parse(ConstantReader rule) {
  final length = rule.read('length').intValue;
  final inclusive = rule.peek('inclusive')?.boolValue ?? true;
  return RuleInfo('MinLength', {'length': length, 'inclusive': inclusive},
      rule.peek('message')?.stringValue);
}

@override
String check(RuleInfo info, String fieldName, {bool nullable = true}) {
  final length = info.params['length'] as int;
  final inclusive = info.params['inclusive'] as bool;
  final op = inclusive ? '<' : '<=';
  final guard = nullable ? '$fieldName != null && ' : '';
  return '$guard$fieldName.length $op $length';
}
```

### 5.3 Test

Update `min_length_test.dart` to cover the new param. No other layers need to change.

---

## 6. Adding a new annotation (class-level)

This is the general pattern behind the six shipped cross-field sugar annotations
(`@RequiredAny`, `@RequiredOneOf`, `@RequiredAll`, `@DependsOn`, `@MutuallyExclusive`,
`@MatchesField` — see §3.4 and §3.13 for the real, working implementation). Walkthrough for any
new class-level annotation that reduces to a synthetic cross-field check:

### 6.1 Annotation

```dart
class MyRule {
  final List<String> fields;
  final String? message;
  const MyRule(this.fields, {this.message});
}
```

Class-level annotations are stackable by default in Dart — a user can write `@MyRule([...]) @MyRule([...])` and the generator sees both metadata entries.

### 6.2 Parser

Add a case to `parsers/cross_field_rules.dart` (or a new parser file, if the annotation doesn't fit the existing `CrossFieldRuleInfo.kind` shape) that recognizes the annotation by name and reads its constant arguments into whatever info type the corresponding generator step expects.

### 6.3 Desugaring / orchestration

Either extend `generators/cross_field_sugar.dart`'s `desugarCrossFieldRules` with a new `case` in its kind switch (if the check fits the existing `RefineMethodInfo`-shaped output), or add a new extraction + generation step in `generator.dart`'s per-class loop, following the same pattern as `extractCrossFieldRules` → `desugarCrossFieldRules` → merge into `allRefines`.

### 6.4 Tests

- `parsers/cross_field_rules_test.dart` — assert the annotation parses into the expected info.
- `test/generator/cross_field_sugar_test.dart` — assert the desugared refine + helper method are emitted and wired into `validate()`/`validateAsync()`.

---

## 7. Build config options

Four `bool` build options, each read via `boolOption(options.config, '<key>')` in `builder.dart` and forwarded to `ValidasiGenerator` as a default:

| Option | Default | Controls |
|---|---|---|
| `generateFields` | `true` | Emit `XFields` sealed hierarchy + `validateField()` on the extension. **Gates the two below.** |
| `generateSchema` | `true` | Emit `_${X}Schema`, exposed as `XFields.schema`. Only takes effect while `generateFields` is also `true`. |
| `generateValidateForm` | `false` | Emit `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)`. Only takes effect while `generateFields` is also `true`. |
| `generateIndexedFields` | `false` | Emit `indexedFields`/`reconstructItem`/`reconstructAll` static methods for list-backed forms. |

Per-class `@ValidateClass(generateFields: …, generateSchema: …, generateIndexedFields: …)` overrides win over the build-level default for those three keys — resolved via `readGenerateFieldsOverride`/`readGenerateSchemaOverride`/`readGenerateIndexedFieldsOverride` in `parsers/rules.dart`. **`generateValidateForm` has no per-class override** — it's build-level only.

### Why `generateValidateForm`/`generateIndexedFields` are off by default

The code they emit references `ValidasiFormController`/`IndexedField`, which live in the Flutter-dependent `validasi_ui` package. Pure-Dart consumers of `validasi_gen` would fail to compile if either were on by default. Flutter consumers opt in per-project via `build.yaml` and must also depend on and import `validasi_ui` in the source file.

### Opting in (Flutter consumer example)

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateValidateForm: true
```

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';
import 'package:validasi_ui/validasi_ui.dart';

part 'user.validasi.dart';

@ValidateClass()
class User { ... }
```

`User.validateForm_User(ctrl)` is now in scope, and if `generateSchema` is also on, `XFields.schema` auto-wires it as the `formValidator` — no separate `formValidator:` argument needed at the `ValidasiForm` call site.

### Adding a new global toggle

Mirror the existing pattern: add a key + default to `builder.dart`, forward it to `ValidasiGenerator`, use it in `generator.dart`'s orchestration, and (if it should be per-class overridable) add a `read<Name>Override` reader in `parsers/rules.dart` and a matching field on `@ValidateClass` in `validasi_annotation`. If the option touches code that references a type from an optional dependency, default to `false` and document the opt-in (see above).

---

## 8. Common gotchas

- **Type identity in metadata** — annotation detection is name-based (`element.enclosingElement.name == 'ValidateClass'`, etc.). A user-defined class sharing one of these names will be picked up.
- **Unknown rules are silently dropped** — in `_parseRule`, any rule whose name isn't in `ruleGens` (and isn't `Required`/`Nullable`/a `CustomRule`/`AsyncCustomRule` subclass) is emitted as `isUnknown: true` and never reaches the snippet emitter. Write `@Validate<String>([MyRule()])`, forget to register `MyRule`, and you get no build error and no validation — silently. Worth a defensive check (or at minimum, grepping the registry) whenever a generated validator seems to be accepting input it shouldn't.
- **`generateSchema`/`generateValidateForm` need `generateFields`** — turning `generateFields` off silently drops the schema and form validator too, even if those flags are individually `true`. This isn't enforced with an error; it's just how the `if` nesting in `generator.dart` works.
- **`part of` means no imports** — `Allocator.none` is mandatory across every `code_builder` emitter. A new `refer('Type')` whose type lives in a package the user hasn't imported in the parent file will fail to compile.
- **`Method.body` is always a block body** — `code_builder` does not support `=>` expression bodies for `Method`. Simple getters end up as `{ return x; }` instead of `=> x;`; `DartFormatter` won't rewrite blocks to arrows.
- **`await` is not emitted by `code_builder`** — it must be written into the `Code` body directly, alongside setting `m.modifier = MethodModifier.async`. Both are easy to forget when adding a new async code path.
- **Async is viral, not local** — a single async rule/refine on a class makes the *entire* generated `validate()` throw, not just the field/refine that's actually async (§3.10). There's no partial-sync mode.

---

## 9. Where to look for what

| I want to change… | File |
|---|---|
| What runs at build time, builder config | `lib/src/builder.dart` |
| What `@ValidateClass` triggers, cycle detection, per-class orchestration | `lib/src/generator.dart` |
| How a field's rules / refine methods are read from the AST | `lib/src/parsers/rules.dart` |
| How the six cross-field sugar annotations are read from the AST | `lib/src/parsers/cross_field_rules.dart` |
| The `RuleGen` interface, `RuleInfo`, `FieldContext` | `lib/src/handlers/handler.dart` |
| The registry mapping rule name → handler | `lib/src/handlers.dart` |
| The sealed `XFields` class layout, `generateIndexedFields` methods | `lib/src/generators/fields_class.dart` |
| The `validate()` / `validateAsync()` extension, async-poisoning check | `lib/src/generators/extension.dart` |
| The shared `$fail_*` refine-invocation closure | `lib/src/generators/refine.dart` |
| The per-rule `if (check) { … }` / async `try/catch` body | `lib/src/generators/field_snippets.dart` |
| The schema class (`XFields.schema`) | `lib/src/generators/cross_fields.dart` |
| Desugaring `@RequiredAny` etc. into synthetic refines | `lib/src/generators/cross_field_sugar.dart` |
| The `validateForm_X(ctrl)` free function | `lib/src/generators/form_validator.dart` |
| The shared `_Result` helper class | `lib/src/generators/error_helpers.dart` |
| A specific rule's emit logic | `lib/src/handlers/<rule>.dart` |
| Annotation definitions | `packages/validasi_annotation/lib/src/` |
| Shared string escaping, function/constant literal rendering | `lib/src/utils.dart` |
