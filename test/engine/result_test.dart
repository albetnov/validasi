import 'package:test/test.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';

void main() {
  group('ValidasiResult', () {
    group('constructor', () {
      test('should create valid result with data', () {
        final result = ValidasiResult<String>(
          errors: [],
          isValid: true,
          data: 'test',
        );

        expect(result.isValid, isTrue);
        expect(result.data, equals('test'));
        expect(result.errors, isEmpty);
      });

      test('should create invalid result with errors', () {
        final error = ValidationError(rule: 'test', message: 'error');
        final result = ValidasiResult<String>(
          errors: [error],
          isValid: false,
        );

        expect(result.isValid, isFalse);
        expect(result.data, isNull);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, equals(error));
      });
    });

    group('error factory', () {
      test('should create invalid result with single error', () {
        final error = ValidationError(rule: 'test', message: 'error');
        final result = ValidasiResult<String>.error(error);

        expect(result.isValid, isFalse);
        expect(result.data, isNull);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, equals(error));
      });
    });

    group('success factory', () {
      test('should create valid result with data', () {
        final result = ValidasiResult<String>.success('test data');

        expect(result.isValid, isTrue);
        expect(result.data, equals('test data'));
        expect(result.errors, isEmpty);
      });

      test('should create valid result with null data', () {
        final result = ValidasiResult<String?>.success(null);

        expect(result.isValid, isTrue);
        expect(result.data, isNull);
        expect(result.errors, isEmpty);
      });
    });

    group('transform', () {
      test('should transform valid result', () {
        final result = ValidasiResult<String>.success('42');

        final transformed = result.transform<int>((value) => int.parse(value!));

        expect(transformed.isValid, isTrue);
        expect(transformed.data, equals(42));
        expect(transformed.errors, isEmpty);
      });

      test('should not transform invalid result', () {
        final error = ValidationError(rule: 'test', message: 'error');
        final result = ValidasiResult<String>.error(error);

        final transformed = result.transform<int>((value) => int.parse(value!));

        expect(transformed.isValid, isFalse);
        expect(transformed.data, isNull);
        expect(transformed.errors.length, equals(1));
        expect(transformed.errors.first, equals(error));
      });

      test('should handle transformation exception', () {
        final result = ValidasiResult<String>.success('not a number');

        final transformed = result.transform<int>((value) => int.parse(value!));

        expect(transformed.isValid, isFalse);
        expect(transformed.errors.length, equals(1));
        expect(transformed.errors.first.rule, equals('Transformation'));
        expect(
          transformed.errors.first.message,
          equals('Failed to transform value'),
        );
      });

      test('should transform with null value', () {
        final result = ValidasiResult<String?>.success(null);

        final transformed = result
            .transform<int>((value) => value == null ? 0 : int.parse(value));

        expect(transformed.isValid, isTrue);
        expect(transformed.data, equals(0));
      });

      test('should chain multiple transformations', () {
        final result = ValidasiResult<String>.success('10');

        final transformed = result
            .transform<int>((value) => int.parse(value!))
            .transform<String>((value) => 'Number: $value')
            .transform<int>((value) => value!.length);

        expect(transformed.isValid, isTrue);
        expect(transformed.data, equals(10)); // 'Number: 10'.length
      });

      test('should stop transformation chain on error', () {
        final result = ValidasiResult<String>.success('not a number');

        final transformed = result
            .transform<int>((value) => int.parse(value!))
            .transform<String>((value) => 'Number: $value');

        expect(transformed.isValid, isFalse);
        expect(transformed.errors.first.rule, equals('Transformation'));
      });
    });

    group('requireValue', () {
      test('should return data for valid result', () {
        final result = ValidasiResult<String>.success('test data');

        final value = result.requireValue();

        expect(value, equals('test data'));
      });

      test('should return null for valid result with null data', () {
        final result = ValidasiResult<String?>.success(null);

        final value = result.requireValue();

        expect(value, isNull);
      });

      test('should throw StateError for invalid result', () {
        final error = ValidationError(rule: 'test', message: 'error');
        final result = ValidasiResult<String>.error(error);

        expect(
          () => result.requireValue(),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError with descriptive message', () {
        final error = ValidationError(rule: 'test', message: 'error');
        final result = ValidasiResult<String>.error(error);

        try {
          result.requireValue();
          fail('Expected StateError to be thrown');
        } catch (e) {
          expect(e, isA<StateError>());
          expect(
            (e as StateError).message,
            equals('Cannot require value from invalid result'),
          );
        }
      });
    });

    group('different data types', () {
      test('should work with int', () {
        final result = ValidasiResult<int>.success(42);

        expect(result.isValid, isTrue);
        expect(result.data, equals(42));
      });

      test('should work with List', () {
        final result = ValidasiResult<List<int>>.success([1, 2, 3]);

        expect(result.isValid, isTrue);
        expect(result.data, equals([1, 2, 3]));
      });

      test('should work with Map', () {
        final result = ValidasiResult<Map<String, int>>.success({'key': 123});

        expect(result.isValid, isTrue);
        expect(result.data, equals({'key': 123}));
      });

      test('should work with custom objects', () {
        final testObject = _TestClass('test', 42);
        final result = ValidasiResult<_TestClass>.success(testObject);

        expect(result.isValid, isTrue);
        expect(result.data?.name, equals('test'));
        expect(result.data?.value, equals(42));
      });
    });

    group('toToolResponse', () {
      test('should serialize valid result with deterministic data map ordering', () {
        final result = ValidasiResult<Map<String, dynamic>>.success({
          'z': 1,
          'a': {
            'k2': false,
            'k1': true,
          },
        });

        final payload = result.toToolResponse();
        final data = payload['data'] as Map<String, Object?>;
        final nested = data['a'] as Map<String, Object?>;

        expect(payload['isValid'], isTrue);
        expect(payload['errorCount'], equals(0));
        expect(payload['errors'], isEmpty);
        expect(data.keys.toList(), equals(['a', 'z']));
        expect(nested.keys.toList(), equals(['k1', 'k2']));
      });

      test('should serialize invalid result with normalized errors', () {
        final result = ValidasiResult<String>.error(
          ValidationError(
            rule: 'MinLength',
            message: 'too short',
            path: ['name'],
            details: {'b': 2, 'a': 1},
          ),
        );

        final payload = result.toToolResponse();
        final errors = payload['errors'] as List<Object?>;
        final firstError = errors.first as Map<String, Object?>;
        final details = firstError['details'] as Map<String, Object?>;

        expect(payload['isValid'], isFalse);
        expect(payload['data'], isNull);
        expect(payload['errorCount'], equals(1));
        expect(firstError['rule'], equals('MinLength'));
        expect(firstError['path'], equals(['name']));
        expect(details.keys.toList(), equals(['a', 'b']));
      });

      test('should produce identical payload on repeated calls', () {
        final result = ValidasiResult<Map<String, dynamic>>(
          isValid: false,
          data: {'c': 3, 'a': 1, 'b': 2},
          errors: [
            ValidationError(
              rule: 'RuleA',
              message: 'failed',
              details: {'z': true, 'x': false},
            ),
          ],
        );

        final payload1 = result.toToolResponse();
        final payload2 = result.toToolResponse();

        expect(payload1, equals(payload2));
      });
    });
  });
}

class _TestClass {
  _TestClass(this.name, this.value);

  final String name;
  final int value;
}
