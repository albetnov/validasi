import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/rules/map/has_fields.dart';

void main() {
  group('HasFields', () {
    test('should validate all fields successfully', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(),
        'b': ValidasiEngine<int>(),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should collect errors from failing field validations', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true)],
        ),
        'b': ValidasiEngine<int>(),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
    });

    test('should prefix errors with field name', () {
      final rule = HasFields<int>({
        'age': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'TooYoung')],
        ),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'age': 15},
      );

      rule.apply(context);

      expect(context.errors.length, equals(1));
      expect(context.errors.first.path, equals(['age']));
      expect(context.errors.first.rule, equals('TooYoung'));
    });

    test('should work with empty fields map', () {
      final rule = HasFields<int>({});
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should validate missing fields as null', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(),
        'b': ValidasiEngine<int>(),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1},
      );

      rule.apply(context);

      // Missing field 'b' is validated as null
      expect(context.errors, isEmpty);
    });

    test('should collect errors from multiple fields', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'Error1')],
        ),
        'b': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'Error2')],
        ),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors.length, equals(2));
      expect(context.errors[0].path, equals(['a']));
      expect(context.errors[1].path, equals(['b']));
    });

    test('should collect multiple errors per field', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(
          rules: [
            _TestRule<int>(shouldFail: true, ruleName: 'Error1'),
            _TestRule<int>(shouldFail: true, ruleName: 'Error2'),
          ],
        ),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1},
      );

      rule.apply(context);

      expect(context.errors.length, equals(2));
      expect(context.errors[0].path, equals(['a']));
      expect(context.errors[0].rule, equals('Error1'));
      expect(context.errors[1].path, equals(['a']));
      expect(context.errors[1].rule, equals('Error2'));
    });

    test('should work with different value types', () {
      final rule = HasFields<dynamic>({
        'name': ValidasiEngine<String>(),
        'age': ValidasiEngine<int>(),
      });
      final context = ValidationContext<Map<String, dynamic>>(
        value: {'name': 'John', 'age': 30},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with nullable fields', () {
      final rule = HasFields<int?>({
        'a': ValidasiEngine<int?>(),
        'b': ValidasiEngine<int?>(),
      });
      final context = ValidationContext<Map<String, int?>>(
        value: {'a': null, 'b': 2},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should validate nested structures', () {
      final rule = HasFields<Map<String, int>>({
        'nested': ValidasiEngine<Map<String, int>>(),
      });
      final context = ValidationContext<Map<String, Map<String, int>>>(
        value: {
          'nested': {'x': 1, 'y': 2}
        },
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should validate all fields even if early ones fail', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorA')],
        ),
        'b': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorB')],
        ),
        'c': ValidasiEngine<int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorC')],
        ),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'a': 1, 'b': 2, 'c': 3},
      );

      rule.apply(context);

      expect(context.errors.length, equals(3));
    });

    test('should work with single field', () {
      final rule = HasFields<int>({
        'id': ValidasiEngine<int>(),
      });
      final context = ValidationContext<Map<String, int>>(
        value: {'id': 123},
      );

      rule.apply(context);

      expect(context.errors, isEmpty);
    });

    test('should work with many fields', () {
      final fields = <String, ValidasiEngine<int>>{};
      for (var i = 0; i < 20; i++) {
        fields['field$i'] = ValidasiEngine<int>();
      }
      final rule = HasFields<int>(fields);
      final map = <String, int>{};
      for (var i = 0; i < 20; i++) {
        map['field$i'] = 1;
      }
      final context = ValidationContext<Map<String, int>>(value: map);

      rule.apply(context);

      expect(context.errors, isEmpty);
    });
  });
}

class _TestRule<T> extends Rule<T> {
  _TestRule({
    required this.shouldFail,
    this.ruleName = 'TestRule',
  });

  final bool shouldFail;
  final String ruleName;

  @override
  void apply(ValidationContext<T> context) {
    if (shouldFail) {
      context.addError(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }
  }
}
