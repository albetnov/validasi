## 0.1.0-dev.2

- Add `@RefineFn(dependsOn: ['field1', 'field2'])` — marks an instance method as a cross-field refine. The method receives a `FailFn` callback as its first positional parameter, followed by named parameters matching field names. Async is detected from the return type.
- Add `FailFn` typedef — `void Function({required String message, List<String> path})`.
- Add `generateFields` and `generateAssemble` named parameters to `@ValidateClass()`.
- **Removed**: `@ValidateWith`, `@ValidateWithAsync`, `@Refine`, `@RefineAsync` (replaced by `@RefineFn`).

## 0.1.0-dev.1

- Initial development release.
- Add `ValidasiKey<T>` base type for typed field-level validation keys.
- Re-export `ValidasiKey` from `validasi_annotation.dart`.
- Add `generateFields` and `generateAssemble` named parameters to `@ValidateClass()`.
- Provides `@ValidateClass()` and `@Validate` annotations for `validasi_gen`.
