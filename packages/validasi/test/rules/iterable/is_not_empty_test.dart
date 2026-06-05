import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/is_not_empty.dart';

void main() {
  group('IsNotEmpty (List)', () {
    test('should pass when list is not empty', () {
      final rule = IsNotEmpty<int>();
      final state = ValidationState();

      rule.apply([1], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list is empty', () {
      final rule = IsNotEmpty<int>();
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('IsNotEmpty'));
      expect(state.errors.first.message, equals('List must not be empty'));
    });

    test('should use custom message', () {
      final rule = IsNotEmpty<int>(message: 'Cannot be empty');
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.first.message, equals('Cannot be empty'));
    });

    test('should pass with multiple items', () {
      final rule = IsNotEmpty<int>();
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should work with different element types', () {
      final rule = IsNotEmpty<String>();
      final state = ValidationState();

      rule.apply(['a'], state);

      expect(state.errors, isEmpty);
    });

    test('should pass with lists containing nulls', () {
      final rule = IsNotEmpty<int?>();
      final state = ValidationState();

      rule.apply([null], state);

      expect(state.errors, isEmpty);
    });
  });
}
