import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/positive.dart';

void main() {
  group('Positive', () {
    test('should pass for positive integer', () {
      final rule = Positive<int>();
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for positive double', () {
      final rule = Positive<double>();
      final state = ValidationState();

      rule.apply(3.14, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for zero', () {
      final rule = Positive<int>();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('positive'));
      expect(state.errors.first.message, equals('value must be positive'));
    });

    test('should fail for negative number', () {
      final rule = Positive<int>();
      final state = ValidationState();

      rule.apply(-1, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Positive<int>(message: 'Must be > 0');
      final state = ValidationState();

      rule.apply(-1, state);

      expect(state.errors.first.message, equals('Must be > 0'));
    });

    test('should skip null values', () {
      final rule = Positive<int>();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
