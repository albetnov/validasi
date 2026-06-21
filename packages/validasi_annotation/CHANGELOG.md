## 0.2.0-dev.1

- **Breaking**: Remove `@ValidateWith` and `@ValidateWithAsync` (replaced by class-level `@Refine`/`@RefineAsync`).
- Add `@Refine` and `@RefineAsync` for class-level cross-field validation (repeatable).
- Document `generateFields` and `generateAssemble` parameters on `@ValidateClass()`.

## 0.1.0-dev.1

- Initial development release.
- Add `ValidasiKey<T>` base type for typed field-level validation keys.
- Re-export `ValidasiKey` from `validasi_annotation.dart`.
- Add `generateFields` and `generateAssemble` named parameters to `@ValidateClass()`.
- Provides `@ValidateClass()` and `@Validate` annotations for `validasi_gen`.
