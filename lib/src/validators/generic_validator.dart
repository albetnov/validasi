import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

class GenericValidator<T> extends Validator<T> {
  GenericValidator({super.transformer});

  @override
  GenericValidator<T> nullable() => super.nullable();

  @override
  GenericValidator<T> custom(CustomCallback<T> callback) =>
      super.custom(callback);

  @override
  GenericValidator<T> customFor(CustomRule<T> customRule) =>
      super.customFor(customRule);

  GenericValidator<T> equalTo(T value, {String? message}) {
    addRule(
      name: 'equalTo',
      test: (v) => v == value,
      message: message ?? ':name must be equal to $value',
    );

    return this;
  }

  GenericValidator<T> notEqualTo(T value, {String? message}) {
    addRule(
      name: 'notEqualTo',
      test: (v) => v != value,
      message: message ?? ':name must not be equal to $value',
    );

    return this;
  }

  GenericValidator<T> oneOf(List<T> values, {String? message}) {
    addRule(
      name: 'oneOf',
      test: (v) => values.contains(v),
      message: message ?? ':name must be one of $values',
    );

    return this;
  }

  GenericValidator<T> notOneOf(List<T> values, {String? message}) {
    addRule(
      name: 'notOneOf',
      test: (v) => !values.contains(v),
      message: message ?? ':name must not be one of $values',
    );

    return this;
  }
}
