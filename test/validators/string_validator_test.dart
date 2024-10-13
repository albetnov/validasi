import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';

void main() {
  group('String Validator Test', () {
    test('should pass type check when value is string', () {
      var schema = Validasi.string();

      shouldNotThrow(() {
        schema.parse('value');
      });
    });

    test('should fail type check when value is not a string', () {
      var schema = Validasi.string();

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type String. Got bool instead.'));
    });

    test('can attach StringTransformer', () {
      var schema = Validasi.string(transformer: StringTransformer());

      var result = schema.parse(123);

      expect(result.value, equals('123'));
    });

    test('should pass if nullable is set for value null', () {
      var schema = Validasi.string().nullable();

      expect(schema.tryParse(null).isValid, isTrue);
    });

    test('should fail if nullable is not set for value null', () {
      var schema = Validasi.string();

      var result = schema.tryParse(null);

      expect(getName(result), equals('required'));
      expect(getMsg(result), equals('field is required'));
    });

    test('verify can attach custom', () async {
      testCanAttachCustom(
        valid: 'valid',
        invalid: 'invalid',
        validator: () => Validasi.string(),
      );
    });

    test('should pass for minLength', () {
      var schema = Validasi.string().minLength(3);

      expect(schema.tryParse('abc').isValid, isTrue);
      expect(schema.tryParse('abcde').isValid, isTrue);
    });

    test('should fail for minLength', () {
      var schema = Validasi.string().minLength(3);

      expect(schema.tryParse('').isValid, isFalse);

      var result = schema.tryParse('ab');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('minLength'));
      expect(
          getMsg(result), equals('field must contains at least 3 characters'));
    });

    test('can customize field name on minLength message', () {
      var schema = Validasi.string().minLength(3);

      expect(getMsg(schema.tryParse('ab', path: 'label')),
          equals('label must contains at least 3 characters'));
    });

    test('can customize default error message on minLength', () {
      var schema = Validasi.string().minLength(3, message: 'too short!');

      expect(getMsg(schema.tryParse('ab')), equals('too short!'));
    });

    test('should pass for maxLength', () {
      var schema = Validasi.string().maxLength(5);

      expect(schema.tryParse('abcd').isValid, isTrue);
      expect(schema.tryParse('abcde').isValid, isTrue);
    });

    test('should fail for maxLength', () {
      var schema = Validasi.string().maxLength(5);

      var result = schema.tryParse('abcdef');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('maxLength'));
      expect(getMsg(result), 'field must not be longer than 5 characters');
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

      var result = schema.tryParse('example@mail');
      expect(result.isValid, isFalse);
      expect(getMsg(result), equals('field must be a valid email'));
      expect(getName(result), equals('email'));

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

      var result = schema.tryParse('world');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('startsWith'));
      expect(getMsg(result), equals('field must start with "hello"'));
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

      var result = schema.tryParse('hello');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('endsWith'));
      expect(getMsg(result), equals('field must end with "world"'));
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

      var result = schema.tryParse('hello');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('contains'));
      expect(getMsg(result), equals('field must contain "world"'));
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

      var result = schema.tryParse(':: not valid ::');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('url'));
      expect(getMsg(result), equals('field must be a valid url'));
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

      var result = schema.tryParse('hello world');

      expect(result.isValid, isFalse);
      expect(getName(result), equals('regex'));
      expect(getMsg(result), equals('field must match the pattern'));
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
