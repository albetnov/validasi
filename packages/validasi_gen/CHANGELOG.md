## 0.1.0-dev.2

- Add cross-field validation support with `validateFields` and related methods.
- Add async validation support with `validateAsync` methods in generated code.
- Add `@RefineFn` annotation with `FailFn`, remove old `@Refine`/`@RefineAsync`.
- Prevent nested fields from being processed in `generateFromForm` method.
- Refactor field generation and validation logic; improve codegen formatting.
- Add support for indexed fields in validation framework.
- Update docs and improve generated code formatting.

## 0.1.0-dev.1

- Initial development release.
- Generates `validate()` extension method for `@ValidateClass()` annotated classes.
- Supports `MinLength`, `MaxLength`, `OneOf`, `Required`, `Nullable` string rules via direct Dart codegen (Level 2).
- Add per-field validation: for each `@ValidateClass()` type, emit a sealed `XFields<V>` hierarchy that extends `ValidasiKey<X>` from `validasi_annotation`.
- Each annotated or nested field becomes a public `XFieldNameField` leaf, exposing `name`, `extract(X owner)`, and `validate(V? value)`.
- Add `validateField<V>(XFields<V> field)` on the generated extension, with `V` inferred from the field key.
- Standalone usage is supported via the leaf directly: `XFields.email.validate('value')`.
- Pattern matching is exhaustive on the sealed `XFields` for downstream form libraries.
- Existing `validate()` is unchanged in behavior; codegen now shares the rule emission helpers.
- Add `generateFields` build option (default `true`) and matching `@ValidateClass(generateFields: ...)` per-class override. When set to `false`, the `XFields` sealed class, the per-field leaves, and the `validateField<V>` method are not emitted — only the existing `validate()` extension is generated.
- Per-class annotation takes precedence over the build-level default. A non-bool value in `build.yaml` is rejected at builder construction with an `InvalidGenerationSourceError`.
