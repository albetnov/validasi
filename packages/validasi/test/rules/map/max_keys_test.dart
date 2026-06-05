import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/max_keys.dart';

void main() {
  group('MaxKeys', () {
    test('should pass when map has exactly maximum keys', () {
      final rule = MaxKeys<String>(3);
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2', 'c': '3'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map has fewer than maximum keys', () {
      final rule = MaxKeys<String>(3);
      final state = ValidationState();

      rule.apply({'a': '1'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when map has more keys than maximum', () {
      final rule = MaxKeys<String>(2);
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2', 'c': '3'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MaxKeys'));
      expect(
          state.errors.first.message, equals('Map must have at most 2 keys'));
    });

    test('should pass when map is empty', () {
      final rule = MaxKeys<String>(1);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when map is non-empty and maximum is zero', () {
      final rule = MaxKeys<String>(0);
      final state = ValidationState();

      rule.apply({'a': '1'}, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when map is empty and maximum is zero', () {
      final rule = MaxKeys<String>(0);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = MaxKeys<String>(2, message: 'Too many keys');
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2', 'c': '3'}, state);

      expect(state.errors.first.message, equals('Too many keys'));
    });

    test('should work with different value types', () {
      final rule = MaxKeys<int>(2);
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2, 'c': 3}, state);

      expect(state.errors.length, equals(1));
    });
  });
}
