import 'package:test/test.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/rules/any_of.dart';

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

class _MaxLengthRule extends Rule<String> {
  const _MaxLengthRule(this.max);
  final int max;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && value.length > max) {
      state.addError(ValidationError(
        rule: 'MaxLength',
        message: 'Must be at most $max characters',
      ));
    }
    return value;
  }
}

class _StartsWithRule extends Rule<String> {
  const _StartsWithRule(this.prefix);
  final String prefix;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !value.startsWith(prefix)) {
      state.addError(ValidationError(
        rule: 'StartsWith',
        message: 'Must start with $prefix',
      ));
    }
    return value;
  }
}

class _GreaterThanRule extends Rule<int> {
  const _GreaterThanRule(this.threshold);
  final int threshold;

  @override
  int? apply(int? value, ValidationState state) {
    if (value != null && value <= threshold) {
      state.addError(ValidationError(
        rule: 'GreaterThan',
        message: 'Must be greater than $threshold',
      ));
    }
    return value;
  }
}

class _LessThanRule extends Rule<int> {
  const _LessThanRule(this.threshold);
  final int threshold;

  @override
  int? apply(int? value, ValidationState state) {
    if (value != null && value >= threshold) {
      state.addError(ValidationError(
        rule: 'LessThan',
        message: 'Must be less than $threshold',
      ));
    }
    return value;
  }
}

void main() {
  group('AnyOf', () {
    test('should pass when first rule set passes', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(5)],
        [const _StartsWithRule('test')],
      ]);
      final state = ValidationState();

      rule.apply('hello', state);

      expect(state.errors, isEmpty);
    });

    test('should pass when second rule set passes', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(10)],
        [const _StartsWithRule('test')],
      ]);
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should pass when multiple rule sets pass', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(3)],
        [const _StartsWithRule('te')],
      ]);
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should fail when no rule sets pass', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(10)],
        [const _StartsWithRule('test')],
      ]);
      final state = ValidationState();

      rule.apply('hi', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('AnyOf'));
      expect(
        state.errors.first.message,
        equals('Value must satisfy at least one rule set'),
      );
    });

    test('should use custom message', () {
      final rule = AnyOf<String>(
        [
          [const _MinLengthRule(10)],
        ],
        message: 'Must be long or start with test',
      );
      final state = ValidationState();

      rule.apply('hi', state);

      expect(state.errors.first.message,
          equals('Must be long or start with test'));
    });

    test('should work with multiple rules in a set', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(3), const _MaxLengthRule(5)],
        [const _StartsWithRule('test')],
      ]);
      final state = ValidationState();

      rule.apply('hi', state);

      expect(state.errors.length, equals(1));
    });

    test('should pass when complex rule set passes', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(3), const _MaxLengthRule(5)],
        [const _StartsWithRule('test')],
      ]);
      final state = ValidationState();

      rule.apply('test', state);

      expect(state.errors, isEmpty);
    });

    test('should skip null values', () {
      final rule = AnyOf<String>([
        [const _MinLengthRule(5)],
      ]);
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });

    test('should work with different types', () {
      final rule = AnyOf<int>([
        [const _GreaterThanRule(100)],
        [const _LessThanRule(0)],
      ]);
      final state = ValidationState();

      rule.apply(150, state);

      expect(state.errors, isEmpty);
    });

    test('should work with empty rule sets', () {
      final rule = AnyOf<String>([
        [],
      ]);
      final state = ValidationState();

      rule.apply('anything', state);

      expect(state.errors, isEmpty);
    });
  });
}
