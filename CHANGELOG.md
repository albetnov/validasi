## 0.0.1

Initial release of Validasi library. This release includes the following features:

- Built-in validators for common data types
- Object and Array schema for complex data validation
- Transformer to convert input value into desired format
- Safe validation using `tryParse` and `tryParseAsync` method
- Custom rule support

## 0.0.2

This release includes the following changes:

- Update documentation: fix typo `customAsync` to `custom`, add `validateAsync` to Helpers section
- Adjust validation(core): ensure rules are unique by using Map, so when rule registered more than once, the old one will be replaced
- Adjust validator test (core):
introduce `should only register rule once` test and adjust the `rules` from array to map
- Update package description to meet dart package criteria
- Update image in `README.md` to use absolute link

## 0.0.3

Minor release to update the following:

- Expose `FailFn`, `CustomRule`, `CustomCallback` API

## 0.0.4

This release introduce `GenericValidator`, add some rules for Array Validation, and add some methods for Object Validation.

- Add `max`, `notContains`, `contains`, and `unique` rule for `ArrayValidator`.
- Add `extend` and `without` method for `ObjectValidator`.
- Add new `GenericValidator` through `Validasi.generic<T>(transformer)` to help validate any type.

## 0.0.5

This release introduce breaking changes!
It simplifies the `FieldValidator` and `GroupValidator` Helpers API from previously when used in flutter:

```dart
var group = GroupValidator({
    'example': Validasi.string()
})

TextFormField(
  validator: (v) => FieldValidator(Validasi.string()).validate(v, path: 'Custom Path'),
)

TextFormField(
    validator: (v) => group.validate('example', v)
)
```

To a more simpler API:

```dart
var group = GroupValidator({
    'example': Validasi.string()
})

TextFormField(
  validator: FieldValidator(Validasi.string(), path: 'Custom Path').validate,
)

TextFormField(
    validator: group.on('example', path: 'Custom Path').validate
)
```

This means the previous code is not longer valid and should be updated to the new API.

Affected methods:
- `FieldValidator.validate`
- `GroupValidator.validate`

## 0.0.6

### What's Changed
* chore(deps): bump intl from 0.19.0 to 0.20.2 by @dependabot in https://github.com/albetnov/validasi/pull/4
* chore(deps): bump lints from 4.0.0 to 5.1.1 by @dependabot in https://github.com/albetnov/validasi/pull/5

### New Contributors
* @dependabot made their first contribution in https://github.com/albetnov/validasi/pull/4

**Full Changelog**: https://github.com/albetnov/validasi/compare/v0.0.5...v0.0.6

## 0.0.7

### What's Changed
* feat(string/url): Enhance url validation adding `checks` for validating `schema` and `host` using `UrlChecks` enum 
* chore(docs): Add `checks` to `url` method in `string.md` documentation
* chore(docs): Updated Quick Start guide in `doc/quick-start.md` to include
Flutter example

**Full Changelog**: https://github.com/albetnov/validasi/compare/v0.0.6...v0.0.7

## 0.0.8

### What's Changed
* rewrite most of GroupValidator code for better maintainability and readability
* Renamed `on` method to `using` to improve clarity
* Added `extend` method to allow extending the existing validator in group
* New `validateMap` and `validateMapAsync` methods to validate a map of values against the group schema.

### Breaking Changes

* `on` method in `GroupValidator` has been renamed to `using`. Update your code accordingly.
* Invalid field will return `ValidasiException("Field '$field' is not found in the schema")`. Impacted method (`validate`, `validateAsync`)
* Unset field will return `ValidasiException("Field is not set. Use 'using' method to set the field.")`. Impacted method (`validate`, `validateAsync`)

**Full Changelog**: https://github.com/albetnov/validasi/compare/v0.0.7...v0.0.8

## 0.0.9

### What's Changed
* Refactored `using` method to return `GroupValidatorUsing` instead of `GroupValidator` to improve DX and better isolation

### Breaking Changes

* `using` method in `GroupValidator` now returns `GroupValidatorUsing` instead of `GroupValidator`. Update your code accordingly.
* `validate` and `validateAsync` methods in `GroupValidator` is now removed. It could only be used in `GroupValidatorUsing` class.
```dart
// before
GroupValidator(...).validate(); // static check: OK
// after
**Full Changelog**: https://github.com/albetnov/validasi/compare/v0.0.7...v0.0.8
GroupValidator(...).using('field').validate(); // static check: OK
GroupValidator(...).validate(); // static check: ERROR
```

**Full Changelog**: https://github.com/albetnov/validasi/compare/v0.0.8...v0.0.9