import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/has_field_keys.dart';

void main() {
  group('HasFieldKeys', () {
    test('should pass when all keys are present', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c'});
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2, 'c': 3}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when extra keys are present', () {
      final rule = HasFieldKeys<int>({'a', 'b'});
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2, 'c': 3, 'd': 4}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when a key is missing', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c'});
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('hasFieldKeys'));
      expect(state.errors.first.message, contains('Missing required fields'));
      expect(state.errors.first.message, contains('c'));
    });

    test('should fail with multiple missing keys', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c', 'd'});
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, contains('c'));
      expect(state.errors.first.message, contains('d'));
    });

    test('should work with empty key set', () {
      final rule = HasFieldKeys<int>({});
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for null value', () {
      final rule = HasFieldKeys<int>({'a', 'b'});
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should work with different value types', () {
      final rule = HasFieldKeys<String>({'name', 'email'});
      final state = ValidationState();

      rule.apply({'name': 'test', 'email': 'test@test.com'}, state);

      expect(state.errors, isEmpty);
    });

    test('should work with single key', () {
      final rule = HasFieldKeys<dynamic>({'id'});
      final state = ValidationState();

      rule.apply(<String, dynamic>{'id': 123, 'name': 'test'}, state);

      expect(state.errors, isEmpty);
    });

    test('should work with many keys', () {
      final keys = Set<String>.from(List.generate(20, (i) => 'key$i'));
      final rule = HasFieldKeys<int>(keys);
      final map = <String, int>{};
      for (var i = 0; i < 20; i++) {
        map['key$i'] = i;
      }
      final state = ValidationState();

      rule.apply(map, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when many keys are missing', () {
      final rule = HasFieldKeys<int>({'a', 'b', 'c', 'd', 'e'});
      final state = ValidationState();

      rule.apply(<String, int>{}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, contains('a, b, c, d, e'));
    });
  });
}
