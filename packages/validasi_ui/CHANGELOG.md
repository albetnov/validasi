## 0.1.0-dev.4

### Breaking Changes

- `shouldUnregister` default changed from `true` to `false`. Field state (value, errors,
  dirty/touched) now persists across mount/unmount cycles by default. Set
  `shouldUnregister: true` on `ValidasiForm` or per-field to restore the old behavior.

### Added

- New comprehensive E2E tests: cross-field refinement rebuild cost, surgical rendering
  isolation, resource leak detection, behavior mismatch verification, and watch + form
  field interaction.
- `ValidasiFieldSignals` disposed-signal detection: read getters now throw a descriptive
  `StateError` with migration guidance when accessed after disposal.

### Fixed

- Async coordinator: `finally` block no longer writes `isValidating = false` to disposed
  signals (version check guard).
- Async coordinator: guard against timer firing after field unregister (disposed-signal
  check on all signal setters).
- `validate()`: only rebuilds widgets for fields whose error state actually changed
  (added `_fieldErrorsEqual` comparison in `_applyErrors`).
- `_distributeFormErrors`: now wraps writes in `batch()` and only clears fields that
  previously had errors but aren't in the new error set — preventing unnecessary
  SignalBuilder notifications.
- `clearAllErrors()` and `setInitialValues()`: wrapped in `batch()` for consistent
  signal notification batching.
- `ValidasiWatch.field`: removed redundant `SignalBuilder.dependencies` (auto-detection
  via `onSignalRead` is sufficient).

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