import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test.mocks.dart';

void main() {
  group('String Validator Test', () {
    test('passes type check on value match string or null', () {
      var schema = Validasi.string();

      shouldNotThrow(() {
        schema.parse('value');
        schema.parse(null);
      });
    });

    test('fails type check on value not match string or not null', () {
      var schema = Validasi.string();

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type String. Got bool instead.'));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(result.errors.first.name, equals('invalidType'));
    });

    test('can attach StringTransformer', () {
      var schema = Validasi.string(transformer: StringTransformer());

      var result = schema.parse(123);

      expect(result.value, equals('123'));
    });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.string().custom((value, fail) {
        if (value == 'value') {
          return fail(':name is not registered');
        }

        return true;
      });

      expect(() => schema.parse('value'),
          throwFieldError(name: 'custom', message: 'field is not registered'));

      shouldNotThrow(() => schema.parse('text'));

      var mock = MockCustomRule<String>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0] == 'value') {
          return args.positionalArguments[1](':name is not registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(() => schema.parse('value'),
          throwFieldError(name: 'custom', message: 'field is not registered'));

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
          throwFieldError(
              name: 'custom', message: 'amount balance is not enough'));
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

    test('should pass for email', () {
      var schema = Validasi.string().email();

      expect(schema.tryParse('example@mail.com').isValid, isTrue);

      var internationalSchema =
          Validasi.string().email(allowInternational: true);

      // example from Wikipedia (https://en.wikipedia.org/wiki/International_email).
      expect(internationalSchema.tryParse('用户@例子.广告').isValid, isTrue);

      var topLevelDomainSchema =
          Validasi.string().email(allowTopLevelDomain: true);

      expect(topLevelDomainSchema.tryParse('example@mail').isValid, isTrue);
    });

    test('should fail for email', () {
      var schema = Validasi.string().email();

      expect(schema.tryParse('example@mail').isValid, isFalse);
      expect(schema.tryParse('用户@例子.广告').isValid, isFalse);
    });

    test('can customize field name on email message', () {
      var schema = Validasi.string().email();

      expect(getMsg(schema.tryParse('example@mail', path: 'email')),
          equals('email must be a valid email'));
    });

    test('can customize default error message on email', () {
      var schema = Validasi.string().email(message: 'invalid email');

      expect(getMsg(schema.tryParse('example@mail')), equals('invalid email'));
    });

    test('should pass for startsWith', () {
      var schema = Validasi.string().startsWith('hello');

      expect(schema.tryParse('hello world').isValid, isTrue);
    });

    test('should fail for startsWith', () {
      var schema = Validasi.string().startsWith('hello');

      expect(schema.tryParse('world').isValid, isFalse);
    });

    test('can customize field name on startsWith message', () {
      var schema = Validasi.string().startsWith('hello');

      expect(getMsg(schema.tryParse('world', path: 'greeting')),
          equals('greeting must start with "hello"'));
    });

    test('can customize default error message on startsWith', () {
      var schema = Validasi.string().startsWith('hello', message: 'no hello');

      expect(getMsg(schema.tryParse('world')), equals('no hello'));
    });

    test('should pass for endsWith', () {
      var schema = Validasi.string().endsWith('world');

      expect(schema.tryParse('hello world').isValid, isTrue);
    });

    test('should fail for endsWith', () {
      var schema = Validasi.string().endsWith('world');

      expect(schema.tryParse('hello').isValid, isFalse);
    });

    test('can customize field name on endsWith message', () {
      var schema = Validasi.string().endsWith('world');

      expect(getMsg(schema.tryParse('hello', path: 'greeting')),
          equals('greeting must end with "world"'));
    });

    test('can customize default error message on endsWith', () {
      var schema = Validasi.string().endsWith('world', message: 'no world');

      expect(getMsg(schema.tryParse('hello')), equals('no world'));
    });

    test('should pass for contains', () {
      var schema = Validasi.string().contains('world');

      expect(schema.tryParse('hello world').isValid, isTrue);
    });

    test('should fail for contains', () {
      var schema = Validasi.string().contains('world');

      expect(schema.tryParse('hello').isValid, isFalse);
    });

    test('can customize field name on contains message', () {
      var schema = Validasi.string().contains('world');

      expect(getMsg(schema.tryParse('hello', path: 'greeting')),
          equals('greeting must contain "world"'));
    });

    test('can customize default error message on contains', () {
      var schema = Validasi.string().contains('world', message: 'no world');

      expect(getMsg(schema.tryParse('hello')), equals('no world'));
    });

    test('should pass for url', () {
      var schema = Validasi.string().url();

      expect(schema.tryParse('https://example.com').isValid, isTrue);
    });

    test('should fail for url', () {
      var schema = Validasi.string().url();

      expect(schema.tryParse(':: not valid ::').isValid, isFalse);
    });

    test('can customize field name on url message', () {
      var schema = Validasi.string().url();

      expect(getMsg(schema.tryParse(':: not valid ::', path: 'url')),
          equals('url must be a valid url'));
    });

    test('can customize default error message on url', () {
      var schema = Validasi.string().url(message: 'invalid url');

      expect(getMsg(schema.tryParse(':: not valid ::')), equals('invalid url'));
    });

    test('should pass for regex', () {
      var schema = Validasi.string().regex(r'^[a-z]+$');

      expect(schema.tryParse('hello').isValid, isTrue);
    });

    test('should fail for regex', () {
      var schema = Validasi.string().regex(r'^[a-z]+$');

      expect(schema.tryParse('hello world').isValid, isFalse);
    });

    test('can customize field name on regex message', () {
      var schema = Validasi.string().regex(r'^[a-z]+$');

      expect(getMsg(schema.tryParse('hello world', path: 'greeting')),
          equals('greeting must match the pattern'));
    });

    test('can customize default error message on regex', () {
      var schema = Validasi.string().regex(r'^[a-z]+$', message: 'invalid');

      expect(getMsg(schema.tryParse('hello world')), equals('invalid'));
    });
  });
}
