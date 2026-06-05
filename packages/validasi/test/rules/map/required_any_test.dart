import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/required_any.dart';

void main() {
  group('RequiredAny', () {
    test('should pass when at least one field is present', () {
      final rule = RequiredAny<String>(['email', 'phone']);
      final state = ValidationState();

      rule.apply({'email': 'test@example.com'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when all fields are present', () {
      final rule = RequiredAny<String>(['email', 'phone']);
      final state = ValidationState();

      rule.apply({'email': 'test@example.com', 'phone': '123'}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when none of the fields are present', () {
      final rule = RequiredAny<String>(['email', 'phone']);
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('RequiredAny'));
      expect(state.errors.first.message, contains('email'));
      expect(state.errors.first.message, contains('phone'));
    });

    test('should fail when map is empty', () {
      final rule = RequiredAny<String>(['email', 'phone']);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when field exists with null value', () {
      final rule = RequiredAny<String?>(['email', 'phone']);
      final state = ValidationState();

      rule.apply({'email': null}, state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule =
          RequiredAny<String>(['email', 'phone'], message: 'Need contact');
      final state = ValidationState();

      rule.apply({'name': 'John'}, state);

      expect(state.errors.first.message, equals('Need contact'));
    });

    test('should work with different value types', () {
      final rule = RequiredAny<int>(['a', 'b']);
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors, isEmpty);
    });
  });
}
