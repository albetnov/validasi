import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/inline_rule.dart';

void main() {
  group('InlineRule', () {
    test('should have runOnNull set to true', () {
      final rule = InlineRule<String>((value) => true);

      expect(rule.runOnNull, isTrue);
    });

    test('should pass when validator returns true', () {
      final rule =
          InlineRule<String>((value) => value != null && value.isNotEmpty);
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when validator returns false', () {
      final rule = InlineRule<String>((value) => false);
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('inline_rule'));
      expect(state.errors.first.message, equals('Validation failed'));
    });

    test('should use custom message', () {
      final rule = InlineRule<String>(
        (value) => false,
        message: 'Custom validation message',
      );
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors.first.message, equals('Custom validation message'));
    });

    test('should use custom rule name', () {
      final rule = InlineRule<String>(
        (value) => false,
        name: 'custom_rule',
      );
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors.first.rule, equals('custom_rule'));
    });

    test('should handle null values', () {
      final rule = InlineRule<String>((value) => value == null);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should catch exceptions in validator', () {
      final rule = InlineRule<String>((value) {
        throw Exception('Validator exception');
      });
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('inline_rule'));
    });

    test('should use custom message on exception', () {
      final rule = InlineRule<String>(
        (value) {
          throw Exception('Validator exception');
        },
        message: 'Custom error message',
      );
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors.first.message, equals('Custom error message'));
    });

    test('should work with complex validators', () {
      final rule = InlineRule<int>(
        (value) => value != null && value > 0 && value < 100,
        message: 'Value must be between 1 and 99',
      );

      var state = ValidationState();
      rule.apply(50, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(150, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with list values', () {
      final rule = InlineRule<List<int>>(
        (value) => value != null && value.length >= 3,
        message: 'List must have at least 3 items',
      );

      var state = ValidationState();
      rule.apply([1, 2, 3], state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply([1, 2], state);
      expect(state.errors.length, equals(1));
    });

    test('should work with map values', () {
      final rule = InlineRule<Map<String, dynamic>>(
        (value) => value != null && value.containsKey('required'),
        message: 'Map must contain required key',
      );

      var state = ValidationState();
      rule.apply(<String, dynamic>{'required': 'value'}, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(<String, dynamic>{'other': 'value'}, state);
      expect(state.errors.length, equals(1));
    });
  });
}
