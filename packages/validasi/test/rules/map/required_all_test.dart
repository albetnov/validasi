import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/required_all.dart';

void main() {
  group('RequiredAll', () {
    test('should pass when all fields are present', () {
      final rule = RequiredAll<String>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply({'password': '123', 'passwordConfirm': '123'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when none of the fields are present', () {
      final rule = RequiredAll<String>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = RequiredAll<String>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when some fields are present but not all', () {
      final rule = RequiredAll<String>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply({'password': '123'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('RequiredAll'));
      expect(state.errors.first.message, contains('password'));
      expect(state.errors.first.message, contains('passwordConfirm'));
    });

    test('should pass when field exists with null value', () {
      final rule = RequiredAll<String?>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply({'password': null, 'passwordConfirm': null}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when one field is null and other is missing', () {
      final rule = RequiredAll<String?>(['password', 'passwordConfirm']);
      final state = ValidationState();

      rule.apply({'password': null}, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = RequiredAll<String>(['a', 'b'], message: 'All required');
      final state = ValidationState();

      rule.apply({'a': '1'}, state);

      expect(state.errors.first.message, equals('All required'));
    });

    test('should work with different value types', () {
      final rule = RequiredAll<int>(['a', 'b']);
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors, isEmpty);
    });
  });
}
