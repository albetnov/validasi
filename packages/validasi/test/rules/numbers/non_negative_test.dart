import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/non_negative.dart';

void main() {
  group('NonNegative', () {
    test('should pass for positive integer', () {
      final rule = NonNegative<int>();
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = NonNegative<int>();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for positive double', () {
      final rule = NonNegative<double>();
      final state = ValidationState();

      rule.apply(3.14, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for negative number', () {
      final rule = NonNegative<int>();
      final state = ValidationState();

      rule.apply(-1, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('nonNegative'));
      expect(state.errors.first.message, equals('value must be non-negative'));
    });

    test('should use custom message', () {
      final rule = NonNegative<int>(message: 'Must be >= 0');
      final state = ValidationState();

      rule.apply(-1, state);

      expect(state.errors.first.message, equals('Must be >= 0'));
    });

    test('should skip null values', () {
      final rule = NonNegative<int>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
