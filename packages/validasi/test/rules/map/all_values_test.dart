import 'package:test/test.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/rules/map/all_values.dart';

class _MinLengthRule extends Rule<String> {
  const _MinLengthRule(this.min);
  final int min;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && value.length < min) {
      state.addError(ValidationError(
        rule: 'MinLength',
        message: 'Must be at least $min characters',
      ));
    }
    return value;
  }
}

class _PositiveIntRule extends Rule<int> {
  const _PositiveIntRule();

  @override
  int? apply(int? value, ValidationState state) {
    if (value != null && value <= 0) {
      state.addError(ValidationError(
        rule: 'PositiveInt',
        message: 'Must be positive',
      ));
    }
    return value;
  }
}

void main() {
  group('AllValues', () {
    test('should pass when all values satisfy rules', () {
      final rule = AllValues<String>([const _MinLengthRule(2)]);
      final state = ValidationState();

      rule.apply({'a': 'hello', 'b': 'world'}, state);

      expect(state.errors, isEmpty);
    });

    test('should pass when map is empty', () {
      final rule = AllValues<String>([const _MinLengthRule(2)]);
      final state = ValidationState();

      rule.apply(<String, String>{}, state);

      expect(state.errors, isEmpty);
    });

    test('should fail when a value does not satisfy rules', () {
      final rule = AllValues<String>([const _MinLengthRule(3)]);
      final state = ValidationState();

      rule.apply({'a': 'hello', 'b': 'hi'}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.path, equals(['b']));
    });

    test('should prefix errors with key', () {
      final rule = AllValues<String>([const _MinLengthRule(3)]);
      final state = ValidationState();

      rule.apply({'name': 'Jo'}, state);

      expect(state.errors.first.path, equals(['name']));
    });

    test('should collect errors from multiple values', () {
      final rule = AllValues<String>([const _MinLengthRule(3)]);
      final state = ValidationState();

      rule.apply({'a': 'hi', 'b': 'ok', 'c': 'hello'}, state);

      expect(state.errors.length, equals(2));
    });

    test('should work with multiple rules', () {
      final rule = AllValues<String>([
        const _MinLengthRule(3),
        const _MinLengthRule(5),
      ]);
      final state = ValidationState();

      rule.apply({'a': 'hi'}, state);

      expect(state.errors.length, equals(2));
    });

    test('should work with different value types', () {
      final rule = AllValues<int>([const _PositiveIntRule()]);
      final state = ValidationState();

      rule.apply({'a': 1, 'b': -1}, state);

      expect(state.errors.length, equals(1));
    });
  });
}
