# Build Flags

Full reference for the four `validasi_gen` build options — what each one emits, how they gate each
other, and how to override them per class. See `SKILL.md` for the quick-glance table.

## The four options

Set under `targets > $default > builders > validasi_gen:validasi > options` in `build.yaml`. Each
is read as a plain `bool`; a non-bool value throws at build time.

| Option | Default | Emits |
|--------|---------|-------|
| `generateFields` | `true` | The sealed `class XFields<V>` hierarchy (one `static const` singleton + leaf class per field), and `validateField<V>()`/`validateFieldAsync<V>()` on the generated extension. |
| `generateSchema` | `true` | `ValidasiSchema<X>`, exposed as `XFields.schema`. |
| `generateValidateForm` | `false` | `ValidasiResult<X> validateForm_X(ValidasiFormController<X> ctrl)`. References `validasi_ui` — off by default so plain-Dart consumers of `validasi_gen` aren't forced to depend on Flutter form plumbing. |
| `generateIndexedFields` | `false` | `indexedFields<FormType>`, `reconstructItem`, `reconstructAll` static methods on the sealed field class — for list-backed / repeatable form sections. References `IndexedField` from `validasi_ui`. |

## Gating: these flags are not independent

`generateSchema` and `generateValidateForm` only have any effect **while `generateFields` is also
true** — the generator nests both inside the `if (generateFields)` branch. Turn `generateFields`
off (e.g. for a purely internal type where you don't want the `XFields` surface at all) and you
silently lose the schema and form validator too, even if you left those two flags on.

`generateValidateForm` is additionally gated by the **build-level** default — there is no
`@ValidateClass(generateValidateForm: ...)` per-class override, unlike the other three. If you need
form validators for only some classes, that's presently an all-or-nothing build-level choice.

## `build.yaml`

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

Omit a key to keep its default — you rarely need to set all four; most projects only touch
`generateFields` (to trim generated surface for internal types) and, if using `validasi_ui` forms,
`generateValidateForm`.

## Per-class override

`@ValidateClass(...)` takes the same three overridable flags (not `generateValidateForm`):

```dart
@ValidateClass(generateSchema: false)
class User {
  @Validate<String>([MinLength(3), MaxLength(100)])
  final String email;
  // ...
}

@ValidateClass(generateFields: false)
class InternalFoo {
  @Validate<String>([MinLength(1)])
  final String code;
  // ...
}
```

A `null` (omitted) field on `@ValidateClass` falls back to the build-level default; a non-null
value always wins over the build-level default for that class.

## A stale-docs warning

The package's own `README.md` and `ARCH.md` describe an older API: a `generateAssemble` flag and
an emitted `assemble_X(...)` function. That option no longer exists — it was replaced by
`generateSchema` / `XFields.schema` in a subsequent dev release. The docs also don't mention
`generateIndexedFields` at all. Trust `lib/src/builder.dart` (the four keys above) over the shipped
prose if they ever disagree — the generator source is the only place these are read.
