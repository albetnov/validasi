import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/exact_length.dart';

void main() {
  group('ExactLength (List)', () {
    test('should pass when list length equals exact length', () {
      final rule = ExactLength<int>(3);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list length is below exact length', () {
      final rule = ExactLength<int>(5);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('ExactLength'));
      expect(
        state.errors.first.message,
        equals('List must have exactly 5 items'),
      );
    });

    test('should fail when list length exceeds exact length', () {
      final rule = ExactLength<int>(2);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = ExactLength<int>(3, message: 'Must be exactly 3');
      final state = ValidationState();

      rule.apply([1, 2], state);

      expect(state.errors.first.message, equals('Must be exactly 3'));
    });

    test('should work with empty list and zero length', () {
      final rule = ExactLength<int>(0);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with empty list when length is non-zero', () {
      final rule = ExactLength<int>(1);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with different element types', () {
      final rule = ExactLength<String>(2);
      final state = ValidationState();

      rule.apply(['a', 'b'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with lists containing nulls', () {
      final rule = ExactLength<int?>(3);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });
  });
}
