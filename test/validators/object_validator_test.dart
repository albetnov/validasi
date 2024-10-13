import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test_stub.mocks.dart';

void main() {
  group('Object Validator Test', () {
    test('passes type check on value match schema', () {
      var schema = Validasi.object({'name': Validasi.string()});

      shouldNotThrow(() {
        schema.parse({'name': 'Asep'});
      });
    });

    test('fails types check on value not match schema', () {
      var schema = Validasi.object({'name': Validasi.string()});

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message:
                  'Expected type Map<dynamic, dynamic>. Got bool instead.'));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(getName(result), equals('invalidType'));
      expect(result.value, isNull);

      expect(schema.tryParse({}).value, equals({'name': null}));
    });

    test('should pass if nullable is set for value null', () {
      var schema = Validasi.object({'name': Validasi.string()}).nullable();

      expect(schema.tryParse(null).isValid, isTrue);

      var nestedSchema = Validasi.object({
        'address': Validasi.object({'street': Validasi.string()}).nullable(),
      });

      shouldNotThrow(() {
        nestedSchema.parse({});
      });
    });

    test('should fail if nullable is not set for value null', () {
      var schema = Validasi.object({'name': Validasi.string()});

      var result = schema.tryParse(null);

      expect(getName(result), equals('required'));
      expect(getMsg(result), equals('field is required'));

      var nestedSchema = Validasi.object({
        'address': Validasi.object({'street': Validasi.string()}),
      });

      expect(() => nestedSchema.parse({}),
          throwFieldError(path: 'field.address', name: 'required'));
    });

    test('verify can attach custom', () {
      testCanAttachCustom(
        valid: {'name': 'valid'},
        invalid: {'name': 'invalid'},
        validator: () => Validasi.object({'name': Validasi.string()}),
      );
    });

    test('verify the validator schema tryParse method get called', () async {
      var mock = MockValidator<int>();

      when(mock.tryParse(1, path: 'field.id')).thenReturn(Result(value: 1));

      when(mock.tryParseAsync(1, path: 'field.id'))
          .thenAnswer((_) async => Result(value: 1));

      var schema = Validasi.object({'id': mock});

      schema.tryParse({'id': 1});
      verify(mock.tryParse(1, path: 'field.id')).called(1);

      await schema.tryParseAsync({'id': 1});
      verify(mock.tryParseAsync(1, path: 'field.id')).called(1);

      schema.parse({'id': 1});
      verify(mock.tryParse(1, path: 'field.id')).called(1);

      await schema.parseAsync({'id': 1});
      verify(mock.tryParseAsync(1, path: 'field.id')).called(1);
    });

    test('parse error contains valid path', () async {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string(),
      });

      expect(() => schema.parse({'id': '1', 'name': 1}),
          throwFieldError(path: 'field.id'));

      await expectLater(() => schema.parseAsync({'id': '1', 'name': 1}),
          throwFieldError(path: 'field.id'));
    });

    test('tryParse error contains valid path', () async {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string(),
      });

      var result = schema.tryParse({'id': '1', 'name': 1});

      expect(result.isValid, isFalse);

      var fields = ['field.id', 'field.name'];

      for (var error in result.errors) {
        expect(fields.contains(error.path), isTrue);
      }

      var resultAsync = await schema.tryParseAsync({'id': '1', 'name': 1});

      expect(resultAsync.isValid, isFalse);

      for (var error in resultAsync.errors) {
        expect(fields.contains(error.path), isTrue);
      }
    });

    test('parse could validate nested schema', () async {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string(),
        'address': Validasi.object({
          'street': Validasi.string(),
          'city': Validasi.string(),
          'zip': Validasi.object({
            'code': Validasi.number(),
          }),
        }),
      });

      expect(
          () => schema.parse({'id': '1'}), throwFieldError(path: 'field.id'));

      expect(
        () => schema.parse({
          'id': 1,
          'name': 'Asep',
          'address': {
            'street': 10,
          }
        }),
        throwFieldError(path: 'field.address.street'),
      );

      expect(
          () => schema.parse({
                'id': 1,
                'name': 'Asep',
                'address': {
                  'street': 'Jalan Jendral Sudirman',
                  'city': 'Jakarta',
                  'zip': {
                    'code': '12345',
                  }
                }
              }),
          throwFieldError(path: 'field.address.zip.code', name: 'invalidType'));

      shouldNotThrow(() => schema.parse({
            'id': 1,
            'name': 'Asep',
            'address': {
              'street': 'Jalan Jendral Sudirman',
              'city': 'Jakarta',
              'zip': {
                'code': 12345,
              }
            }
          }));

      await expectLater(
          () => schema.parseAsync({
                'id': 1,
                'name': 'Asep',
                'address': {
                  'street': 'Jalan Jendral Sudirman',
                  'city': 'Jakarta',
                  'zip': {
                    'code': '12345',
                  }
                }
              }),
          throwFieldError(path: 'field.address.zip.code', name: 'invalidType'));

      await shouldNotThrowAsync(() => schema.parseAsync({
            'id': 1,
            'name': 'Asep',
            'address': {
              'street': 'Jalan Jendral Sudirman',
              'city': 'Jakarta',
              'zip': {
                'code': 12345,
              }
            }
          }));
    });

    test('tryParse could validate nested schema', () async {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string(),
        'address': Validasi.object({
          'street': Validasi.string(),
          'city': Validasi.string(),
          'zip': Validasi.object({
            'code': Validasi.number(),
          }),
        }),
      });

      var result = schema.tryParse({'id': '1'});

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, 'field.id');

      result = schema.tryParse({
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 10,
        }
      });

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, 'field.address.street');

      result = schema.tryParse({
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 'Jalan Jendral Sudirman',
          'city': 'Jakarta',
          'zip': {
            'code': '12345',
          }
        }
      });

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, 'field.address.zip.code');
      expect(result.errors.first.name, 'invalidType');

      result = schema.tryParse({
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 'Jalan Jendral Sudirman',
          'city': 'Jakarta',
          'zip': {
            'code': 12345,
          }
        }
      });

      expect(result.isValid, isTrue);

      var resultAsync = await schema.tryParseAsync({
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 'Jalan Jendral Sudirman',
          'city': 'Jakarta',
          'zip': {
            'code': '12345',
          }
        }
      });

      expect(resultAsync.isValid, isFalse);
      expect(resultAsync.errors.first.path, 'field.address.zip.code');
      expect(resultAsync.errors.first.name, 'invalidType');

      resultAsync = await schema.tryParseAsync({
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 'Jalan Jendral Sudirman',
          'city': 'Jakarta',
          'zip': {
            'code': 12345,
          }
        }
      });

      expect(resultAsync.isValid, isTrue);
    });

    test('parse and tryParse reconstruct object correctly', () async {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string(),
        'address': Validasi.object({
          'street': Validasi.string(),
          'city': Validasi.string(),
          'zip': Validasi.object({
            'code': Validasi.number(transformer: NumberTransformer()),
          }),
        }),
      });

      var rawValue = {
        'id': 1,
        'name': 'Asep',
        'address': {
          'street': 'Jalan Jendral Sudirman',
          'city': 'Jakarta',
          'zip': {
            'code': '12345',
          }
        }
      };

      Map<String, dynamic> transformedValue = Map.from(rawValue);
      transformedValue['address']['zip'] = <String, dynamic>{'code': 12345};

      var result = schema.parse(rawValue);

      expect(result.value, equals(transformedValue));

      var resultAsync = await schema.parseAsync(rawValue);

      expect(resultAsync.value, equals(transformedValue));

      var scenarios = [
        {
          'case': {'id': 1},
          'expectation': {'id': 1, 'name': null, 'address': null}
        },
        {
          'case': {
            'address': {
              'zip': {'code': '123'}
            }
          },
          'expectation': {
            'id': null,
            'name': null,
            'address': {
              'street': null,
              'city': null,
              'zip': {
                'code': 123,
              }
            }
          }
        },
        {
          'case': {
            'id': 1,
            'name': 'Asep',
            'address': {
              'street': 'Jalan Jendral Sudirman',
              'city': 'Jakarta',
              'zip': {
                'code': '12345',
              }
            }
          },
          'expectation': {
            'id': 1,
            'name': 'Asep',
            'address': {
              'street': 'Jalan Jendral Sudirman',
              'city': 'Jakarta',
              'zip': {
                'code': 12345,
              }
            }
          }
        }
      ];

      for (var scenario in scenarios) {
        var result = schema.tryParse(scenario['case']);

        expect(result.value, equals(scenario['expectation']));

        var resultAsync = await schema.tryParseAsync(scenario['case']);

        expect(resultAsync.value, equals(scenario['expectation']));
      }
    });
  });
}
