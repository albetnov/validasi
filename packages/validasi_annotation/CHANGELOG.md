## 0.1.0-dev.1

- Initial development release.
- Add `ValidasiKey<T>` base type for typed field-level validation keys.
- Re-export `ValidasiKey` from `validasi_annotation.dart`.
- Add `generateFields` named parameter to `@ValidateClass()` to override the global per-field generation flag. `null` (the default) means "use the builder-level default"; pass `true` or `false` to make it explicit.
- Provides `@ValidateClass()` and `@Validate` annotations for `validasi_gen`.
