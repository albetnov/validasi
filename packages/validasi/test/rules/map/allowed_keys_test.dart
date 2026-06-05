import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/allowed_keys.dart';

void main() {
  group('AllowedKeys', () {
    test('should pass when map has only allowed keys', () {
      final rule = AllowedKeys<String>({'name', 'email'});
      final state = ValidationState();

      rule.apply({'name': 'John', 'email': 'john@example.com'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = AllowedKeys<String>({'name', 'email'});
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map has subset of allowed keys', () {
      final rule = AllowedKeys<String>({'name', 'email', 'phone'});
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when map has extra keys', () {
      final rule = AllowedKeys<String>({'name', 'email'});
      final state = ValidationState();

      rule.apply(
          {'name': 'John', 'email': 'john@example.com', 'age': '30'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('AllowedKeys'));
      expect(state.errors.first.message, contains('age'));
    });

    test('should use custom message', () {
      final rule = AllowedKeys<String>({'name'}, message: 'Invalid fields');
      final state = ValidationState();

      rule.apply({'name': 'John', 'age': '30'}, state);

      expect(state.errors.first.message, equals('Invalid fields'));
    });

    test('should work with different value types', () {
      final rule = AllowedKeys<int>({'a', 'b'});
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2, 'c': 3}, state);

      expect(state.errors.length, equals(1));
    });
  });
}
