import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/starts_with.dart';

void main() {
  group('StartsWith (String)', () {
    test('should pass when string starts with prefix', () {
      final rule = StartsWith('hello');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string does not start with prefix', () {
      final rule = StartsWith('hello');
      final state = ValidationState();

      rule.apply('world hello', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('StartsWith'));
      expect(state.errors.first.message, equals('Must start with "hello"'));
    });

    test('should use custom message', () {
      final rule = StartsWith('hello', message: 'Wrong start!');
      final state = ValidationState();

      rule.apply('world', state);

      expect(state.errors.first.message, equals('Wrong start!'));
    });

    test('should include prefix in details', () {
      final rule = StartsWith('hello');
      final state = ValidationState();

      rule.apply('world', state);

      expect(state.errors.first.details?['prefix'], equals('hello'));
    });

    test('should pass for exact match', () {
      final rule = StartsWith('hello');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should be case sensitive', () {
      final rule = StartsWith('Hello');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with empty prefix', () {
      final rule = StartsWith('');
      final state = ValidationState();

      rule.apply('anything', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = StartsWith('hello');
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
