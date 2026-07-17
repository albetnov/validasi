# Configuration

The `validasi_gen` build options control which artifacts are emitted. They can be
set globally in `build.yaml` and overridden per class via `@ValidateClass`.

## Global options (`build.yaml`)

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateSchema: true
          generateValidateForm: false
          generateIndexedFields: false
```

| Option | Type | Default | Description |
|--------|------|:---:|-------------|
| `generateFields` | `bool` | `true` | Emit `sealed class XFields<V>` + per-field leaf classes + `validateField()`. **Gates `generateSchema` and `generateValidateForm`** — if this is `false`, those two produce nothing even when set to `true`. |
| `generateSchema` | `bool` | `true` | Emit `static const ValidasiSchema<X> schema` on the fields class + `_XSchema` implementation |
| `generateValidateForm` | `bool` | `false` | Emit `validateForm_X(controller)` top-level function (requires `validasi_ui`). **No per-class override** — see below. |
| `generateIndexedFields` | `bool` | `false` | Emit `indexedFields`, `reconstructItem`, `reconstructAll` (requires `validasi_ui`; for field arrays) |

## Per-class overrides

`@ValidateClass(...)` takes exactly three parameters — `generateFields`, `generateSchema`, and
`generateIndexedFields` — each overriding the corresponding global option for that class only.
**`generateValidateForm` has no per-class override; it's build-level only.**

```dart
@ValidateClass(generateFields: true, generateSchema: true)
class User {
  // ...
}

@ValidateClass(generateFields: false)
class InternalOnly {
  // No XFields hierarchy emitted — only validate()
}
```

Per-class settings take precedence over `build.yaml` for the three flags that support them.

## Recommended configs

### Dart-only (no Flutter, no forms)

```yaml
options:
  generateFields: true
  generateSchema: false
  generateValidateForm: false
```

### Flutter with form management

```yaml
options:
  generateFields: true
  generateSchema: true
  generateValidateForm: true
```

### Flutter with field arrays

```yaml
options:
  generateFields: true
  generateSchema: true
  generateValidateForm: true
  generateIndexedFields: true
```

### Minimal (just `validate()` extension)

```yaml
options:
  generateFields: false
  generateSchema: false
  generateValidateForm: false
```

## Generated artifacts by option

```
@ValidateClass()
class User { ... }

generateFields: true     →  sealed class UserFields<V>
                            UserFields.name, .email, .age constants
                            extension: validateField<V>(UserFields<V>)

generateSchema: true     →  UserFields.schema (ValidasiSchema<User>)
                            class _UserSchema
                            (no-op unless generateFields is also true)

generateValidateForm: true → validateForm_User(ValidasiFormController<User>)
                            (reads from controller, runs refines)
                            (no-op unless generateFields is also true)

generateIndexedFields: true → UserFields.name_indexed(index)
                              UserFields.indexedFields()
                              UserFields.reconstructItem(...)
                              UserFields.reconstructAll(...)
```

## Example: full build.yaml

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateSchema: true
          generateValidateForm: true
          generateIndexedFields: false
        generate_for:
          exclude:
            - "lib/generated/**"
```

The `generate_for` filter controls which files the builder processes. Exclude
directories like `lib/generated/` if you keep generated files versioned separately.
