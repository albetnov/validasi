import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/more_than_equal.dart';

void main() {
  group('MoreThanEqual', () {
    test('should pass when value is greater than min', () {
      final rule = MoreThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(15, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when value equals min', () {
      final rule = MoreThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(10, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value is less than min', () {
      final rule = MoreThanEqual<int>(10);
      final state = ValidationState();

      rule.apply(9, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('moreThanEqual'));
      expect(
        state.errors.first.message,
        equals('value must be more than or equal to 10'),
      );
    });

    test('should use custom message', () {
      final rule = MoreThanEqual<int>(10, message: 'Too small!');
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors.first.message, equals('Too small!'));
    });

    test('should work with negative numbers', () {
      final rule = MoreThanEqual<int>(0);

      var state = ValidationState();
      rule.apply(0, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(-5, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = MoreThanEqual<double>(10.5);

      var state = ValidationState();
      rule.apply(10.5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.6, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.4, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = MoreThanEqual<int>(0);

      var state = ValidationState();
      rule.apply(0, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(-1, state);
      expect(state.errors.length, equals(1));
    });
  });
}
