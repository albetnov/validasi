import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/not_contains.dart';

void main() {
  group('NotContains (List)', () {
    test('should pass when list does not contain element', () {
      final rule = NotContains<int>(5);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list contains element', () {
      final rule = NotContains<int>(2);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('NotContains'));
      expect(state.errors.first.message, equals('List must not contain 2'));
    });

    test('should use custom message', () {
      final rule = NotContains<int>(2, message: 'Cannot include 2');
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.first.message, equals('Cannot include 2'));
    });

    test('should work with empty list', () {
      final rule = NotContains<int>(1);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with different element types', () {
      final rule = NotContains<String>('x');
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with custom equals', () {
      final rule = NotContains<Map<String, int>>(
        {'id': 5},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
      ], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals when found', () {
      final rule = NotContains<Map<String, int>>(
        {'id': 2},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 3},
      ], state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with lists containing nulls when checking null', () {
      final rule = NotContains<int?>(null);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors.length, equals(1));
    });
  });
}
