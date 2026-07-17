# Extensibility Mechanisms

Full contracts for every way to extend generated validation beyond the built-in rule catalog. See
`SKILL.md` for the one-line decision table; this file has the signatures, build-time contracts, and
a worked example per mechanism.

## Inline

A synchronous, one-off check backed by a `static` or top-level function — no reusable class needed.

```dart
class Inline<T> extends Rule<T> {
  const Inline(this.validator, {this.name = 'inline', super.message, this.runOnNull = false});
  final bool Function(T? value) validator;
  final String name;       // tags the emitted error's `rule`
  final bool runOnNull;    // default false: skipped when the value is null
}
```

```dart
@Validate<CustomDataClass?>([Required(), Inline(_validateCustomClass)])
final CustomDataClass? customData;

static bool _validateCustomClass(dynamic value) {
  if (value is! CustomDataClass) return false;
  return value.id > 0;
}
```

The function **must be static or top-level** — the generator emits a qualified call
(`User._validateCustomClass(value)` for a static method, or the bare name for a top-level
function); an instance method reference wouldn't resolve outside the instance. Default error
message is `'$name: validation failed.'`.

## AsyncInline

Same shape as `Inline`, but the validator returns `FutureOr<bool>` — for a check that needs
`await` (an HTTP call, a DB lookup) without promoting it to a reusable `AsyncCustomRule`.

```dart
class AsyncInline<T> extends Rule<T> {
  const AsyncInline(this.validator, {super.message, this.name = 'async_inline'});
  final Function validator; // FutureOr<bool> Function(T? value)
  final String name;
}
```

```dart
@Validate<String>([MinLength(3), MaxLength(100), AsyncInline(_checkUsernameAvailable)])
final String username;

FutureOr<bool> _checkUsernameAvailable(String? value) async {
  await Future<void>.delayed(Duration.zero);
  return value != 'taken';
}
```

Presence of this rule anywhere on the class flips it async-only (see "Async rules discipline" in
`SKILL.md`). If the validator function **throws**, the thrown value's `toString()` becomes the
error message — a convenient way to surface a specific failure reason from inside the check
without constructing a `ValidationError` yourself.

## CustomRule / AsyncCustomRule

Reusable, parameterizable rule classes — the promotion path once the same `Inline`/`AsyncInline`
check starts appearing on more than one field.

```dart
class CustomRule<T> extends Rule<T> {
  const CustomRule({required this.name, super.message, this.runOnNull = false});
  final String name;
  final bool runOnNull;
}
// AsyncCustomRule<T> has the identical shape.
```

Subclass it and give the subclass a `static check` method — the generator enforces this contract
at build time (`InvalidGenerationSourceError` on violation):

- `check`'s **first parameter must be positional** (the value to validate).
- Sync `CustomRule.check` must return `bool`; `AsyncCustomRule.check` must return
  `Future<bool>`/`FutureOr<bool>`.
- Every parameter *after* the first must be **named**, and each named parameter's name **must match
  a field name** on the rule class — its value is read off the const rule instance and threaded
  through as a literal config argument.

```dart
class NoSpaces extends CustomRule<String> {
  const NoSpaces({String? message, super.runOnNull})
      : super(name: 'noSpaces', message: message);

  static bool check(String? value) => value == null || !value.contains(' ');
}

@Validate<String>([MinLength(3), MaxLength(100), NoSpaces()])
final String email;
```

With config: a field like `final int minAge;` on the rule class lets `check(String? value, {int
minAge})` receive it — pass `minAge: 18` when constructing the rule, and the generator threads that
literal through to every call site.

## RefineFn

A hand-written cross-field check — the escape hatch when no cross-field sugar annotation
(below) fits the shape.

```dart
typedef FailFn = void Function({required String message, List<String> path});

class RefineFn {
  const RefineFn({this.dependsOn = const []});
  final List<String> dependsOn;
}
```

Apply it to a `static` method (as of a recent release, non-static throws
`InvalidGenerationSourceError` — the generator needs to call it from both `validate()` and, if
enabled, `validateForm_X(ctrl)`). Every named parameter on the method corresponds to a name in
`dependsOn`, and the generator supplies the current value of that field automatically:

```dart
@RefineFn(dependsOn: ['email', 'confirmEmail'])
static void emailMatchesConfirm(FailFn fail, {String? email, String? confirmEmail}) {
  if (email != null && confirmEmail != null && email != confirmEmail) {
    fail(message: 'Emails do not match', path: ['confirmEmail']);
  }
}
```

Errors raised via `fail(...)` are tagged `rule: 'Refine'`. `path` defaults to `[]` (a form-level,
un-pathed error) when omitted. Return `Future<void>` and the generator inserts the `await` for you
when calling it from `validateAsync()`/an async form validator.

## Cross-field sugar

Class-level annotations that desugar into a synthetic `RefineFn`-shaped check for you — reach for
these before hand-writing a `RefineFn` method, since they cover the common shapes declaratively and
are stackable (apply as many as you need):

```dart
RequiredAny(List<String> fields, {String? message})        // at least one of `fields` present
RequiredOneOf(List<String> fields, {String? message})      // exactly one present (XOR)
RequiredAll(List<String> fields, {String? message})        // if any present, all present
DependsOn({required String field, required String dependsOn, String? message})
MutuallyExclusive(String fieldA, String fieldB, {String? message})
MatchesField({required String field, required String matchesField, String? message})
```

```dart
@ValidateClass(generateFields: false, generateSchema: false)
@RequiredAny(['email', 'phone'])
@MatchesField(field: 'password', matchesField: 'passwordConfirmation')
class ContactInfo {
  final String? email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;
  const ContactInfo({this.email, this.phone, this.password, this.passwordConfirmation});
}
```

## A note on `@Validate<T>`'s type argument

`@Validate<T>([...])` dispatches rule handling by `T` (string / iterable / generic context) — the
type argument does the work, there is no `@Validate.string([...])` named-constructor form despite
what older docs in this repo show. Always write the type argument explicitly and match it to the
field's declared type.
