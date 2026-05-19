import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/rules/map/has_fields.dart';

void main() {
  group('HasFields', () {
    test('should validate all fields successfully', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(),
        'b': ValidasiEngine<int, int>(),
      });
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors, isEmpty);
    });

    test('should collect errors from failing field validations', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true)],
        ),
        'b': ValidasiEngine<int, int>(),
      });
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors.length, equals(1));
    });

    test('should prefix errors with field name', () {
      final rule = HasFields<int>({
        'age': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'TooYoung')],
        ),
      });
      final state = ValidationState();

      rule.apply({'age': 15}, state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.path, equals(['age']));
      expect(state.errors.first.rule, equals('TooYoung'));
    });

    test('should work with empty fields map', () {
      final rule = HasFields<int>({});
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors, isEmpty);
    });

    test('should validate missing fields as null', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(),
        'b': ValidasiEngine<int, int>(),
      });
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      // Missing field 'b' is validated as null
      expect(state.errors, isEmpty);
    });

    test('should collect errors from multiple fields', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'Error1')],
        ),
        'b': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'Error2')],
        ),
      });
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2}, state);

      expect(state.errors.length, equals(2));
      expect(state.errors[0].path, equals(['a']));
      expect(state.errors[1].path, equals(['b']));
    });

    test('should collect multiple errors per field', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(
          rules: [
            _TestRule<int>(shouldFail: true, ruleName: 'Error1'),
            _TestRule<int>(shouldFail: true, ruleName: 'Error2'),
          ],
        ),
      });
      final state = ValidationState();

      rule.apply({'a': 1}, state);

      expect(state.errors.length, equals(2));
      expect(state.errors[0].path, equals(['a']));
      expect(state.errors[0].rule, equals('Error1'));
      expect(state.errors[1].path, equals(['a']));
      expect(state.errors[1].rule, equals('Error2'));
    });

    test('should work with different value types', () {
      final rule = HasFields<dynamic>({
        'name': ValidasiEngine<String, String>(),
        'age': ValidasiEngine<int, int>(),
      });
      final state = ValidationState();

      rule.apply({'name': 'John', 'age': 30}, state);

      expect(state.errors, isEmpty);
    });

    test('should work with nullable fields', () {
      final rule = HasFields<int?>({
        'a': ValidasiEngine<int?, int?>(),
        'b': ValidasiEngine<int?, int?>(),
      });
      final state = ValidationState();

      rule.apply({'a': null, 'b': 2}, state);

      expect(state.errors, isEmpty);
    });

    test('should validate nested structures', () {
      final rule = HasFields<Map<String, int>>({
        'nested': ValidasiEngine<Map<String, int>, Map<String, int>>(),
      });
      final state = ValidationState();

      rule.apply({
        'nested': {'x': 1, 'y': 2}
      }, state);

      expect(state.errors, isEmpty);
    });

    test('should validate all fields even if early ones fail', () {
      final rule = HasFields<int>({
        'a': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorA')],
        ),
        'b': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorB')],
        ),
        'c': ValidasiEngine<int, int>(
          rules: [_TestRule<int>(shouldFail: true, ruleName: 'ErrorC')],
        ),
      });
      final state = ValidationState();

      rule.apply({'a': 1, 'b': 2, 'c': 3}, state);

      expect(state.errors.length, equals(3));
    });

    test('should work with single field', () {
      final rule = HasFields<int>({
        'id': ValidasiEngine<int, int>(),
      });
      final state = ValidationState();

      rule.apply({'id': 123}, state);

      expect(state.errors, isEmpty);
    });

    test('should work with many fields', () {
      final fields = <String, ValidasiEngine<int, int>>{};
      for (var i = 0; i < 20; i++) {
        fields['field$i'] = ValidasiEngine<int, int>();
      }
      final rule = HasFields<int>(fields);
      final map = <String, int>{};
      for (var i = 0; i < 20; i++) {
        map['field$i'] = 1;
      }
      final state = ValidationState();

      rule.apply(map, state);

      expect(state.errors, isEmpty);
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
  T? apply(T? value, ValidationState state) {
    if (shouldFail) {
      state.errors.add(ValidationError(
        rule: ruleName,
        message: 'Test rule failed',
      ));
    }
    return value;
  }
}
