import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/iterable/min_length.dart';

void main() {
  group('MinLength (List)', () {
    test('should pass when list length equals minimum', () {
      final rule = MinLength<int>(3);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should pass when list length exceeds minimum', () {
      final rule = MinLength<int>(2);
      final state = ValidationState();

      rule.apply([1, 2, 3, 4], state);

      expect(state.errors, isEmpty);
    });

    test('should fail when list length is below minimum', () {
      final rule = MinLength<int>(5);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MinLength'));
      expect(
        state.errors.first.message,
        equals('List must have at least 5 items'),
      );
    });

    test('should use custom message', () {
      final rule = MinLength<int>(5, message: 'Need more items');
      final state = ValidationState();

      rule.apply([1, 2], state);

      expect(state.errors.first.message, equals('Need more items'));
    });

    test('should work with empty list', () {
      final rule = MinLength<int>(1);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors.length, equals(1));
    });

    test('should work with zero minimum', () {
      final rule = MinLength<int>(0);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with different element types', () {
      final rule = MinLength<String>(2);
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should work with large lists', () {
      final rule = MinLength<int>(100);
      final state = ValidationState();

      rule.apply(List.generate(150, (i) => i), state);

      expect(state.errors, isEmpty);
    });

    test('should work with lists containing nulls', () {
      final rule = MinLength<int?>(3);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });
  });
}
