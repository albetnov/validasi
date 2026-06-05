import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/contains.dart';

void main() {
  group('Contains (String)', () {
    test('should pass when string contains substring', () {
      final rule = Contains('lo wo');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string does not contain substring', () {
      final rule = Contains('xyz');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Contains'));
      expect(state.errors.first.message, equals('Must contain "xyz"'));
    });

    test('should use custom message', () {
      final rule = Contains('xyz', message: 'Missing!');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.message, equals('Missing!'));
    });

    test('should include substring in details', () {
      final rule = Contains('xyz');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors.first.details?['substring'], equals('xyz'));
    });

    test('should pass for exact match', () {
      final rule = Contains('hello');
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should be case sensitive', () {
      final rule = Contains('WORLD');
      final state = ValidationState();

      rule.apply('hello world', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass with empty substring', () {
      final rule = Contains('');
      final state = ValidationState();

      rule.apply('anything', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Contains('xyz');
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
