import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/case.dart';

void main() {
  group('Lowercase (String)', () {
    test('should pass when string is lowercase', () {
      final rule = Lowercase();
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string contains uppercase', () {
      final rule = Lowercase();
      final state = ValidationState();

      rule.apply('Hello World', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Lowercase'));
      expect(state.errors.first.message, equals('Must be lowercase'));
    });

    test('should use custom message', () {
      final rule = Lowercase(message: 'Use lowercase!');
      final state = ValidationState();

      rule.apply('HELLO', state);

      expect(state.errors.first.message, equals('Use lowercase!'));
    });

    test('should pass with empty string', () {
      final rule = Lowercase();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with numbers and symbols', () {
      final rule = Lowercase();
      final state = ValidationState();

      rule.apply('hello 123 !@#', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Lowercase();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });

  group('Uppercase (String)', () {
    test('should pass when string is uppercase', () {
      final rule = Uppercase();
      final state = ValidationState();

      rule.apply('HELLO WORLD', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string contains lowercase', () {
      final rule = Uppercase();
      final state = ValidationState();

      rule.apply('Hello World', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Uppercase'));
      expect(state.errors.first.message, equals('Must be uppercase'));
    });

    test('should use custom message', () {
      final rule = Uppercase(message: 'Use uppercase!');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.message, equals('Use uppercase!'));
    });

    test('should pass with empty string', () {
      final rule = Uppercase();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with numbers and symbols', () {
      final rule = Uppercase();
      final state = ValidationState();

      rule.apply('HELLO 123 !@#', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Uppercase();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
