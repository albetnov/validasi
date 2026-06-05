import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/contains.dart';

void main() {
  group('Contains (List)', () {
    test('should pass when list contains element', () {
      final rule = Contains<int>(2);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list does not contain element', () {
      final rule = Contains<int>(5);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Contains'));
      expect(state.errors.first.message, equals('List must contain 5'));
    });

    test('should use custom message', () {
      final rule = Contains<int>(5, message: 'Must include 5');
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.first.message, equals('Must include 5'));
    });

    test('should work with empty list', () {
      final rule = Contains<int>(1);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with different element types', () {
      final rule = Contains<String>('b');
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with custom equals', () {
      final rule = Contains<Map<String, int>>(
        {'id': 2},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 3},
      ], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals when not found', () {
      final rule = Contains<Map<String, int>>(
        {'id': 5},
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
      ], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with lists containing nulls', () {
      final rule = Contains<int?>(null);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });
  });
}
