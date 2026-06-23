# validasi_annotation

Annotations for [Validasi](https://pub.dev/packages/validasi) code generation.

## Annotations

### `@ValidateClass(generateFields: ..., generateAssemble: ...)`
Class-level marker that triggers code generation. Both parameters are `bool?` — `null` uses the builder default; `true`/`false` forces an explicit override.

### `@Validate(rules)` / `@Validate.string(rules)` / `@Validate.iterable(rules)`
Field-level declarative rule list. The named constructors narrow the rule type for type-safe usage.

### `@RefineFn(dependsOn: ['field1', 'field2'])`
Class-level marker for cross-field validation. Placed on an instance method on the class. The method receives a `FailFn` callback as its first positional parameter, followed by named parameters matching the field names in `dependsOn`. Async is detected from the return type (`Future<void>` = async).

```dart
class User {
  final String name;
  final String email;

  @RefineFn(dependsOn: ['name', 'email'])
  void emailMatchesName(FailFn fail, {String? name, String? email}) {
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
- Built-in rules: `Required`, `Nullable`, `AsyncInline`, `MinLength`, `MaxLength`, `OneOf`.
