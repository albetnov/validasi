import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/numeric.dart';

void main() {
  group('Numeric (String)', () {
    test('should pass when string contains only digits', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('12345', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string contains letters', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('123abc', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Numeric'));
      expect(state.errors.first.message, equals('Must contain only digits'));
    });

    test('should fail when string contains spaces', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('123 456', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail when string contains symbols', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('123.45', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Numeric(message: 'Digits only!');
      final state = ValidationState();

      rule.apply('abc', state);

      expect(state.errors.first.message, equals('Digits only!'));
    });

    test('should fail with empty string', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with single digit', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply('0', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Numeric();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
