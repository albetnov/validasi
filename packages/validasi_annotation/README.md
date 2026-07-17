# validasi_annotation

Annotations for [Validasi](https://pub.dev/packages/validasi) code generation.

## Annotations

### `@ValidateClass(generateFields: ..., generateSchema: ..., generateIndexedFields: ...)`
Class-level marker that triggers code generation. All three parameters are `bool?` — `null` uses
the builder default; `true`/`false` forces an explicit per-class override. A fourth build option,
`generateValidateForm`, exists but is build-level only — there's no per-class override for it.

### `@Validate<T>(rules)`
Field-level declarative rule list. The generic type argument `T` selects how rules are dispatched
(string / iterable / generic) — always write it explicitly and match it to the field's declared
type:

```dart
@Validate<String>([MinLength(3), MaxLength(100)])
final String email;
```

### `@RefineFn(dependsOn: ['field1', 'field2'])`
Class-level marker for cross-field validation. Placed on a `static` method on the class — the method must be `static` because the generator calls it via a fully-qualified reference (`ClassName.methodName(...)`) from both the instance-level `validate()`/`validateAsync()` extension and the top-level `validateForm_X(ctrl)` function, so it can't rely on an implicit instance receiver. The method receives a `FailFn` callback as its first positional parameter, followed by named parameters matching the field names in `dependsOn`. Async is detected from the return type (`Future<void>` = async).

```dart
class User {
  final String name;
  final String email;

  @RefineFn(dependsOn: ['name', 'email'])
  static void emailMatchesName(FailFn fail, {String? name, String? email}) {
    if (email != null && name != null && !email.contains(name)) {
      fail(message: 'Email must contain name', path: ['email']);
    }
  }
}
```

If `dependsOn` is empty, all fields are passed.

### `FailFn`
Callback type used by `@RefineFn` methods to report validation failures:
```dart
typedef FailFn = void Function({required String message, List<String> path});
```
The `path` defaults to `[]` (form-level) when omitted.

## Other exports

- `ValidasiKey<T>` — base type for generated field-key hierarchies.
- `Rule<T>` — base class for declarative rule descriptors.
- `Required<T>` / `Nullable<T>` — non-null control. Non-nullable Dart field types get an implicit
  `Required` check for free; `@Nullable()` opts a field out of that automatic check, and
  `@Required(message: ...)` overrides its message or forces it onto a nullable-typed field.
- The full built-in rule catalog, grouped by kind: string (`MinLength`, `MaxLength`, `Alpha`,
  `Alphanumeric`, `Numeric`, `Lowercase`, `Uppercase`, `StartsWith`, `EndsWith`, `Contains`,
  `Regex`, `Ulid`, `Uuid`, `Url`, `Ip`/`Ipv4`/`Ipv6`, `Email`), numeric (`Between`, `LessThan`,
  `LessThanEqual`, `MoreThan`, `MoreThanEqual`, `Negative`, `NonNegative`, `NonPositive`,
  `Positive`, `Finite`), iterable (`ExactLength`, `IsEmpty`, `IsNotEmpty`, `Unique`,
  `ContainsAll`, `NotContains` — plus `MinLength`/`MaxLength`, reused), and generic (`OneOf`,
  `Equals`, `NotEquals`, `Having`).
- Extensible rules — for checks the built-in catalog doesn't cover:
  - `Inline<T>(validator, {name, message, runOnNull})` — one-off synchronous check backed by a
    `static`/top-level function.
  - `AsyncInline<T>(validator, {name, message})` — same, but `validator` returns `FutureOr<bool>`.
  - `CustomRule<T>({required name, message, runOnNull})` — base for a reusable rule subclass with a
    `static bool check(T? value, {...})` method.
  - `AsyncCustomRule<T>({required name, message, runOnNull})` — same, with
    `static FutureOr<bool> check(T? value, {...})`.
- Cross-field sugar — class-level annotations that desugar into a synthetic `@RefineFn`:
  `RequiredAny(fields, {message})`, `RequiredOneOf(fields, {message})`,
  `RequiredAll(fields, {message})`, `DependsOn({field, dependsOn, message})`,
  `MutuallyExclusive(fieldA, fieldB, {message})`, `MatchesField({field, matchesField, message})`.
