import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/numbers/less_than.dart';

void main() {
  group('LessThan', () {
    test('should pass when value is less than max', () {
      final rule = LessThan<int>(10);
      final context = ValidationContext<int>(value: 5);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when value equals max', () {
      final rule = LessThan<int>(10);
      final context = ValidationContext<int>(value: 10);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('lessThan'));
      expect(
          context.errors.first.message, equals('value must be less than 10'));
    });

    test('should fail when value is greater than max', () {
      final rule = LessThan<int>(10);
      final context = ValidationContext<int>(value: 15);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = LessThan<int>(10, message: 'Too big!');
      final context = ValidationContext<int>(value: 15);

      rule.apply(context);

      expect(context.errors.first.message, equals('Too big!'));
    });

    test('should work with negative numbers', () {
      final rule = LessThan<int>(0);

      final validContext = ValidationContext<int>(value: -5);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: 5);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = LessThan<double>(10.5);

      final validContext = ValidationContext<double>(value: 10.4);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<double>(value: 10.5);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = LessThan<int>(1);
      final context = ValidationContext<int>(value: 0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with very large numbers', () {
      final rule = LessThan<int>(1000000);
      final context = ValidationContext<int>(value: 999999);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with decimal precision', () {
      final rule = LessThan<double>(1.001);
      final context = ValidationContext<double>(value: 1.0);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}
