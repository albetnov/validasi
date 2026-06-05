import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/non_positive.dart';

void main() {
  group('NonPositive', () {
    test('should pass for negative integer', () {
      final rule = NonPositive<int>();
      final state = ValidationState();

      rule.apply(-42, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = NonPositive<int>();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for negative double', () {
      final rule = NonPositive<double>();
      final state = ValidationState();

      rule.apply(-3.14, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for positive number', () {
      final rule = NonPositive<int>();
      final state = ValidationState();

      rule.apply(1, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('nonPositive'));
      expect(state.errors.first.message, equals('value must be non-positive'));
    });

    test('should use custom message', () {
      final rule = NonPositive<int>(message: 'Must be <= 0');
      final state = ValidationState();

      rule.apply(1, state);

      expect(state.errors.first.message, equals('Must be <= 0'));
    });

    test('should skip null values', () {
      final rule = NonPositive<int>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
