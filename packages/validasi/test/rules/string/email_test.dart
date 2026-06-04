import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/email.dart';

void main() {
  group('Email (String)', () {
    test('should pass with valid email', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user@example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with email with subdomain', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user@mail.example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with email with plus sign', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user+tag@example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with email with dots in local part', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('first.last@example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with no @ symbol', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('userexample.com', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Email'));
      expect(state.errors.first.message, equals('Must be a valid email address'));
    });

    test('should fail with multiple @ symbols', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user@@example.com', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with empty local part', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('@example.com', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with empty domain', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user@', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with consecutive dots in local part', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user..name@example.com', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with dot at start of local part', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('.user@example.com', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with dot at end of local part', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user.@example.com', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with top level domain by default', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply('user@localhost', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with top level domain when allowed', () {
      final rule = Email(allowTopLevelDomain: true);
      final state = ValidationState();

      rule.apply('user@localhost', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when domain not in allowed list', () {
      final rule = Email(domains: ['gmail.com', 'yahoo.com']);
      final state = ValidationState();

      rule.apply('user@example.com', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Email'));
      expect(
        state.errors.first.message,
        equals('Email domain must be one of: gmail.com, yahoo.com'),
      );
    });

    test('should pass when domain in allowed list', () {
      final rule = Email(domains: ['gmail.com', 'yahoo.com']);
      final state = ValidationState();

      rule.apply('user@gmail.com', state);

      expect(state.errors, isEmpty);
    });

    test('should be case insensitive for domain check', () {
      final rule = Email(domains: ['gmail.com']);
      final state = ValidationState();

      rule.apply('user@GMAIL.COM', state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = Email(message: 'Invalid email!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid email!'));
    });

    test('should include domains in details when restricted', () {
      final rule = Email(domains: ['gmail.com']);
      final state = ValidationState();

      rule.apply('user@example.com', state);

      expect(state.errors.first.details?['domains'], equals('gmail.com'));
    });

    test('should skip null values', () {
      final rule = Email();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
