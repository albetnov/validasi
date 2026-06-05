import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/required_one_of.dart';

void main() {
  group('RequiredOneOf', () {
    test('should pass when exactly one field is present', () {
      final rule = RequiredOneOf<String>(['name', 'username']);
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when none of the fields are present', () {
      final rule = RequiredOneOf<String>(['name', 'username']);
      final state = ValidationState();

      rule.apply({'email': 'test@example.com'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('RequiredOneOf'));
      expect(state.errors.first.message, contains('Exactly one'));
    });

    test('should fail when more than one field is present', () {
      final rule = RequiredOneOf<String>(['name', 'username']);
      final state = ValidationState();

      rule.apply({'name': 'John', 'username': 'john123'}, state);

      expect(state.errors.length, equals(1));
    });

    test('should fail when map is empty', () {
      final rule = RequiredOneOf<String>(['name', 'username']);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when field exists with null value', () {
      final rule = RequiredOneOf<String?>(['name', 'username']);
      final state = ValidationState();

      rule.apply({'name': null}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when all fields exist with null values', () {
      final rule = RequiredOneOf<String?>(['name', 'username']);
      final state = ValidationState();

      rule.apply({'name': null, 'username': null}, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule =
          RequiredOneOf<String>(['name', 'username'], message: 'Pick one');
      final state = ValidationState();

      rule.apply({'name': 'John', 'username': 'john123'}, state);

      expect(state.errors.first.message, equals('Pick one'));
    });

    test('should work with different value types', () {
      final rule = RequiredOneOf<int>(['a', 'b']);
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors, isEmpty);
    });
  });
}
