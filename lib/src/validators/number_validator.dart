import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating [num] for both [double] and [int] also
/// support type conversion from [String] based on [num.tryParse].
class NumberValidator extends Validator<num> {
  NumberValidator({super.transformer});

  /// [required] indicate that the [value] cannot be `null`
  NumberValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  NumberValidator nonDecimal({String? message}) {
    addRule(
        name: 'nonDecimal',
        test: (value) {
          if (value == null) return false;

          return value is int || value == value.roundToDouble();
        },
        message: message ?? ':name must be non-decimal number');

    return this;
  }

  NumberValidator decimal({String? message}) {
    addRule(
        name: 'decimal',
        test: (value) => value is double,
        message: message ?? ':name must be decimal number');

    return this;
  }

  NumberValidator positive({String? message}) {
    addRule(
        name: 'positive',
        test: (value) => value != null && value > 0,
        message: message ?? ':name must be positive number');

    return this;
  }

  NumberValidator negative({String? message}) {
    addRule(
        name: 'negative',
        test: (value) => value != null && value < 0,
        message: message ?? ':name must be negative number');

    return this;
  }

  NumberValidator nonPositive({String? message}) {
    addRule(
        name: 'nonPositive',
        test: (value) => value != null && value <= 0,
        message: message ?? ':name must be non-positive number');

    return this;
  }

  NumberValidator nonNegative({String? message}) {
    addRule(
        name: 'nonNegative',
        test: (value) => value != null && value >= 0,
        message: message ?? ':name must be non-negative number');

    return this;
  }

  NumberValidator gt(num min, {String? message}) {
    addRule(
        name: 'gt',
        test: (value) => value != null && value > min,
        message: message ?? ':name must be greater than $min');

    return this;
  }

  NumberValidator gte(num min, {String? message}) {
    addRule(
        name: 'gte',
        test: (value) => value != null && value >= min,
        message: message ?? ':name must be greater than or equal to $min');

    return this;
  }

  NumberValidator lt(num max, {String? message}) {
    addRule(
        name: 'lt',
        test: (value) => value != null && value < max,
        message: message ?? ':name must be less than $max');

    return this;
  }

  NumberValidator lte(num max, {String? message}) {
    addRule(
        name: 'lte',
        test: (value) => value != null && value <= max,
        message: message ?? ':name must be less than or equal to $max');

    return this;
  }

  NumberValidator finite({String? message}) {
    addRule(
        name: 'finite',
        test: (value) => value != null && value.isFinite,
        message: message ?? ':name must be finite number');

    return this;
  }

  @override
  NumberValidator custom(callback) => super.custom(callback);

  @override
  NumberValidator customFor(customRule) => super.customFor(customRule);
}
