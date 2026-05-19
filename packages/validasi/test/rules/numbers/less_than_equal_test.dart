import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/less_than_equal.dart';

void main() {
  group('LessThanEqual', () {
    test('should pass when value is less than max', () {
      final rule = LessThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when value equals max', () {
      final rule = LessThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(10, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value is greater than max', () {
      final rule = LessThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(11, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('lessThanEqual'));
      expect(
        state.errors.first.message,
        equals('value must be less than or equal to 10'),
      );
    });

    test('should use custom message', () {
      final rule = LessThanEqual<int>(10, message: 'Too big!');
      final state = ValidationState();

      rule.apply(15, state);

      expect(state.errors.first.message, equals('Too big!'));
    });

    test('should work with negative numbers', () {
      final rule = LessThanEqual<int>(0);

      var state = ValidationState();
      rule.apply(-5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(5, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = LessThanEqual<double>(10.5);

      var state = ValidationState();
      rule.apply(10.5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.4, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.6, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = LessThanEqual<int>(0);

      var state = ValidationState();
      rule.apply(0, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(1, state);
      expect(state.errors.length, equals(1));
    });
  });
}
