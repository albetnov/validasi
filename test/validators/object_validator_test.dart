import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'array_validator_test.mocks.dart';
import 'validator_test.mocks.dart';

void main() {
  group('Object Validator Test', () {
    test('passes type check on value match schema or null', () {
      var schema = Validasi.object({'name': Validasi.string()});

      shouldNotThrow(() {
        schema.parse({'name': null});
        schema.parse({'name': 'Asep'});
        schema.parse({});
        schema.parse(null);
      });
    });

    test('fails types check on value not match schema or not null', () {
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
      expect(result.value, equals({'name': null}));
    });

    test('parse can run custom callback and custom rule class', () {
      var schema =
          Validasi.object({'id': Validasi.number()}).custom((value, fail) {
        if (value == null) return false;

        if (value['id'] == 1) {
          return fail(':name is already registered');
        }

        return true;
      });

      expect(
          () => schema.parse({'id': 1}),
          throwFieldError(
              name: 'custom', message: 'field is already registered'));

      shouldNotThrow(() => schema.parse({'id': 3}));

      var mock = MockCustomRule<Map<dynamic, dynamic>>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0]['id'] == 1) {
          return args.positionalArguments[1](':name is already registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(
          () => schema.parse({'id': 1}),
          throwFieldError(
              name: 'custom', message: 'field is already registered'));

      verify(mock.handle({'id': 1}, any)).called(1);

      shouldNotThrow(() {
        schema.parse({'id': 2});
      });
    });

    test('parseAsync can also run custom rule', () async {
      var schema = Validasi.object({'id': Validasi.number()})
          .custom((value, fail) async => fail(':name is invalid'));

      await expectLater(() => schema.parseAsync({'id': 1}, path: 'id'),
          throwFieldError(name: 'custom', message: 'id is invalid'));
    });

    test('tryParse can run custom rule', () {
      var schema = Validasi.object({'id': Validasi.number()})
          .custom((value, fail) => fail(':name contains invalid value'));

      var result = schema.tryParse({'id': 1}, path: 'users');

      expect(result.isValid, isFalse);
      expect(getMsg(result), 'users contains invalid value');
    });

    test('tryParseAsync can also run custom rule', () async {
      var schema = Validasi.object({'id': Validasi.number()})
          .custom((value, fail) async => fail(':name contains invalid value'));

      var result = await schema.tryParseAsync({'id': 1}, path: 'users');

      expect(result.isValid, isFalse);
      expect(getMsg(result), 'users contains invalid value');
    });

    test('verify the validator schema parse method get called', () async {
      var mock = MockValidator<int>();

      when(mock.parse(1, path: 'field.id')).thenReturn(Result(value: 1));
      when(mock.parseAsync(1, path: 'field.id'))
          .thenAnswer((_) async => Result(value: 1));

      var schema = Validasi.object({'id': mock});

      schema.parse({'id': 1});
      verify(mock.parse(1, path: 'field.id')).called(1);

      await schema.parseAsync({'id': 1});
      verify(mock.parseAsync(1, path: 'field.id')).called(1);
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
          'expectation': {
            'id': 1,
            'name': null,
            'address': {
              'street': null,
              'city': null,
              'zip': {
                'code': null,
              }
            }
          }
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

    test('should pass for required rule', () {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string().required(),
      }).required();

      shouldNotThrow(() {
        schema.parse({'id': null, 'name': 'Asep'});
        schema.parse({'id': 1, 'name': 'Asep'});
      });
    });

    test('should fail for required rule', () {
      var schema = Validasi.object({
        'id': Validasi.number(),
        'name': Validasi.string().required(),
      }).required();

      expect(
          () => schema.parse({'id': 1}),
          throwFieldError(
              name: 'required',
              path: 'field.name',
              message: 'field.name is required'));

      expect(
          () => schema.parse(null),
          throwFieldError(
              name: 'required', path: 'field', message: 'field is required'));
    });

    test('can customize field name on required rule', () {
      var schema = Validasi.object({
        'id': Validasi.number(),
      }).required();

      expect(() => schema.parse(null, path: 'custom'),
          throwFieldError(path: 'custom', message: 'custom is required'));
    });

    test('can customize default error message for required rule', () {
      var schema = Validasi.object({
        'id': Validasi.number(),
      }).required(message: ':name must be filled');

      expect(() => schema.parse(null),
          throwFieldError(message: 'field must be filled'));
    });
  });
}
