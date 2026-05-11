import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/old_rules/iterable/foreach.dart';
import 'package:validasi/src/old_rules/required.dart';

void main() {
  group('ForEach', () {
    test('should validate all items successfully', () {
      final itemSchema = ValidasiEngine<int, int>();
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1, 2, 3]);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should collect errors from failing items', () {
      final itemSchema = ValidasiEngine<int, int>(
        rules: [
          _TestRule<int>(shouldFail: (value) => value! > 5),
        ],
      );
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1, 10, 3, 15]);

      rule.apply(context);

      expect(context.errors.length, equals(2));
    });

    test('should prefix errors with item index', () {
      final itemSchema = ValidasiEngine<int, int>(
        rules: [
          _TestRule<int>(
            shouldFail: (value) => value! > 5,
            ruleName: 'TooLarge',
          ),
        ],
      );
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1, 10, 3]);

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.path, equals(['[1]']));
    });

    test('should work with empty list', () {
      final itemSchema = ValidasiEngine<int, int>();
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: []);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with complex item validation', () {
      final itemSchema = ValidasiEngine<String, String>(
        rules: [Required<String>()],
      );
      final rule = ForEach<String>(itemSchema);
      final context = ValidationContext<List<String>>(
        value: ['a', 'b', 'c'],
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should validate nested structures', () {
      final itemSchema = ValidasiEngine<Map<String, int>, Map<String, int>>();
      final rule = ForEach<Map<String, int>>(itemSchema);
      final context = ValidationContext<List<Map<String, int>>>(
        value: [
          {'a': 1},
          {'b': 2}
        ],
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should collect multiple errors per item', () {
      final itemSchema = ValidasiEngine<int, int>(
        rules: [
          _TestRule<int>(shouldFail: (value) => true, ruleName: 'Error1'),
          _TestRule<int>(shouldFail: (value) => true, ruleName: 'Error2'),
        ],
      );
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1]);

      rule.apply(context);

      expect(context.errors.length, equals(2));
      expect(context.errors[0].rule, equals('Error1'));
      expect(context.errors[1].rule, equals('Error2'));
    });

    test('should preserve error path from nested validation', () {
      final itemSchema = ValidasiEngine<int, int>(
        rules: [
          _TestRule<int>(shouldFail: (value) => true, ruleName: 'ItemError'),
        ],
      );
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1, 2, 3]);

      rule.apply(context);

      expect(context.errors[0].path, equals(['[0]']));
      expect(context.errors[1].path, equals(['[1]']));
      expect(context.errors[2].path, equals(['[2]']));
    });

    test('should work with nullable items', () {
      final itemSchema = ValidasiEngine<int?, int?>();
      final rule = ForEach<int?>(itemSchema);
      final context = ValidationContext<List<int?>>(value: [1, null, 3]);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should validate all items even if early ones fail', () {
      final itemSchema = ValidasiEngine<int, int>(
        rules: [
          _TestRule<int>(shouldFail: (value) => value! > 2),
        ],
      );
      final rule = ForEach<int>(itemSchema);
      final context = ValidationContext<List<int>>(value: [1, 5, 2, 8, 3, 10]);

      rule.apply(context);

      expect(
          context.errors.length, equals(4)); // indices 1, 3, 4, 5 (values > 2)
      expect(context.errors[0].path, equals(['[1]']));
      expect(context.errors[1].path, equals(['[3]']));
      expect(context.errors[2].path, equals(['[4]']));
      expect(context.errors[3].path, equals(['[5]']));
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
  void apply(ValidationContext<T> context) {
    if (shouldFail(context.value)) {
      context.addError(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }
  }
}
