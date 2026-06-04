import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/url.dart';

void main() {
  group('Url (String)', () {
    test('should pass with valid http URL', () {
      final rule = Url();
      final state = ValidationState();

      rule.apply('http://example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with valid https URL', () {
      final rule = Url();
      final state = ValidationState();

      rule.apply('https://example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with URL with path and query', () {
      final rule = Url();
      final state = ValidationState();

      rule.apply('https://example.com/path?query=value', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with no scheme when required', () {
      final rule = Url(requireScheme: true);
      final state = ValidationState();

      rule.apply('example.com', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Url'));
      expect(state.errors.first.message, equals('Must have a scheme'));
    });

    test('should pass with no scheme when not required', () {
      final rule = Url(requireScheme: false, requireHost: false);
      final state = ValidationState();

      rule.apply('example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with no host when required', () {
      final rule = Url(requireHost: true);
      final state = ValidationState();

      rule.apply('http://', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Must have a host'));
    });

    test('should fail with http when https only', () {
      final rule = Url(httpsOnly: true);
      final state = ValidationState();

      rule.apply('http://example.com', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.message, equals('Must use HTTPS scheme'));
    });

    test('should pass with https when https only', () {
      final rule = Url(httpsOnly: true);
      final state = ValidationState();

      rule.apply('https://example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = Url(message: 'Invalid URL!');
      final state = ValidationState();

      rule.apply('not a url', state);

      expect(state.errors.first.message, equals('Invalid URL!'));
    });

    test('should pass with ftp scheme', () {
      final rule = Url();
      final state = ValidationState();

      rule.apply('ftp://files.example.com', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Url();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
