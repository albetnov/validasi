import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/finite.dart';

void main() {
  group('Finite', () {
    test('should pass for finite positive number', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(42.0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for finite negative number', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(-42.0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(0.0, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for positive infinity', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(double.infinity, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('finite'));
      expect(
        state.errors.first.message,
        equals('value must be a finite number'),
      );
    });

    test('should fail for negative infinity', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(double.negativeInfinity, state);

      expect(state.errors.length, equals(1));
    });

    test('should fail for NaN', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(double.nan, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Finite(message: 'Must be a real number');
      final state = ValidationState();

      rule.apply(double.infinity, state);

      expect(state.errors.first.message, equals('Must be a real number'));
    });

    test('should pass for very large finite numbers', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(double.maxFinite, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for very small finite numbers', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(-double.maxFinite, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for decimal numbers', () {
      final rule = Finite();
      final state = ValidationState();

      rule.apply(3.14159, state);

      expect(state.errors, isEmpty);
    });
  });
}
