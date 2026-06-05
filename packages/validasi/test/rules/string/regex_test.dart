import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/regex.dart';

void main() {
  group('Regex (String)', () {
    test('should pass when string matches pattern', () {
      final rule = Regex(r'^[a-z]+$');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string does not match pattern', () {
      final rule = Regex(r'^[a-z]+$');
      final state = ValidationState();

      rule.apply('Hello123', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Regex'));
      expect(
          state.errors.first.message, equals('Must match pattern "^[a-z]+\$"'));
    });

    test('should use custom message', () {
      final rule = Regex(r'^[a-z]+$', message: 'Invalid!');
      final state = ValidationState();

      rule.apply('ABC', state);

      expect(state.errors.first.message, equals('Invalid!'));
    });

    test('should include pattern in details', () {
      final rule = Regex(r'^[a-z]+$');
      final state = ValidationState();

      rule.apply('ABC', state);

      expect(state.errors.first.details?['pattern'], equals(r'^[a-z]+$'));
    });

    test('should work with digit patterns', () {
      final rule = Regex(r'^\d{3}-\d{4}$');
      final state = ValidationState();

      rule.apply('123-4567', state);

      expect(state.errors, isEmpty);
    });

    test('should work with email-like patterns', () {
      final rule = Regex(r'^[\w.]+@[\w.]+$');
      final state = ValidationState();

      rule.apply('user@example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Regex(r'^[a-z]+$');
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
