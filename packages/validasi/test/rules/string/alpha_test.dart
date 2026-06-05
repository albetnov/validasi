import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/alpha.dart';

void main() {
  group('Alpha (String)', () {
    test('should pass when string contains only letters', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply('Hello', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string contains digits', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply('Hello123', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Alpha'));
      expect(state.errors.first.message, equals('Must contain only letters'));
    });

    test('should fail when string contains spaces', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply('Hello World', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail when string contains symbols', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply('Hello!', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Alpha(message: 'Letters only!');
      final state = ValidationState();

      rule.apply('123', state);

      expect(state.errors.first.message, equals('Letters only!'));
    });

    test('should fail with empty string', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors.length, equals(1));
    });

    test('should skip null values', () {
      final rule = Alpha();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
