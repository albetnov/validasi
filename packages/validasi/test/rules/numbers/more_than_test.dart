import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/numbers/more_than.dart';

void main() {
  group('MoreThan', () {
    test('should pass when value is greater than min', () {
      final rule = MoreThan<int>(10);
      final state = ValidationState();

      rule.apply(15, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when value equals min', () {
      final rule = MoreThan<int>(10);
      final state = ValidationState();

      rule.apply(10, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('moreThan'));
      expect(
        state.errors.first.message,
        equals('value must be more than 10'),
      );
    });

    test('should fail when value is less than min', () {
      final rule = MoreThan<int>(10);
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = MoreThan<int>(10, message: 'Too small!');
      final state = ValidationState();

      rule.apply(5, state);

      expect(state.errors.first.message, equals('Too small!'));
    });

    test('should work with negative numbers', () {
      final rule = MoreThan<int>(-10);

      var state = ValidationState();
      rule.apply(-5, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(-15, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with double', () {
      final rule = MoreThan<double>(10.5);

      var state = ValidationState();
      rule.apply(10.6, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(10.5, state);
      expect(state.errors.length, equals(1));
    });

    test('should work with zero', () {
      final rule = MoreThan<int>(0);

      var state = ValidationState();
      rule.apply(1, state);
      expect(state.errors, isEmpty);

      state = ValidationState();
      rule.apply(0, state);
      expect(state.errors.length, equals(1));
    });
  });
}
