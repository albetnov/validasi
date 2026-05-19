import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/max_length.dart';

void main() {
  group('MaxLength (String)', () {
    test('should pass when string length equals maximum', () {
      final rule = MaxLength(5);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should pass when string length is below maximum', () {
      final rule = MaxLength(10);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string length exceeds maximum', () {
      final rule = MaxLength(3);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('MaxLength'));
      expect(
        state.errors.first.message,
        equals('Maximum length is 3 characters'),
      );
    });

    test('should use custom message', () {
      final rule = MaxLength(3, message: 'Too long!');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.message, equals('Too long!'));
    });

    test('should include length in details', () {
      final rule = MaxLength(3);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.details?['length'], equals('3'));
    });

    test('should work with empty string', () {
      final rule = MaxLength(0);
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors, isEmpty);
    });

    test('should fail for non-empty string with zero max', () {
      final rule = MaxLength(0);
      final state = ValidationState();

      rule.apply('a', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with long strings', () {
      final rule = MaxLength(50);
      final state = ValidationState();

      rule.apply('a' * 100, state);

      expect(state.errors.length, equals(1));
    });

    test('should work with unicode characters', () {
      final rule = MaxLength(3);
      final state = ValidationState();

      rule.apply('👋🌍🎉💻', state);

      expect(state.errors.length, equals(1));
    });

    test('should work with whitespace', () {
      final rule = MaxLength(3);
      final state = ValidationState();

      rule.apply('     ', state);

      expect(state.errors.length, equals(1));
    });

    test('should allow max length boundary', () {
      final rule = MaxLength(5);
      final state = ValidationState();

      rule.apply('12345', state);

      expect(state.errors, isEmpty);
    });
  });
}
