import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating [num] for both [double] and [int] also
/// support type conversion from [String] based on [num.tryParse].
class NumberValidator extends Validator<num> {
  NumberValidator({super.transformer});

  @override
  NumberValidator nullable() => super.nullable();

  @override
  NumberValidator custom(CustomCallback<num> callback) =>
      super.custom(callback);

  @override
  NumberValidator customFor(CustomRule<num> customRule) =>
      super.customFor(customRule);

  /// Check if the value is an integer, not a decimal/float.
  NumberValidator nonDecimal({String? message}) {
    addRule(
        name: 'nonDecimal',
        test: (value) => value is int || value == value.roundToDouble(),
        message: message ?? ':name must be non-decimal number');

    return this;
  }

  /// Check if the value is a decimal/float, not an integer.
  NumberValidator decimal({String? message}) {
    addRule(
        name: 'decimal',
        test: (value) => value is double,
        message: message ?? ':name must be decimal number');

    return this;
  }

  /// Check if the value is a positive number (> 0).
  NumberValidator positive({String? message}) {
    addRule(
        name: 'positive',
        test: (value) => value > 0,
        message: message ?? ':name must be positive number');

    return this;
  }

  /// Check if the value is a negative number (< 0).
  NumberValidator negative({String? message}) {
    addRule(
        name: 'negative',
        test: (value) => value < 0,
        message: message ?? ':name must be negative number');

    return this;
  }

  /// Check if the value is a non-positive number (<= 0).
  NumberValidator nonPositive({String? message}) {
    addRule(
        name: 'nonPositive',
        test: (value) => value <= 0,
        message: message ?? ':name must be non-positive number');

    return this;
  }

  /// Check if the value is a non-negative number (>= 0).
  NumberValidator nonNegative({String? message}) {
    addRule(
        name: 'nonNegative',
        test: (value) => value >= 0,
        message: message ?? ':name must be non-negative number');

    return this;
  }

  /// Check if the value is greater than [min].
  NumberValidator gt(num min, {String? message}) {
    addRule(
        name: 'gt',
        test: (value) => value > min,
        message: message ?? ':name must be greater than $min');

    return this;
  }

  /// Check if the value is greater than or equal to [min].
  NumberValidator gte(num min, {String? message}) {
    addRule(
        name: 'gte',
        test: (value) => value >= min,
        message: message ?? ':name must be greater than or equal to $min');

    return this;
  }

  /// Check if the value is less than [max].
  NumberValidator lt(num max, {String? message}) {
    addRule(
        name: 'lt',
        test: (value) => value < max,
        message: message ?? ':name must be less than $max');

    return this;
  }

  /// Check if the value is less than or equal to [max].
  NumberValidator lte(num max, {String? message}) {
    addRule(
        name: 'lte',
        test: (value) => value <= max,
        message: message ?? ':name must be less than or equal to $max');

    return this;
  }

  /// Check if the value is a finite number.
  NumberValidator finite({String? message}) {
    addRule(
        name: 'finite',
        test: (value) => value.isFinite,
        message: message ?? ':name must be finite number');

    return this;
  }
}
