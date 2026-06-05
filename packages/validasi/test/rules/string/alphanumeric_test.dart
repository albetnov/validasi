import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/alphanumeric.dart';

void main() {
  group('Alphanumeric (String)', () {
    test('should pass when string contains only letters and digits', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('Hello123', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with only letters', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('Hello', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with only digits', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('12345', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when string contains spaces', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('Hello 123', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Alphanumeric'));
      expect(
        state.errors.first.message,
        equals('Must contain only letters and digits'),
      );
    });

    test('should fail when string contains symbols', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('Hello!', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Alphanumeric(message: 'Alphanumeric only!');
      final state = ValidationState();

      rule.apply('Hello!', state);

      expect(state.errors.first.message, equals('Alphanumeric only!'));
    });

    test('should fail with empty string', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply('', state);

      expect(state.errors.length, equals(1));
    });

    test('should skip null values', () {
      final rule = Alphanumeric();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
