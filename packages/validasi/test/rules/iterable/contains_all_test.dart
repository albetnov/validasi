import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/contains_all.dart';

void main() {
  group('ContainsAll (List)', () {
    test('should pass when list contains all required elements', () {
      final rule = ContainsAll<int>([1, 2]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should pass when list contains exactly the required elements', () {
      final rule = ContainsAll<int>([1, 2, 3]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list is missing a required element', () {
      final rule = ContainsAll<int>([1, 2, 5]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('ContainsAll'));
      expect(
        state.errors.first.message,
        equals('List must contain all required elements'),
      );
    });

    test('should use custom message', () {
      final rule = ContainsAll<int>([5], message: 'Must include all');
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.first.message, equals('Must include all'));
    });

    test('should work with empty required list', () {
      final rule = ContainsAll<int>([]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with empty value list when required is not empty', () {
      final rule = ContainsAll<int>([1]);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with both empty lists', () {
      final rule = ContainsAll<int>([]);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with different element types', () {
      final rule = ContainsAll<String>(['a', 'b']);
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with custom equals', () {
      final rule = ContainsAll<Map<String, int>>(
        [
          {'id': 1},
          {'id': 2},
        ],
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

    test('should fail with custom equals when missing element', () {
      final rule = ContainsAll<Map<String, int>>(
        [
          {'id': 1},
          {'id': 5},
        ],
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
      final rule = ContainsAll<int?>([1, null]);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });
  });
}
