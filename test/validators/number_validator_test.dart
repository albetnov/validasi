import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test.mocks.dart';

void main() {
  group('Number Validator Test', () {
    test('passes type check on value match num or null', () {
      var schema = Validasi.number();

      shouldNotThrow(() {
        schema.parse(10);
        schema.parse(null);
      });
    });

    test('fails type check on value not match num or not null', () {
      var schema = Validasi.number();

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type num. Got bool instead.'));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(result.errors.first.name, equals('invalidType'));
      expect(result.value, isNull);
    });

    test('can attach NumberTransformer', () {
      var schema = Validasi.number(transformer: NumberTransformer());

      var result = schema.parse('123');

      expect(result.value, equals(123));
    });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.number().custom((value, fail) {
        if (value == 1) {
          return fail(':name is not registered');
        }

        return true;
      });

      expect(() => schema.parse(1),
          throwFieldError(name: 'custom', message: 'field is not registered'));

      shouldNotThrow(() => schema.parse(2));

      var mock = MockCustomRule<num>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0] == 1) {
          return args.positionalArguments[1](':name is not registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(() => schema.parse(1),
          throwFieldError(name: 'custom', message: 'field is not registered'));

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
          throwFieldError(
              name: 'custom', message: 'order no need to be in between 5-20.'));
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

      expect(() => schema.parse(null),
          throwFieldError(name: 'required', message: 'field is required'));
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

    test('should pass for nonDecimal', () {
      var schema = Validasi.number().nonDecimal();

      shouldNotThrow(() {
        schema.parse(1);
        schema.parse(10);
      });
    });

    test('should fail for nonDecimal', () {
      var schema = Validasi.number().nonDecimal();

      expect(
          () => schema.parse(1.1),
          throwFieldError(
              name: 'nonDecimal', message: 'field must be non-decimal number'));
    });

    test('can customize field name on nonDecimal message', () {
      var schema = Validasi.number().nonDecimal();

      expect(getMsg(schema.tryParse(1.1, path: 'id')),
          equals('id must be non-decimal number'));
    });

    test('can customize default error message on nonDecimal', () {
      var schema =
          Validasi.number().nonDecimal(message: 'should not be decimal!');

      expect(getMsg(schema.tryParse(1.1)), equals('should not be decimal!'));
    });

    test('should pass for decimal', () {
      var schema = Validasi.number().decimal();

      shouldNotThrow(() {
        schema.parse(1.1);
        schema.parse(10.1);
      });
    });

    test('should fail for decimal', () {
      var schema = Validasi.number().decimal();

      expect(
          () => schema.parse(1),
          throwFieldError(
              name: 'decimal', message: 'field must be decimal number'));
    });

    test('can customize field name on decimal', () {
      var schema = Validasi.number().decimal();

      expect(getMsg(schema.tryParse(1, path: 'id')),
          equals('id must be decimal number'));
    });

    test('can customize default error message on decimal', () {
      var schema = Validasi.number().decimal(message: 'should be decimal!');

      expect(getMsg(schema.tryParse(1)), equals('should be decimal!'));
    });

    test('should pass for positive', () {
      var schema = Validasi.number().positive();

      shouldNotThrow(() {
        schema.parse(1);
        schema.parse(10);
      });
    });

    test('should fail for positive', () {
      var schema = Validasi.number().positive();

      expect(
          () => schema.parse(-1),
          throwFieldError(
              name: 'positive', message: 'field must be positive number'));
    });

    test('can customize field name on positive', () {
      var schema = Validasi.number().positive();

      expect(getMsg(schema.tryParse(-1, path: 'id')),
          equals('id must be positive number'));
    });

    test('can customize default error message on positive', () {
      var schema = Validasi.number().positive(message: 'should be positive!');

      expect(getMsg(schema.tryParse(-1)), equals('should be positive!'));
    });

    test('should pass for negative', () {
      var schema = Validasi.number().negative();

      shouldNotThrow(() {
        schema.parse(-1);
        schema.parse(-10);
      });
    });

    test('should fail for negative', () {
      var schema = Validasi.number().negative();

      expect(
          () => schema.parse(1),
          throwFieldError(
              name: 'negative', message: 'field must be negative number'));
    });

    test('can customize field name on negative', () {
      var schema = Validasi.number().negative();

      expect(getMsg(schema.tryParse(1, path: 'id')),
          equals('id must be negative number'));
    });

    test('can customize default error message on negative', () {
      var schema = Validasi.number().negative(message: 'should be negative!');

      expect(getMsg(schema.tryParse(1)), equals('should be negative!'));
    });

    test('should pass for nonPositive', () {
      var schema = Validasi.number().nonPositive();

      shouldNotThrow(() {
        schema.parse(0);
        schema.parse(-1);
      });
    });

    test('should fail for nonPositive', () {
      var schema = Validasi.number().nonPositive();

      expect(
          () => schema.parse(1),
          throwFieldError(
              name: 'nonPositive',
              message: 'field must be non-positive number'));
    });

    test('can customize field name on nonPositive', () {
      var schema = Validasi.number().nonPositive();

      expect(getMsg(schema.tryParse(1, path: 'id')),
          equals('id must be non-positive number'));
    });

    test('can customize default error message on nonPositive', () {
      var schema =
          Validasi.number().nonPositive(message: 'should be non-positive!');

      expect(getMsg(schema.tryParse(1)), equals('should be non-positive!'));
    });

    test('should pass for nonNegative', () {
      var schema = Validasi.number().nonNegative();

      shouldNotThrow(() {
        schema.parse(0);
        schema.parse(1);
      });
    });

    test('should fail for nonNegative', () {
      var schema = Validasi.number().nonNegative();

      expect(
          () => schema.parse(-1),
          throwFieldError(
              name: 'nonNegative',
              message: 'field must be non-negative number'));
    });

    test('can customize field name on nonNegative', () {
      var schema = Validasi.number().nonNegative();

      expect(getMsg(schema.tryParse(-1, path: 'id')),
          equals('id must be non-negative number'));
    });

    test('can customize default error message on nonNegative', () {
      var schema =
          Validasi.number().nonNegative(message: 'should be non-negative!');

      expect(getMsg(schema.tryParse(-1)), equals('should be non-negative!'));
    });

    test('should pass for gt', () {
      var schema = Validasi.number().gt(0);

      shouldNotThrow(() {
        schema.parse(1);
        schema.parse(10);
      });

      schema = Validasi.number().gt(5);

      shouldNotThrow(() {
        schema.parse(6);
        schema.parse(10);
      });
    });

    test('should fail for gt', () {
      var schema = Validasi.number().gt(0);

      expect(() => schema.parse(0),
          throwFieldError(name: 'gt', message: 'field must be greater than 0'));

      schema = Validasi.number().gt(5);

      expect(() => schema.parse(5),
          throwFieldError(name: 'gt', message: 'field must be greater than 5'));

      expect(() => schema.parse(4),
          throwFieldError(name: 'gt', message: 'field must be greater than 5'));
    });

    test('can customize field name on gt', () {
      var schema = Validasi.number().gt(0);

      expect(getMsg(schema.tryParse(0, path: 'id')),
          equals('id must be greater than 0'));
    });

    test('can customize default error message on gt', () {
      var schema =
          Validasi.number().gt(0, message: 'should be greater than 0!');

      expect(getMsg(schema.tryParse(0)), equals('should be greater than 0!'));
    });

    test('should pass for gte', () {
      var schema = Validasi.number().gte(0);

      shouldNotThrow(() {
        schema.parse(0);
        schema.parse(1);
        schema.parse(10);
      });

      schema = Validasi.number().gte(5);

      shouldNotThrow(() {
        schema.parse(5);
        schema.parse(6);
        schema.parse(10);
      });
    });

    test('should fail for gte', () {
      var schema = Validasi.number().gte(0);

      expect(
          () => schema.parse(-1),
          throwFieldError(
              name: 'gte',
              message: 'field must be greater than or equal to 0'));

      schema = Validasi.number().gte(5);

      expect(
          () => schema.parse(4),
          throwFieldError(
              name: 'gte',
              message: 'field must be greater than or equal to 5'));
    });

    test('can customize field name on gte', () {
      var schema = Validasi.number().gte(0);

      expect(getMsg(schema.tryParse(-1, path: 'id')),
          equals('id must be greater than or equal to 0'));
    });

    test('can customize default error message on gte', () {
      var schema =
          Validasi.number().gte(0, message: 'should be greater than 0!');

      expect(getMsg(schema.tryParse(-1)), equals('should be greater than 0!'));
    });

    test('should pass for lt', () {
      var schema = Validasi.number().lt(0);

      shouldNotThrow(() {
        schema.parse(-1);
        schema.parse(-10);
      });

      schema = Validasi.number().lt(5);

      shouldNotThrow(() {
        schema.parse(4);
        schema.parse(-10);
      });
    });

    test('should fail for lt', () {
      var schema = Validasi.number().lt(0);

      expect(() => schema.parse(0),
          throwFieldError(name: 'lt', message: 'field must be less than 0'));

      schema = Validasi.number().lt(5);

      expect(() => schema.parse(5),
          throwFieldError(name: 'lt', message: 'field must be less than 5'));

      expect(() => schema.parse(6),
          throwFieldError(name: 'lt', message: 'field must be less than 5'));
    });

    test('can customize field name on lt', () {
      var schema = Validasi.number().lt(0);

      expect(getMsg(schema.tryParse(0, path: 'id')),
          equals('id must be less than 0'));
    });

    test('can customize default error message on lt', () {
      var schema = Validasi.number().lt(0, message: 'should be less than 0!');

      expect(getMsg(schema.tryParse(0)), equals('should be less than 0!'));
    });

    test('should pass for lte', () {
      var schema = Validasi.number().lte(0);

      shouldNotThrow(() {
        schema.parse(0);
        schema.parse(-1);
        schema.parse(-10);
      });

      schema = Validasi.number().lte(5);

      shouldNotThrow(() {
        schema.parse(5);
        schema.parse(4);
        schema.parse(-10);
      });
    });

    test('should fail for lte', () {
      var schema = Validasi.number().lte(0);

      expect(() => schema.parse(1),
          throwFieldError(name: 'lte', message: 'field must be less than or equal to 0'));

      schema = Validasi.number().lte(5);

      expect(() => schema.parse(6),
          throwFieldError(name: 'lte', message: 'field must be less than or equal to 5'));
    });

    test('can customize field name on lte', () {
      var schema = Validasi.number().lte(0);

      expect(getMsg(schema.tryParse(1, path: 'id')),
          equals('id must be less than or equal to 0'));
    });

    test('can customize default error message on lte', () {
      var schema = Validasi.number().lte(0, message: 'should be less than 0!');

      expect(getMsg(schema.tryParse(1)), equals('should be less than 0!'));
    });

    test('should pass for finite', () {
      var schema = Validasi.number().finite();

      shouldNotThrow(() {
        schema.parse(1);
        schema.parse(0);
        schema.parse(-1);
      });
    });

    test('should fail for finite', () {
      var schema = Validasi.number().finite();

      expect(
          () => schema.parse(double.infinity),
          throwFieldError(
              name: 'finite', message: 'field must be finite number'));

      expect(
          () => schema.parse(double.negativeInfinity),
          throwFieldError(
              name: 'finite', message: 'field must be finite number'));

      expect(
          () => schema.parse(double.nan),
          throwFieldError(
              name: 'finite', message: 'field must be finite number'));
    });

    test('can customize field name on finite', () {
      var schema = Validasi.number().finite();

      expect(getMsg(schema.tryParse(double.infinity, path: 'id')),
          equals('id must be finite number'));
    });

    test('can customize default error message on finite', () {
      var schema =
          Validasi.number().finite(message: 'should be finite number!');

      expect(getMsg(schema.tryParse(double.infinity)),
          equals('should be finite number!'));
    });
  });
}
