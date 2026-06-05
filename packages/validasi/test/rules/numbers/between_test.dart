import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/between.dart';

void main() {
  group('Between', () {
    test('should pass for value within range', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for value at min boundary', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(1, state);

      expect(state.errors, isEmpty);
    });

    test('should pass for value at max boundary', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(10, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for value below min', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('between'));
      expect(
        state.errors.first.message,
        equals('value must be between 1 and 10'),
      );
    });

    test('should fail for value above max', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(11, state);

      expect(state.errors.length, equals(1));
    });

    test('should work with doubles', () {
      final rule = Between<double>(1.0, 10.0);
      final state = ValidationState();

      rule.apply(5.5, state);

      expect(state.errors, isEmpty);
    });

    test('should fail for double below min', () {
      final rule = Between<double>(1.0, 10.0);
      final state = ValidationState();

      rule.apply(0.5, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Between<int>(1, 10, message: 'Must be 1-10');
      final state = ValidationState();

      rule.apply(11, state);

      expect(state.errors.first.message, equals('Must be 1-10'));
    });

    test('should skip null values', () {
      final rule = Between<int>(1, 10);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
