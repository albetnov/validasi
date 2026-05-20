import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/having.dart';

void main() {
  group('Having', () {
    test('should have runOnNull set to true', () {
      final rule = Having<String>(['a', 'b', 'c']);

      expect(rule.runOnNull, isTrue);
    });

    test('should pass when value is in valid values', () {
      final rule = Having<String>(['apple', 'banana', 'cherry']);
      final state = ValidationState();

      rule.apply('apple', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value is not in valid values', () {
      final rule = Having<String>(['apple', 'banana', 'cherry']);
      final state = ValidationState();

      rule.apply('orange', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('having'));
      expect(
        state.errors.first.message,
        equals('Value must be one of: apple, banana, cherry'),
      );
    });

    test('should use custom message', () {
      final rule = Having<String>(
        ['apple', 'banana'],
        message: 'Pick from the list',
      );
      final state = ValidationState();

      rule.apply('orange', state);

      expect(state.errors.first.message, equals('Pick from the list'));
    });

    test('should work with integers', () {
      final rule = Having<int>([1, 2, 3, 4, 5]);

      var state = ValidationState();
      rule.apply(3, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with booleans', () {
      final rule = Having<bool>([true]);

      var state = ValidationState();
      rule.apply(true, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(false, state);
      expect(state.errors.length, equals(1));
    });

    test('should fail for null value', () {
      final rule = Having<String>(['apple', 'banana']);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors.length, equals(1));
    });

    test('should work with single valid value', () {
      final rule = Having<String>(['only']);

      var state = ValidationState();
      rule.apply('only', state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply('other', state);
      expect(state.errors.length, equals(1));
    });

    test('should work with empty list of valid values', () {
      final rule = Having<String>([]);
      final state = ValidationState();

      rule.apply('any', state);

      expect(state.errors.length, equals(1));
    });

    test('should be case sensitive for strings', () {
      final rule = Having<String>(['Apple', 'Banana']);
      final state = ValidationState();

      rule.apply('apple', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with many options', () {
      final rule = Having<int>(
        List.generate(100, (i) => i),
      );

      var state = ValidationState();
      rule.apply(50, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(150, state);
      expect(state.errors.length, equals(1));
    });
  });
}
