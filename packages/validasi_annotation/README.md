# validasi_annotation

Annotations for [Validasi](https://github.com/albetnov/validasi) code generation.

## Annotations

### `@ValidateClass(generateFields: ..., generateAssemble: ...)`

Class-level marker that triggers code generation. Both parameters are `bool?` — `null` uses the builder default; `true`/`false` forces an explicit override.

### `@Validate(rules)` / `@Validate.string(rules)` / `@Validate.iterable(rules)`

Field-level declarative rule list. The named constructors narrow the rule type for type-safe usage.

### `@Refine(validator, dependsOn: {})`

Class-level cross-field validation (repeatable). The validator receives a `getField` callback and returns `List<ValidationError>` with paths set.

### `@RefineAsync(validator, dependsOn: {})`

Async variant of `@Refine`.

## Other exports

- `ValidasiKey<T>` — base type for generated field-key hierarchies.
- `Rule<T>` — base class for declarative rule descriptors.
- Built-in rules: `Required`, `Nullable`, `AsyncInline`, `MinLength`, `MaxLength`, `OneOf`.
