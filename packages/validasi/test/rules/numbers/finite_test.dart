import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/numbers/finite.dart';

void main() {
  group('Finite', () {
    test('should pass for finite positive number', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: 42.0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for finite negative number', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: -42.0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: 0.0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail for positive infinity', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: double.infinity);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('finite'));
      expect(
        context.errors.first.message,
        equals('value must be a finite number'),
      );
    });

    test('should fail for negative infinity', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: double.negativeInfinity);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should fail for NaN', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: double.nan);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Finite(message: 'Must be a real number');
      final context = ValidationContext<double>(value: double.infinity);

      rule.apply(context);

      expect(context.errors.first.message, equals('Must be a real number'));
    });

    test('should pass for very large finite numbers', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: double.maxFinite);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for very small finite numbers', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: -double.maxFinite);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass for decimal numbers', () {
      final rule = Finite();
      final context = ValidationContext<double>(value: 3.14159);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}
