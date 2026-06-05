import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/is_empty.dart';

void main() {
  group('IsEmpty (List)', () {
    test('should pass when list is empty', () {
      final rule = IsEmpty<int>();
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list is not empty', () {
      final rule = IsEmpty<int>();
      final state = ValidationState();

      rule.apply([1], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('IsEmpty'));
      expect(state.errors.first.message, equals('List must be empty'));
    });

    test('should use custom message', () {
      final rule = IsEmpty<int>(message: 'Must be empty');
      final state = ValidationState();

      rule.apply([1, 2], state);

      expect(state.errors.first.message, equals('Must be empty'));
    });

    test('should fail with multiple items', () {
      final rule = IsEmpty<int>();
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with different element types', () {
      final rule = IsEmpty<String>();
      final state = ValidationState();

      rule.apply(<String>[], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with lists containing nulls', () {
      final rule = IsEmpty<int?>();
      final state = ValidationState();

      rule.apply([null], state);

      expect(state.errors.length, equals(1));
    });
  });
}
