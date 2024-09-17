import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test.mocks.dart';

void main() {
  group('Number Validator Test', () {
    test('passes strict check on value match num or null', () {
      var schema = Validasi.number();

      shouldNotThrow(() {
        schema.parse(10);
        schema.parse(null);
      });
    });

    test('fails strict check on value not match num or not null', () {
      var schema = Validasi.number();

      expect(
          () => schema.parse(true),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'invalidType' &&
              e.message == 'field is not a valid number')));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(result.errors.first.name, equals('invalidType'));
      expect(result.value, isNull);
    });

    // test('can override message for type check', () {
    //   var schema = Validasi.number(message: 'Must numeric!');

    //   expect(schema.tryParse(true).errors.first.message, 'Must numeric!');
    // });

    // test('allow conversion to num on strict turned off', () {
    //   var schema = Validasi.number(strict: false);

    //   expect(schema.parse('10').value, equals(10));

    //   expect(schema.parse(null).value, isNull,
    //       reason: 'When passed null it should stay null, not converted');
    // });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.number().custom((value, fail) {
        if (value == 1) {
          return fail(':name is not registered');
        }

        return true;
      });

      expect(
          () => schema.parse(1),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is not registered')));

      shouldNotThrow(() => schema.parse(2));

      var mock = MockCustomRule<num>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0] == 1) {
          return args.positionalArguments[1](':name is not registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(
          () => schema.parse(1),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is not registered')));

      verify(mock.handle(1, any)).called(1);

      shouldNotThrow(() {
        schema.parse(2);
      });
    });

    test('parseAsync can also run custom rule', () async {
      var schema = Validasi.number().custom(
          (value, fail) async => fail(':name need to be in between 5-20.'));

      await expectLater(
          () => schema.parseAsync(3, path: 'order no'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'order no need to be in between 5-20.')));
    });

    test('tryParse can run custom rule', () {
      var schema = Validasi.number()
          .custom((value, fail) => fail('your chosen :name is not available'));

      var result = schema.tryParse(1, path: 'order no');

      expect(result.isValid, isFalse);
      expect(
          result.errors.first.message, 'your chosen order no is not available');
    });

    test('tryParseAsync can also run custom rule', () async {
      var schema = Validasi.number().custom(
          (value, fail) async => fail('your chosen :name is not available'));

      var result = await schema.tryParseAsync(1, path: 'order no');

      expect(result.isValid, isFalse);
      expect(
          result.errors.first.message, 'your chosen order no is not available');
    });

    test('should pass for required rule', () {
      var schema = Validasi.number().required();

      shouldNotThrow(() {
        schema.parse(1);
      });
    });

    test('should fail for required rule', () {
      var schema = Validasi.number().required();

      expect(schema.tryParse(null).errors.first.name, 'required');
    });

    test('can customize field name on required message', () {
      var schema = Validasi.number().required();

      expect(schema.tryParse(null, path: 'id').errors.first.message,
          equals('id is required'));
    });

    test('can customize default error message on required', () {
      var schema = Validasi.number().required(message: 'fill this!');

      expect(schema.tryParse(null).errors.first.message, equals('fill this!'));
    });
  });
}
