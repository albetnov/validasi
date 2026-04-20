import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/rules/having.dart';

void main() {
  group('Having', () {
    test('should have runOnNull set to true', () {
      final rule = Having<String>(['a', 'b', 'c']);

      expect(rule.runOnNull, isTrue);
    });

    test('should pass when value is in valid values', () {
      final rule = Having<String>(['apple', 'banana', 'cherry']);
      final context = ValidationContext<String>(value: 'apple');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when value is not in valid values', () {
      final rule = Having<String>(['apple', 'banana', 'cherry']);
      final context = ValidationContext<String>(value: 'orange');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('having'));
      expect(
        context.errors.first.message,
        equals('Value must be one of: apple, banana, cherry'),
      );
    });

    test('should use custom message', () {
      final rule = Having<String>(
        ['apple', 'banana'],
        message: 'Pick from the list',
      );
      final context = ValidationContext<String>(value: 'orange');

      rule.apply(context);

      expect(context.errors.first.message, equals('Pick from the list'));
    });

    test('should work with integers', () {
      final rule = Having<int>([1, 2, 3, 4, 5]);

      final validContext = ValidationContext<int>(value: 3);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: 10);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with booleans', () {
      final rule = Having<bool>([true]);

      final validContext = ValidationContext<bool>(value: true);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<bool>(value: false);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should fail for null value', () {
      final rule = Having<String>(['apple', 'banana']);
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with single valid value', () {
      final rule = Having<String>(['only']);

      final validContext = ValidationContext<String>(value: 'only');
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<String>(value: 'other');
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with empty list of valid values', () {
      final rule = Having<String>([]);
      final context = ValidationContext<String>(value: 'any');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should be case sensitive for strings', () {
      final rule = Having<String>(['Apple', 'Banana']);
      final context = ValidationContext<String>(value: 'apple');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with many options', () {
      final rule = Having<int>(
        List.generate(100, (i) => i),
      );

      final validContext = ValidationContext<int>(value: 50);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: 150);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });
  });
}
