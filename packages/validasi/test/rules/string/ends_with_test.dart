import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/ends_with.dart';

void main() {
  group('EndsWith (String)', () {
    test('should pass when string ends with suffix', () {
      final rule = EndsWith('world');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string does not end with suffix', () {
      final rule = EndsWith('world');
      final state = ValidationState();

      rule.apply('world hello', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('EndsWith'));
      expect(state.errors.first.message, equals('Must end with "world"'));
    });

    test('should use custom message', () {
      final rule = EndsWith('world', message: 'Wrong end!');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.message, equals('Wrong end!'));
    });

    test('should include suffix in details', () {
      final rule = EndsWith('world');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.details?['suffix'], equals('world'));
    });

    test('should pass for exact match', () {
      final rule = EndsWith('hello');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should be case sensitive', () {
      final rule = EndsWith('World');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with empty suffix', () {
      final rule = EndsWith('');
      final state = ValidationState();

      rule.apply('anything', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = EndsWith('world');
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
