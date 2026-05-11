import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/numbers/more_than_equal.dart';

void main() {
  group('MoreThanEqual', () {
    test('should pass when value is greater than min', () {
      final rule = MoreThanEqual<int>(10);
      final context = ValidationContext<int>(value: 15);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should pass when value equals min', () {
      final rule = MoreThanEqual<int>(10);
      final context = ValidationContext<int>(value: 10);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when value is less than min', () {
      final rule = MoreThanEqual<int>(10);
      final context = ValidationContext<int>(value: 9);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('moreThanEqual'));
      expect(
        context.errors.first.message,
        equals('value must be more than or equal to 10'),
      );
    });

    test('should use custom message', () {
      final rule = MoreThanEqual<int>(10, message: 'Too small!');
      final context = ValidationContext<int>(value: 5);

      rule.apply(context);

      expect(context.errors.first.message, equals('Too small!'));
    });

    test('should work with negative numbers', () {
      final rule = MoreThanEqual<int>(0);

      final validContext1 = ValidationContext<int>(value: 0);
      rule.apply(validContext1);
      expect(validContext1.errors, isEmpty);

      final validContext2 = ValidationContext<int>(value: 5);
      rule.apply(validContext2);
      expect(validContext2.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: -5);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = MoreThanEqual<double>(10.5);

      final validContext1 = ValidationContext<double>(value: 10.5);
      rule.apply(validContext1);
      expect(validContext1.errors, isEmpty);

      final validContext2 = ValidationContext<double>(value: 10.6);
      rule.apply(validContext2);
      expect(validContext2.errors, isEmpty);

      final invalidContext = ValidationContext<double>(value: 10.4);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = MoreThanEqual<int>(0);

      final validContext = ValidationContext<int>(value: 0);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: -1);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });
  });
}
