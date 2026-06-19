import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/unique.dart';

void main() {
  group('Unique (List)', () {
    test('should pass when all elements are unique', () {
      final rule = Unique<int>();
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when duplicates exist', () {
      final rule = Unique<int>();
      final state = ValidationState();

      rule.apply([1, 2, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Unique'));
      expect(
        state.errors.first.message,
        equals('List must contain only unique items'),
      );
    });

    test('should use custom message', () {
      final rule = Unique<int>(message: 'No duplicates allowed');
      final state = ValidationState();

      rule.apply([1, 1], state);

      expect(state.errors.first.message, equals('No duplicates allowed'));
    });

    test('should work with empty list', () {
      final rule = Unique<int>();
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with single element', () {
      final rule = Unique<int>();
      final state = ValidationState();

      rule.apply([1], state);

      expect(state.errors, isEmpty);
    });

    test('should work with different element types', () {
      final rule = Unique<String>();
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with duplicate strings', () {
      final rule = Unique<String>();
      final state = ValidationState();

      rule.apply(['a', 'b', 'a'], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with custom equals and hasher', () {
      final rule = Unique<Map<String, int>>(
        equals: (a, b) => a['id'] == b['id'],
        hasher: (m) => m['id']?.hashCode ?? 0,
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 3},
      ], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with custom equals and hasher when duplicates exist', () {
      final rule = Unique<Map<String, int>>(
        equals: (a, b) => a['id'] == b['id'],
        hasher: (m) => m['id']?.hashCode ?? 0,
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 1},
      ], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with custom equals (fallback without hashCode)', () {
      final rule = Unique<Map<String, int>>(
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

    test('should fail with custom equals (fallback without hashCode)', () {
      final rule = Unique<Map<String, int>>(
        equals: (a, b) => a['id'] == b['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 1},
      ], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with keySelector', () {
      final rule = Unique<Map<String, int>>(
        keySelector: (m) => m['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 3},
      ], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with keySelector when duplicates exist', () {
      final rule = Unique<Map<String, int>>(
        keySelector: (m) => m['id'],
      );
      final state = ValidationState();

      rule.apply([
        {'id': 1},
        {'id': 2},
        {'id': 1},
      ], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with keySelector on simple types', () {
      final rule = Unique<String>(
        keySelector: (s) => s.length,
      );
      final state = ValidationState();

      rule.apply(['a', 'bb', 'ccc'], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with keySelector on simple types when duplicates exist',
        () {
      final rule = Unique<String>(
        keySelector: (s) => s.length,
      );
      final state = ValidationState();

      rule.apply(['a', 'bb', 'c'], state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with duplicate nulls', () {
      final rule = Unique<int?>();
      final state = ValidationState();

      rule.apply([1, null, null], state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with single null', () {
      final rule = Unique<int?>();
      final state = ValidationState();

      rule.apply([1, null, 2], state);

      expect(state.errors, isEmpty);
    });

    test('should handle null value', () {
      final rule = Unique<int>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should work with keySelector and null elements', () {
      final rule = Unique<int?>(
        keySelector: (v) => v ?? -1,
      );
      final state = ValidationState();

      rule.apply([1, null, 2], state);

      expect(state.errors, isEmpty);
    });
  });
}
