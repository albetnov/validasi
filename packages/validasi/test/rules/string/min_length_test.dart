import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/min_length.dart';

void main() {
  group('MinLength (String)', () {
    test('should pass when string length equals minimum', () {
      final rule = MinLength(5);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should pass when string length exceeds minimum', () {
      final rule = MinLength(3);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string length is below minimum', () {
      final rule = MinLength(10);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MinLength'));
      expect(
        state.errors.first.message,
        equals('Minimum length is 10 characters'),
      );
    });

    test('should use custom message', () {
      final rule = MinLength(10, message: 'Too short!');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.message, equals('Too short!'));
    });

    test('should include length in details', () {
      final rule = MinLength(10);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.details?['length'], equals('10'));
    });

    test('should work with empty string', () {
      final rule = MinLength(1);
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with zero minimum', () {
      final rule = MinLength(0);
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should work with long strings', () {
      final rule = MinLength(100);
      final state = ValidationState();

      rule.apply('a' * 150, state);

      expect(state.errors, isEmpty);
    });

    test('should work with unicode characters', () {
      final rule = MinLength(5);
      final state = ValidationState();

      rule.apply('👋🌍🎉💻🚀', state);

      expect(state.errors, isEmpty);
    });

    test('should work with whitespace', () {
      final rule = MinLength(5);
      final state = ValidationState();

      rule.apply('     ', state);

      expect(state.errors, isEmpty);
    });
  });
}
