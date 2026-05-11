import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/string/one_of.dart';

void main() {
  group('OneOf', () {
    test('should pass when value is in options', () {
      final rule = OneOf(['apple', 'banana', 'cherry']);
      final context = ValidationContext<String>(value: 'apple');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when value is not in options', () {
      final rule = OneOf(['apple', 'banana', 'cherry']);
      final context = ValidationContext<String>(value: 'orange');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('OneOf'));
      expect(
        context.errors.first.message,
        equals('Value must be one of: apple, banana, cherry'),
      );
    });

    test('should use custom message', () {
      final rule = OneOf(['a', 'b'], message: 'Pick a or b');
      final context = ValidationContext<String>(value: 'c');

      rule.apply(context);

      expect(context.errors.first.message, equals('Pick a or b'));
    });

    test('should include options in details', () {
      final rule = OneOf(['a', 'b', 'c']);
      final context = ValidationContext<String>(value: 'd');

      rule.apply(context);

      expect(context.errors.first.details?['options'], equals('a, b, c'));
    });

    test('should work with single option', () {
      final rule = OneOf(['only']);

      final validContext = ValidationContext<String>(value: 'only');
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<String>(value: 'other');
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with empty options list', () {
      final rule = OneOf([]);
      final context = ValidationContext<String>(value: 'any');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should be case sensitive', () {
      final rule = OneOf(['Apple', 'Banana']);
      final context = ValidationContext<String>(value: 'apple');

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should work with empty string option', () {
      final rule = OneOf(['', 'a', 'b']);
      final context = ValidationContext<String>(value: '');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with many options', () {
      final rule = OneOf(List.generate(100, (i) => 'option$i'));

      final validContext = ValidationContext<String>(value: 'option50');
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<String>(value: 'invalid');
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with special characters', () {
      final rule = OneOf(['@', '#', '\$']);
      final context = ValidationContext<String>(value: '@');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with whitespace strings', () {
      final rule = OneOf([' ', '\t', '\n']);
      final context = ValidationContext<String>(value: ' ');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}
