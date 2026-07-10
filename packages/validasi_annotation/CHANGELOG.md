## 0.1.0-dev.5

### Added

- Documentation comments for `@Required` and `@Nullable` annotations explaining auto-inference behavior

### Changed

- Cross-field validation methods must now be static (enforced via code generation)

## 0.1.0-dev.4

### Added

- String validation annotations: `@Alpha`, `@Alphanumeric`, `@Numeric`, `@Lowercase`,
  `@Uppercase`, `@StartsWith`, `@EndsWith`, `@Regex`, `@Ulid`, `@Uuid`, `@Url`,
  `@Ip`, `@Ipv4`, `@Ipv6`, `@Email`, `@Contains`, `@NotContains`, `@ContainsAll`
- Numeric validation annotations: `@Between`, `@LessThan`, `@LessThanEqual`,
  `@MoreThan`, `@MoreThanEqual`, `@Negative`, `@NonNegative`, `@NonPositive`,
  `@Positive`, `@Finite`
- Iterable validation annotations: `@ExactLength`, `@IsEmpty`, `@IsNotEmpty`, `@Unique`
- Generic validation annotations: `@Equals`, `@NotEquals`, `@Having`
- Cross-field class-level annotations: `@RequiredAny`, `@RequiredOneOf`, `@RequiredAll`,
  `@DependsOn`, `@MutuallyExclusive`, `@MatchesField`

## 0.1.0-dev.3

### Breaking Changes

- `@ValidateClass()` parameter `generateAssemble` is renamed to `generateSchema`.
- `Validate` is now generic: use `Validate<T>([...])` instead of `Validate.string(...)` or
  `Validate.iterable(...)`.
- `rules` parameter in `Validate` is now required (use empty list `[]` for no rules).

### Added

- `@CustomRule`, `@AsyncCustomRule`, and `@Inline` annotations for custom code generation rules.

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
