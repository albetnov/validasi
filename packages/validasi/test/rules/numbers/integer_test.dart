import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/integer.dart';

void main() {
  group('Integer', () {
    test('should pass for positive integer', () {
      final rule = Integer();
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for negative integer', () {
      final rule = Integer();
      final state = ValidationState();

      rule.apply(-42, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for zero', () {
      final rule = Integer();
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for large integer', () {
      final rule = Integer();
      final state = ValidationState();

      rule.apply(999999999, state);

      expect(state.errors, isEmpty);
    });

    test('should use custom message', () {
      final rule = Integer(message: 'Must be an integer');
      final state = ValidationState();

      rule.apply(42, state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = Integer();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
