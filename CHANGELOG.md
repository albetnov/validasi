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