import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/less_than.dart';

void main() {
  group('LessThan', () {
    test('should pass when value is less than max', () {
      final rule = LessThan<int>(10);
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value equals max', () {
      final rule = LessThan<int>(10);
      final state = ValidationState();

      rule.apply(10, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('lessThan'));
      expect(state.errors.first.message, equals('value must be less than 10'));
    });

    test('should fail when value is greater than max', () {
      final rule = LessThan<int>(10);
      final state = ValidationState();

      rule.apply(15, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = LessThan<int>(10, message: 'Too big!');
      final state = ValidationState();

      rule.apply(15, state);

      expect(state.errors.first.message, equals('Too big!'));
    });

    test('should work with negative numbers', () {
      final rule = LessThan<int>(0);

      var state = ValidationState();
      rule.apply(-5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(5, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = LessThan<double>(10.5);

      var state = ValidationState();
      rule.apply(10.4, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.5, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = LessThan<int>(1);
      final state = ValidationState();

      rule.apply(0, state);

      expect(state.errors, isEmpty);
    });

    test('should work with very large numbers', () {
      final rule = LessThan<int>(1000000);
      final state = ValidationState();

      rule.apply(999999, state);

      expect(state.errors, isEmpty);
    });

    test('should work with decimal precision', () {
      final rule = LessThan<double>(1.001);
      final state = ValidationState();

      rule.apply(1.0, state);

      expect(state.errors, isEmpty);
    });
  });
}
