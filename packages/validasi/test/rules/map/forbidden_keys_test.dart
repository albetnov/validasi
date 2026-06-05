import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/forbidden_keys.dart';

void main() {
  group('ForbiddenKeys', () {
    test('should pass when map has no forbidden keys', () {
      final rule = ForbiddenKeys<String>({'password', 'secret'});
      final state = ValidationState();

      rule.apply({'name': 'John', 'email': 'john@example.com'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = ForbiddenKeys<String>({'password', 'secret'});
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when map has forbidden key', () {
      final rule = ForbiddenKeys<String>({'password', 'secret'});
      final state = ValidationState();

      rule.apply({'name': 'John', 'password': '123'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('ForbiddenKeys'));
      expect(state.errors.first.message, contains('password'));
    });

    test('should fail when map has multiple forbidden keys', () {
      final rule = ForbiddenKeys<String>({'password', 'secret'});
      final state = ValidationState();

      rule.apply({'password': '123', 'secret': 'abc'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, contains('password'));
      expect(state.errors.first.message, contains('secret'));
    });

    test('should use custom message', () {
      final rule = ForbiddenKeys<String>({'password'}, message: 'Not allowed');
      final state = ValidationState();

      rule.apply({'password': '123'}, state);

      expect(state.errors.first.message, equals('Not allowed'));
    });

    test('should work with different value types', () {
      final rule = ForbiddenKeys<int>({'x', 'y'});
      final state = ValidationState();

      rule.apply({'x': 1}, state);

      expect(state.errors.length, equals(1));
    });
  });
}
