import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/max_length.dart';

void main() {
  group('MaxLength (List)', () {
    test('should pass when list length equals maximum', () {
      final rule = MaxLength<int>(3);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should pass when list length is below maximum', () {
      final rule = MaxLength<int>(5);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list length exceeds maximum', () {
      final rule = MaxLength<int>(2);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MaxLength'));
      expect(
        state.errors.first.message,
        equals('List must have at most 2 items'),
      );
    });

    test('should use custom message', () {
      final rule = MaxLength<int>(2, message: 'Too many items');
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.first.message, equals('Too many items'));
    });

    test('should work with empty list', () {
      final rule = MaxLength<int>(1);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with zero maximum', () {
      final rule = MaxLength<int>(0);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should fail with zero maximum and non-empty list', () {
      final rule = MaxLength<int>(0);
      final state = ValidationState();

      rule.apply([1], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with different element types', () {
      final rule = MaxLength<String>(2);
      final state = ValidationState();

      rule.apply(['a', 'b'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with lists containing nulls', () {
      final rule = MaxLength<int?>(3);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });
  });
}
