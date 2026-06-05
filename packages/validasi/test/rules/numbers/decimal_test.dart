import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/decimal.dart';

void main() {
  group('Decimal', () {
    test('should pass for positive decimal', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(3.14, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for negative decimal', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(-3.14, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(0.0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for whole number double', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(42.0, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for infinity', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(double.infinity, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('decimal'));
      expect(
        state.errors.first.message,
        equals('value must be a finite decimal'),
      );
    });

    test('should fail for NaN', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(double.nan, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Decimal(message: 'Must be a real number');
      final state = ValidationState();

      rule.apply(double.infinity, state);

      expect(state.errors.first.message, equals('Must be a real number'));
    });

    test('should skip null values', () {
      final rule = Decimal();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
