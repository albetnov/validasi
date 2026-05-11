import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/old_rules/inline_rule.dart';

void main() {
  group('InlineRule', () {
    test('should have runOnNull set to true', () {
      final rule = InlineRule<String>((value) => true);

      expect(rule.runOnNull, isTrue);
    });

    test('should pass when validator returns true', () {
      final rule =
          InlineRule<String>((value) => value != null && value.isNotEmpty);
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should fail when validator returns false', () {
      final rule = InlineRule<String>((value) => false);
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('inline_rule'));
      expect(context.errors.first.message, equals('Validation failed'));
    });

    test('should use custom message', () {
      final rule = InlineRule<String>(
        (value) => false,
        message: 'Custom validation message',
      );
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors.first.message, equals('Custom validation message'));
    });

    test('should use custom rule name', () {
      final rule = InlineRule<String>(
        (value) => false,
        name: 'custom_rule',
      );
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors.first.rule, equals('custom_rule'));
    });

    test('should handle null values', () {
      final rule = InlineRule<String>((value) => value == null);
      final context = ValidationContext<String>(value: null);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should catch exceptions in validator', () {
      final rule = InlineRule<String>((value) {
        throw Exception('Validator exception');
      });
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.rule, equals('inline_rule'));
    });

    test('should use custom message on exception', () {
      final rule = InlineRule<String>(
        (value) {
          throw Exception('Validator exception');
        },
        message: 'Custom error message',
      );
      final context = ValidationContext<String>(value: 'test');

      rule.apply(context);

      expect(context.errors.first.message, equals('Custom error message'));
    });

    test('should work with complex validators', () {
      final rule = InlineRule<int>(
        (value) => value != null && value > 0 && value < 100,
        message: 'Value must be between 1 and 99',
      );

      final validContext = ValidationContext<int>(value: 50);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<int>(value: 150);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with list values', () {
      final rule = InlineRule<List<int>>(
        (value) => value != null && value.length >= 3,
        message: 'List must have at least 3 items',
      );

      final validContext = ValidationContext<List<int>>(value: [1, 2, 3]);
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<List<int>>(value: [1, 2]);
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });

    test('should work with map values', () {
      final rule = InlineRule<Map<String, dynamic>>(
        (value) => value != null && value.containsKey('required'),
        message: 'Map must contain required key',
      );

      final validContext = ValidationContext<Map<String, dynamic>>(
        value: {'required': 'value'},
      );
      rule.apply(validContext);
      expect(validContext.errors, isEmpty);

      final invalidContext = ValidationContext<Map<String, dynamic>>(
        value: {'other': 'value'},
      );
      rule.apply(invalidContext);
      expect(invalidContext.errors.length, equals(1));
    });
  });
}
