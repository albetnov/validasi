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