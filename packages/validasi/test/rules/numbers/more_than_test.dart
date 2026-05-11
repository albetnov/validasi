import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/numbers/more_than.dart';

void main() {
  group('MoreThan', () {
    test('should pass when value is greater than min', () {
      final rule = MoreThan<int>(10);
      final context = ValidationContext<int>(value: 15);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when value equals min', () {
      final rule = MoreThan<int>(10);
      final context = ValidationContext<int>(value: 10);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('moreThan'));
      expect(
        context.errors.first.message,
        equals('value must be more than 10'),
      );
    });

    test('should fail when value is less than min', () {
      final rule = MoreThan<int>(10);
      final context = ValidationContext<int>(value: 5);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = MoreThan<int>(10, message: 'Too small!');
      final context = ValidationContext<int>(value: 5);

      rule.apply(context);

      expect(context.errors.first.message, equals('Too small!'));
    });

    test('should work with negative numbers', () {
      final rule = MoreThan<int>(-10);

      final validContext = ValidationContext<int>(value: -5);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: -15);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = MoreThan<double>(10.5);

      final validContext = ValidationContext<double>(value: 10.6);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<double>(value: 10.5);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = MoreThan<int>(0);

      final validContext = ValidationContext<int>(value: 1);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: 0);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });
  });
}
