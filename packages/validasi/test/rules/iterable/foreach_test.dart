import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/rules/iterable/foreach.dart';
import 'package:validasi/src/rules/required.dart';

void main() {
  group('ForEach', () {
    test('should validate all items successfully', () {
      final rule = ForEach<int>([]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should collect errors from failing items', () {
      final rule = ForEach<int>([
        _TestRule<int>(shouldFail: (value) => value! > 5),
      ]);
      final state = ValidationState();

      rule.apply([1, 10, 3, 15], state);

      expect(state.errors.length, equals(2));
    });

    test('should prefix errors with item index', () {
      final rule = ForEach<int>([
        _TestRule<int>(
          shouldFail: (value) => value! > 5,
          ruleName: 'TooLarge',
        ),
      ]);
      final state = ValidationState();

      rule.apply([1, 10, 3], state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.path, equals(['[1]']));
    });

    test('should work with empty list', () {
      final rule = ForEach<int>([]);
      final state = ValidationState();

      rule.apply(<int>[], state);

      expect(state.errors, isEmpty);
    });

    test('should work with complex item validation', () {
      final rule = ForEach<String>([
        Required<String>(),
      ]);
      final state = ValidationState();

      rule.apply(['a', 'b', 'c'], state);

      expect(state.errors, isEmpty);
    });

    test('should validate nested structures', () {
      final rule = ForEach<Map<String, int>>([]);
      final state = ValidationState();

      rule.apply([
        {'a': 1},
        {'b': 2}
      ], state);

      expect(state.errors, isEmpty);
    });

    test('should collect multiple errors per item', () {
      final rule = ForEach<int>([
        _TestRule<int>(shouldFail: (value) => true, ruleName: 'Error1'),
        _TestRule<int>(shouldFail: (value) => true, ruleName: 'Error2'),
      ]);
      final state = ValidationState();

      rule.apply([1], state);

      expect(state.errors.length, equals(2));
      expect(state.errors[0].rule, equals('Error1'));
      expect(state.errors[1].rule, equals('Error2'));
    });

    test('should preserve error path from nested validation', () {
      final rule = ForEach<int>([
        _TestRule<int>(shouldFail: (value) => true, ruleName: 'ItemError'),
      ]);
      final state = ValidationState();

      rule.apply([1, 2, 3], state);

      expect(state.errors[0].path, equals(['[0]']));
      expect(state.errors[1].path, equals(['[1]']));
      expect(state.errors[2].path, equals(['[2]']));
    });

    test('should work with nullable items', () {
      final rule = ForEach<int?>([]);
      final state = ValidationState();

      rule.apply([1, null, 3], state);

      expect(state.errors, isEmpty);
    });

    test('should validate all items even if early ones fail', () {
      final rule = ForEach<int>([
        _TestRule<int>(shouldFail: (value) => value! > 2),
      ]);
      final state = ValidationState();

      rule.apply([1, 5, 2, 8, 3, 10], state);

      expect(state.errors.length, equals(4)); // indices 1, 3, 4, 5 (values > 2)
      expect(state.errors[0].path, equals(['[1]']));
      expect(state.errors[1].path, equals(['[3]']));
      expect(state.errors[2].path, equals(['[4]']));
      expect(state.errors[3].path, equals(['[5]']));
    });
  });
}

class _TestRule<T> extends Rule<T> {
  _TestRule({
    required this.shouldFail,
    this.ruleName = 'TestRule',
  });

  final bool Function(T? value) shouldFail;
  final String ruleName;

  @override
  T? apply(T? value, ValidationState state) {
    if (shouldFail(value)) {
      state.errors.add(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }
    return value;
  }
}
