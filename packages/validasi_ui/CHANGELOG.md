## 0.1.0-dev.3

### Breaking Changes

- `ValidasiTextFormField<T>` and `ValidasiParsedTextFormField<T, V>` are **removed**.
  Replaced by `ValidasiTextField<T, V>` + `ValidasiTextController`.
  Migration: replace `ValidasiTextFormField(field: ..., decoration: ...)` with
  `ValidasiTextField<T, String>(field: ..., builder: ...)`. See README for details.

### Added

- `ValidasiSchema<T>` integration: form controller and fields now work with `ValidasiSchema`
  and `ValidasiFieldReader` abstractions from validasi core.
- `ValidasiTextField<T, V>` — wraps `ValidasiFormField` with automatic
  `TextEditingController` lifecycle and form-value sync. Accepts an optional
  `ValidasiTextController` for programmatic control (clear, selection, etc.).
  Builder receives `(context, state, controller)` with zero `TextField`-API coupling.
- `ValidasiTextController` — a `TextEditingController` subclass for use with
  `ValidasiTextField`.

### Fixed

- Async coordinator: use safe ternary instead of unchecked cast for values passed as
  `dynamic`/`Object`.
- Controller `setValue`: add assert to catch type mismatches at runtime.

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