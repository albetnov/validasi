import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test.mocks.dart';

void main() {
  group('String Validator Test', () {
    test('passes strict check on value match string or null', () {
      var schema = Validasi.string();

      shouldNotThrow(() {
        schema.parse('value');
        schema.parse(null);
      });
    });

    test('fails strict check on value not match string or not null', () {
      var schema = Validasi.string();

      expect(
          () => schema.parse(true),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'invalidType' &&
              e.message == 'field is not a valid String')));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(result.errors.first.name, equals('invalidType'));
    });

    test('can override message for type check', () {
      var schema = Validasi.string(message: 'Must string!');

      expect(schema.tryParse(true).errors.first.message, 'Must string!');
    });

    test('allow conversion to string on strict turned off', () {
      var schema = Validasi.string(strict: false);

      expect(schema.parse(10).value, equals('10'));

      expect(schema.parse(null).value, isNull,
          reason: 'When passed null it should stay null, not converted');
    });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.string().custom((value, fail) {
        if (value == 'value') {
          return fail(':name is not registered');
        }

        return true;
      });

      expect(
          () => schema.parse('value'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is not registered')));

      shouldNotThrow(() => schema.parse('text'));

      var mock = MockCustomRule();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0] == 'value') {
          return args.positionalArguments[1](':name is not registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(
          () => schema.parse('value'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is not registered')));

      verify(mock.handle('value', any)).called(1);

      shouldNotThrow(() {
        schema.parse('text');
      });
    });

    test('parseAsync can also run custom rule', () async {
      var schema = Validasi.string()
          .custom((value, fail) async => fail(':name balance is not enough'));

      await expectLater(
          () => schema.parseAsync('value', path: 'amount'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'amount balance is not enough')));
    });

    test('tryParse can run custom rule', () {
      var schema = Validasi.string()
          .custom((value, fail) => fail('your chosen :name is not available'));

      var result = schema.tryParse('value', path: 'type');

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, 'your chosen type is not available');
    });

    test('tryParseAsync can also run custom rule', () async {
      var schema = Validasi.string().custom(
          (value, fail) async => fail('your chosen :name is not available'));

      var result = await schema.tryParseAsync('value', path: 'type');

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, 'your chosen type is not available');
    });

    test('should pass for required rule', () {
      var schema = Validasi.string().required();

      shouldNotThrow(() {
        schema.parse('value');
      });
    });

    test('should fail for required rule', () {
      var schema = Validasi.string().required();

      expect(schema.tryParse(null).errors.first.name, 'required');
      expect(schema.tryParse('').errors.first.name, 'required');
      expect(schema.tryParse('    ').errors.first.name, 'required');
    });

    test('can customize field name on required message', () {
      var schema = Validasi.string().required();

      expect(schema.tryParse(null, path: 'label').errors.first.message,
          equals('label is required'));
    });

    test('can customize default error message on required', () {
      var schema = Validasi.string().required(message: 'fill this!');

      expect(schema.tryParse(null).errors.first.message, equals('fill this!'));
    });

    test('should pass for minLength', () {
      var schema = Validasi.string().minLength(3);

      expect(schema.tryParse('abc').isValid, isTrue);
      expect(schema.tryParse('abcde').isValid, isTrue);
    });

    test('should fail for minLength', () {
      var schema = Validasi.string().minLength(3);

      var result = schema.tryParse(null);

      expect(result.isValid, isFalse);
      expect(result.errors.first.name, 'minLength');
      expect(schema.tryParse('').isValid, isFalse);
      expect(schema.tryParse('ab').isValid, isFalse);
      expect(schema.tryParse(null).isValid, isFalse);
    });

    test('can customize field name on minLength message', () {
      var schema = Validasi.string().minLength(3);

      expect(schema.tryParse(null, path: 'label').errors.first.message,
          equals('label must be at least contains 3 characters'));
    });

    test('can customize default error message on minLength', () {
      var schema = Validasi.string().minLength(3, message: 'too short!');

      expect(schema.tryParse(null).errors.first.message, equals('too short!'));
    });

    test('should pass for maxLength', () {
      var schema = Validasi.string().maxLength(5);

      expect(schema.tryParse('abcd').isValid, isTrue);
      expect(schema.tryParse('abcde').isValid, isTrue);
    });

    test('should fail for maxLength', () {
      var schema = Validasi.string().maxLength(5);

      expect(schema.tryParse('abcdef').isValid, isFalse);
      expect(schema.tryParse(null).isValid, isFalse);
    });

    test('can customize field name on maxLength message', () {
      var schema = Validasi.string().maxLength(5);

      expect(schema.tryParse('abcdef', path: 'nid').errors.first.message,
          equals('nid must not be longer than 5 characters'));
    });

    test('can customize default error message on maxLength', () {
      var schema =
          Validasi.string().maxLength(5, message: ':name is too long!');

      expect(schema.tryParse('abcdef', path: 'nid').errors.first.message,
          equals('nid is too long!'));
    });
  });
}
