import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/one_of.dart';

void main() {
  group('OneOf', () {
    test('should pass when value is in options', () {
      final rule = OneOf(['apple', 'banana', 'cherry']);
      final state = ValidationState();

      rule.apply('apple', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value is not in options', () {
      final rule = OneOf(['apple', 'banana', 'cherry']);
      final state = ValidationState();

      rule.apply('orange', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('OneOf'));
      expect(
        state.errors.first.message,
        equals('Value must be one of: apple, banana, cherry'),
      );
    });

    test('should use custom message', () {
      final rule = OneOf(['a', 'b'], message: 'Pick a or b');
      final state = ValidationState();

      rule.apply('c', state);

      expect(state.errors.first.message, equals('Pick a or b'));
    });

    test('should include options in details', () {
      final rule = OneOf(['a', 'b', 'c']);
      final state = ValidationState();

      rule.apply('d', state);

      expect(state.errors.first.details?['options'], equals('a, b, c'));
    });

    test('should work with single option', () {
      final rule = OneOf(['only']);

      var state = ValidationState();
      rule.apply('only', state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply('other', state);
      expect(state.errors.length, equals(1));
    });

    test('should work with empty options list', () {
      final rule = OneOf([]);
      final state = ValidationState();

      rule.apply('any', state);

      expect(state.errors.length, equals(1));
    });

    test('should be case sensitive', () {
      final rule = OneOf(['Apple', 'Banana']);
      final state = ValidationState();

      rule.apply('apple', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with empty string option', () {
      final rule = OneOf(['', 'a', 'b']);
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should work with many options', () {
      final rule = OneOf(List.generate(100, (i) => 'option$i'));

      var state = ValidationState();
      rule.apply('option50', state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply('invalid', state);
      expect(state.errors.length, equals(1));
    });

    test('should work with special characters', () {
      final rule = OneOf(['@', '#', '\$']);
      final state = ValidationState();

      rule.apply('@', state);

      expect(state.errors, isEmpty);
    });

    test('should work with whitespace strings', () {
      final rule = OneOf([' ', '\t', '\n']);
      final state = ValidationState();

      rule.apply(' ', state);

      expect(state.errors, isEmpty);
    });
  });
}
