## 0.1.0-dev.3

### Breaking Changes

- `ValidasiForm` and `ValidasiFormController` no longer accept `assembler`. Use `schema`
  (`ValidasiSchema<T>`) instead. Generated schemas are exposed as `<ClassName>Fields.schema`.

### Added

- `ValidasiFormController<T>` now implements `ValidasiFieldReader<T>`.
- `ValidasiTextFormField<T>` convenience widget for `String` fields.
- `ValidasiParsedTextFormField<T, V>` convenience widget for fields parsed from `String` to `V`.

## 0.1.0-dev.2

- Updated `validasi` dependency to `^1.0.0-rc.2`.

## 0.1.0-dev.1

- Add `ValidasiFormController` with field signal management, dirty/touched state, migration/swap support.
- Add `FormValidator` — route `validate()` through form validator with error distribution.
- Add `setError()` with overwrite option, `clearErrors()`, `validateAsync()`.
- Add `shouldUnregister` option for field cleanup.
- Add disposal checks — methods throw `StateError` when disposed.
- Add async validation coordination and field disabling logic.
- Add support for indexed fields in validation framework.
- Add `getValues()` method for value retrieval.
- Improve docs and add comprehensive tests.

## 0.1.0-dev.0

- Initial development release.