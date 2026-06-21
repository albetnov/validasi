# `validasi_gen` — Architecture & Extension Guide

`validasi_gen` is the code generator that turns `@ValidateClass()` and `@Validate(...)` annotations on a user model into a sealed `XFields<V>` hierarchy plus a `validate()` / `validateAsync()` extension. This document describes the pipeline end-to-end, then gives step-by-step instructions for the most common extensions.

---

## 1. Pipeline at a glance

```
┌─────────────────────────┐
│ Source: user.dart       │
│   @ValidateClass()      │
│   class User {          │
│     @Validate.string(…) │
│     final String email; │
│   }                     │
└────────────┬────────────┘
             │  build_runner reads file
             ▼
┌─────────────────────────┐
│ _ValidasiBuilder        │  builder.dart
│  - reads build.yaml cfg │
│  - parses library       │
│  - calls Generator      │
│  - DartFormatter        │  ◄── final pass: pretty-prints
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ ValidasiGenerator       │  generator.dart
│  1. collect @ValidateClass
│  2. detect cycles       │
│  3. for each class:     │
│     a. extractValidateFields → FieldRules
│     b. emit fields class  (generators/fields_class.dart)
│     c. emit assemble fn   (generators/cross_fields.dart)
│     d. emit extension     (generators/extension.dart)
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ Output: user.g.dart     │
│   sealed class UserFields<V> …
│   extension $UserValidasi on User {
///     ValidasiResult<User> validate() { … }
///   }
└─────────────────────────┘
```

`build.yaml` (at the package root) registers the builder so `auto_apply: dependents` fires for every package that depends on `validasi_gen`.

---

## 2. The four layers

| Layer | Lives in | Knows about |
|---|---|---|
| **Builder** | `lib/src/builder.dart` | `build_runner`, `source_gen`, `dart_style` |
| **Generator** | `lib/src/generator.dart` | Parsing, cycle detection, orchestration |
| **Parsers** | `lib/src/parsers/rules.dart` | Reading `@Validate`, `@ValidateClass`, `@Refine` from AST |
| **Emitters** | `lib/src/generators/*.dart` | `code_builder` — how to render each artifact |
| **Rule handlers** | `lib/src/handlers/*.dart` | Per-rule emit: condition, message, details, type-check |

The rule of thumb: **one file, one job**. If you find yourself reaching into another layer to fix a bug, the layers are probably mis-split.

---

## 3. File-by-file

### 3.1 `lib/src/builder.dart`

The `build_runner` entry point. It:

1. Instantiates `ValidasiGenerator` with builder-config defaults (`generateFields`, `generateAssemble`).
2. Reads the source library.
3. If the generator returns non-empty output, wraps it in the `part of '…';` header and runs it through `DartFormatter` (page width 80, latest language version).
4. Writes to `*.g.dart` next to the source.

The formatter pass is what makes `code_builder`'s terse output readable — without it, the generated file is one long line per method.

### 3.2 `lib/src/generator.dart`

`class ValidasiGenerator extends Generator` from `source_gen`.

Orchestration per `@ValidateClass` class:

```dart
for (final cls in validateClasses.values) {
  final fields = extractValidateFields(cls, library);
  if (fields.isEmpty) continue;
  // ...per-class generateFields / generateAssemble overrides...
  if (generateFields) {
    buffer.write(generateFieldsClass(cls.name!, fields));
    if (generateAssemble) buffer.write(generateFromForm(cls.name!, fields));
  }
  buffer.write(generateValidateExtension(cls.name!, fields, includeValidateField: generateFields));
}
```

Before the loop, it runs `_detectCycles(...)` against nested `@ValidateClass` references (e.g. `User { Car car; }`) and throws `InvalidGenerationSourceError` with a readable `A -> B -> A` path.

### 3.3 `lib/src/parsers/rules.dart`

Reads annotations on a Dart class and produces a `List<FieldRules>`. Three data types:

- `FieldRules` — a field's name, its rules, whether it's nested, and its declared type.
- `RuleInfo` — one rule entry inside a `@Validate(...)` list (name, params, message, isAsync, typeArg).
- `RefineInfo` — a class-level `@Refine` (used by Phase 4, not yet wired in).

The walk is: for every non-static field, try `_extractRules` first, then `detectNestedField`, then skip. `_extractRules` calls `_parseRule` which, for any rule whose name is not in the `ruleGens` registry, marks it `isUnknown: true` and silently drops it (see §6 for the caveat).

### 3.4 `lib/src/utils.dart`

- `hasValidateClassAnnotation` — name-based check.
- `detectNestedField` — recognises direct `@ValidateClass` and `List<@ValidateClass>`, rejects `Map`.
- `boolOption` — read a boolean builder-config key with a proper error message.
- `escapeDartString` — shared by the field-snippet emitter and `OneOfGen`. No more duplicated copies.

### 3.5 `lib/src/generators/field_snippets.dart`

`FieldRuleSnippets.emitInline(...)` is the only piece of the pipeline that still writes to a `StringBuffer`. It produces the *body* of `validate()` and `validateAsync()`: the per-rule `if (check) { $errors.add(ValidationError(...)); }` blocks.

- The `indent` parameter is set to `''` by every code_builder caller — the `DartFormatter` in the builder handles indentation.
- `Required` is special-cased to emit `if (value == null) { ... }` (this was the bug fixed in Phase 3).
- `Nullable` rules are stripped up front — they don't emit code.
- `AsyncInline` is dispatched to a dedicated `try { if (!await fn(value)) { … } } catch (e) { … }` block, bypassing the generic `if (check)` path.

### 3.6 `lib/src/generators/fields_class.dart`

`generateFieldsClass` returns the sealed class plus every leaf class. Built with `code_builder` `Class` specs:

```dart
final sealedClass = Class((c) {
  c.sealed = true;
  c.name = 'UserFields';
  c.types.add(refer('V'));
  c.extend = refer('ValidasiKey<User>');
  c.implements.add(refer('ValidasiField<User, V>'));
  c.constructors.add(Constructor((con) { con.name = '_'; con.constant = true; }));
  // ...static const fields...
});
```

Leaf classes use `Method((m) { ... })` for `name`/`extract`/`validate`/`validateAsync`. The async method needs `m.modifier = MethodModifier.async`. Body content comes from `_addLeafValidate` (flat) or `_addNestedValidate` (nested). The nested path uses a `_buildNestedMethod` helper that takes `isAsync: bool` — that's how sync/async duplication was eliminated.

`Allocator.none` is used everywhere so the emitter never injects an `import` directive (we're inside a `part of` file).

### 3.7 `lib/src/generators/extension.dart`

`generateValidateExtension` returns the `extension $XValidasi on X { ... }` with `validate()`, `validateAsync()`, and (if `generateFields: true`) `validateField<V>(XFields<V> field)` / `validateFieldAsync`.

The `validate()` and `validateAsync()` methods share a sync/async helper structure via `_generateFieldBody(buf, ctx, isAsync: bool)` and the nested pair (`_generateNestedObjectBody` / `_generateNestedIterableBody`) accept the same `isAsync` flag.

### 3.8 `lib/src/generators/cross_fields.dart`

`generateFromForm` emits `X assemble_X(ValidasiFormController<X> ctrl) => X(...)` — the function the UI uses to materialise a `T` from the form's current values. Nested fields are skipped here because they can't be flat-copied.

### 3.9 `lib/src/handlers/` and `lib/src/handlers.dart`

Each rule gets one file. The registry in `handlers.dart`:

```dart
final Map<String, RuleGen> ruleGens = {
  for (final g in [MinLengthGen(), MaxLengthGen(), OneOfGen(), AsyncInlineGen()])
    g.name: g,
};
```

A `RuleGen` has four responsibilities:

- `parse(ConstantReader)` → `RuleInfo` — extract the constructor args.
- `check(info, accessor)` → `String` — the boolean expression used in `if (check) { ... }`.
- `defaultMessage(info, context)` → `String` — fallback when no custom message.
- `details(info)` → `String?` — emitted as the `details:` field on the `ValidationError`.
- `validateType(typeArg, field)` — optional, throws if the rule is applied to a type it doesn't support.

`Required` and `Nullable` are special-cased in `parsers/rules.dart:_parseRule` — they don't have a handler.

---

## 4. Adding a new rule

Concrete example: adding `Rules.email()` (a string-format check).

### 4.1 Define the annotation class

`packages/validasi_annotation/lib/src/rules/email.dart`:

```dart
import 'package:validasi_annotation/src/base.dart';

class Email<T> extends Rule<T> {
  const Email({super.message});
}
```

Re-export it from `packages/validasi_annotation/lib/validasi_annotation.dart`:

```dart
export 'src/rules/email.dart';
```

Bump the version, update the annotation `CHANGELOG.md`. The annotation package now has the type the user can write.

### 4.2 Write a `RuleGen`

`packages/validasi_gen/lib/src/handlers/email.dart`:

```dart
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class EmailGen extends RuleGen {
  @override
  String get name => 'Email';

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo(
      'Email',
      const {},
      rule.peek('message')?.stringValue,
      typeArg: typeArgOf(rule),
    );
  }

  @override
  void validateType(DartType? typeArg, FieldElement field) {
    if (typeArg == null || typeArg is DynamicType || typeArg.isDartCoreObject) {
      return;
    }
    if (typeArg.isDartCoreString) return;
    throw InvalidGenerationSourceError(
      "Email does not support type '${typeArg.getDisplayString()}'. Supported: String",
      element: field,
    );
  }

  @override
  String check(RuleInfo info, String fieldName) =>
      '$fieldName != null && !emailRegExp.hasMatch($fieldName)';

  @override
  String defaultMessage(RuleInfo info, [String context = '']) =>
      'Must be a valid email';
}
```

### 4.3 Register it

`packages/validasi_gen/lib/src/handlers.dart`:

```dart
final Map<String, RuleGen> ruleGens = {
  for (final g in [
    MinLengthGen(),
    MaxLengthGen(),
    OneOfGen(),
    AsyncInlineGen(),
    EmailGen(),   // ← new
  ])
    g.name: g,
};
```

### 4.4 (If the check references runtime constants)

The example above references `emailRegExp`. Add a top-level declaration to the *generator* so the user's `part of` file inherits it — or emit the literal inline:

```dart
@override
String check(RuleInfo info, String fieldName) =>
    r'$fieldName != null && !RegExp(r"^[a-z]+@[a-z]+\.[a-z]+$").hasMatch($fieldName)';
```

Prefer the inline literal — keeps the generated file self-contained.

### 4.5 Tests

`packages/validasi_gen/test/handlers/email_test.dart` — unit test the `RuleInfo` parsing and the `check` string.

`packages/validasi_gen/test/generator/src/email_source.dart` — fixture with a `@Validate.string([Email()])` field.

`packages/validasi_gen/test/generator/email_test.dart` — assert the generated output `contains("'Must be a valid email'")` and `contains("!RegExp(")`.

### 4.6 Verify

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
  return RuleInfo(
    'MinLength',
    {'length': length, 'inclusive': inclusive},
    rule.peek('message')?.stringValue,
    typeArg: typeArgOf(rule),
  );
}

@override
String check(RuleInfo info, String fieldName) {
  final length = info.params['length'] as int;
  final inclusive = info.params['inclusive'] as bool;
  final op = inclusive ? '<' : '<=';
  return '$fieldName != null && $fieldName.length $op $length';
}
```

### 5.3 Test

Update `min_length_test.dart` to cover the new param. No other layers need to change.

---

## 6. Adding a new annotation (class-level)

This is the `@Refine` story from Phase 4. Walkthrough for any new class-level annotation that takes a function reference plus metadata:

### 6.1 Annotation

```dart
class MyRefine {
  final Function validator;
  const MyRefine(this.validator);
}
```

Stackable: make the constructor `const` and the user writes `@MyRefine(fn1) @MyRefine(fn2)` — the generator sees both metadata entries.

### 6.2 Parser

`parsers/rules.dart`:

```dart
List<MyRefineInfo> extractMyRefines(ClassElement element) {
  final result = <MyRefineInfo>[];
  for (final meta in element.metadata.annotations) {
    final e = meta.element;
    if (e is! ConstructorElement) continue;
    if (e.enclosingElement.name != 'MyRefine') continue;
    final c = meta.computeConstantValue();
    if (c == null) continue;
    final reader = ConstantReader(c);
    final fn = reader.read('validator').objectValue.toFunctionValue();
    result.add(MyRefineInfo(functionName: fn?.name ?? '_unknown'));
  }
  return result;
}
```

### 6.3 Orchestration

`generator.dart:generate()`:

```dart
final myRefines = extractMyRefines(cls);
if (myRefines.isNotEmpty) {
  buffer.write(generateMyRefineInvocation(cls.name!, myRefines));
}
```

### 6.4 Emitter

`generators/my_refine.dart` — emit a block that runs inside the `validate()` / `validateAsync()` methods, after per-field rules:

```dart
String generateMyRefineInvocation(String className, List<MyRefineInfo> refines) {
  final buf = StringBuffer();
  for (final r in refines) {
    buf.writeln('\$errors.addAll(${r.functionName}(this));');
  }
  return buf.toString();
}
```

Then in `extension.dart`, splice the block into the `validate()` and `validateAsync()` bodies before the `if ($errors.isNotEmpty)` finalizer.

### 6.5 Tests

- `parsers_test.dart` — assert the annotation is parsed into `MyRefineInfo`.
- `generator/my_refine_test.dart` — assert the invocation is emitted.

---

## 7. Changing the build config defaults

`build.yaml` consumers can override per-project:

```yaml
# In a downstream package
targets:
  $default:
    builders:
      validasi:
        options:
          generateFields: false
          generateAssemble: false
```

The builder reads both keys in `builder.dart:build` via `boolOption(options.config, ...)`. The per-class `@ValidateClass(generateFields: …, generateAssemble: …)` override wins if present.

To add a new global toggle, mirror the existing pattern: read it in `builder.dart`, forward it to `ValidasiGenerator`, and use it in `generator.dart` orchestration.

---

## 8. Common gotchas

- **Type identity in metadata** — annotation detection is name-based (`element.enclosingElement.name == 'ValidateClass'`). A user-defined class named `ValidateClass` will be picked up. Phase 6 considered switching to `isAssignableFrom`, but the name check is the established pattern and matches what the rest of the codebase does.
- **Unknown rules are silently dropped** — in `_parseRule`, any rule whose name is not in `ruleGens` is emitted as `isUnknown: true` and never reaches the snippet emitter. If you write `@Validate.string([MyRule()])` and forget to register `MyRule`, you'll get no error and no validation. Consider upgrading this to a warning once the rule set stabilises.
- **`part of` means no imports** — `Allocator.none` is mandatory. If you add a new `refer('Type')` whose type lives in a package the user hasn't imported in the parent file, the build will fail.
- **`Method.body` is always a block body** — `code_builder` does not support `=>` expression bodies for `Method`. Simple getters end up as `{ return x; }` instead of `=> x;`. The `DartFormatter` will not rewrite blocks to arrows; this is a style preference baked into the emitter.
- **`await` is not emitted by `code_builder`** — you must put it in the `Code` body yourself, and set `m.modifier = MethodModifier.async`. Both are easy to forget.
- **`required v.s. optional` for the generated leaf's `value` parameter** — the snippet for `Required` now emits `if (value == null) { … }`. If you add a rule that mutates the value (like `Transform`), the `validate()` signature must accept a non-null value and the field type must be non-null. The `Rule` base class doesn't enforce this — it falls out of the `Required` semantics.

---

## 9. Where to look for what

| I want to change… | File |
|---|---|
| What runs at build time, builder config | `lib/src/builder.dart` |
| What `@ValidateClass` triggers, cycle detection | `lib/src/generator.dart` |
| How a field's rules are read from the AST | `lib/src/parsers/rules.dart` |
| The sealed class layout | `lib/src/generators/fields_class.dart` |
| The `validate()` / `validateAsync()` extension | `lib/src/generators/extension.dart` |
| The per-rule `if (check) { … }` body | `lib/src/generators/field_snippets.dart` |
| The `assemble_X` function | `lib/src/generators/cross_fields.dart` |
| A specific rule's emit logic | `lib/src/handlers/<rule>.dart` |
| Annotation definitions | `packages/validasi_annotation/lib/src/` |
| Shared string escaping | `lib/src/utils.dart` (top-level) |
