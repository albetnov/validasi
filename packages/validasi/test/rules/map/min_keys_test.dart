import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/min_keys.dart';

void main() {
  group('MinKeys', () {
    test('should pass when map has exactly minimum keys', () {
      final rule = MinKeys<String>(2);
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map has more than minimum keys', () {
      final rule = MinKeys<String>(2);
      final state = ValidationState();

      rule.apply({'a': '1', 'b': '2', 'c': '3'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when map has fewer keys than minimum', () {
      final rule = MinKeys<String>(3);
      final state = ValidationState();

      rule.apply({'a': '1'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MinKeys'));
      expect(
          state.errors.first.message, equals('Map must have at least 3 keys'));
    });

    test('should fail when map is empty and minimum is greater than zero', () {
      final rule = MinKeys<String>(1);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when map is empty and minimum is zero', () {
      final rule = MinKeys<String>(0);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = MinKeys<String>(3, message: 'Need more keys');
      final state = ValidationState();

      rule.apply({'a': '1'}, state);

      expect(state.errors.first.message, equals('Need more keys'));
    });

    test('should work with different value types', () {
      final rule = MinKeys<int>(2);
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors.length, equals(1));
    });
  });
}
