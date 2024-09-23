import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';

void main() {
  group('Date Validator Test', () {
    test('passes type check on value match date or null', () {
      var schema = Validasi.date();

      shouldNotThrow(() {
        schema.parse(DateTime(2024, 9, 9));
        schema.parse(null);
      });
    });

    test('fails type check on value not match date or not null', () {
      var schema = Validasi.date();

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type DateTime. Got bool instead.'));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(getName(result), equals('invalidType'));
      expect(result.value, isNull);
    });

    test('can attach transformer', () {
      var schema = Validasi.date(transformer: DateTransformer());

      var result = schema.parse('2024-09-23');

      expect(result.value, isA<DateTime>());
      expect(result.value!.isAtSameMomentAs(DateTime(2024, 9, 23)), isTrue);
    });

    test('parseAsync can also run custom rule', () async {
      var schema =
          Validasi.date().custom((value, fail) async => fail(':name is taken'));

      await expectLater(
          () => schema.parseAsync(DateTime(2024, 9, 10), path: 'date'),
          throwFieldError(name: 'custom', message: 'date is taken'));
    });

    test('tryParse can run custom rule', () {
      var schema =
          Validasi.date().custom((value, fail) => fail(':name is taken'));

      var result = schema.tryParse(DateTime(2024, 9, 10), path: 'date');

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, 'date is taken');
    });

    test('tryParseAsync can also run custom rule', () async {
      var schema =
          Validasi.date().custom((value, fail) async => fail(':name is taken'));

      var result =
          await schema.tryParseAsync(DateTime(2024, 9, 10), path: 'date');

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, 'date is taken');
    });

    test('should pass for required rule', () {
      var schema = Validasi.date().required();

      shouldNotThrow(() {
        schema.parse(DateTime.now());
      });
    });

    test('should fail for required rule', () {
      var schema = Validasi.date().required();

      expect(schema.tryParse(null).errors.first.name, 'required');
    });

    test('can customize field name on required message', () {
      var schema = Validasi.date().required();

      expect(schema.tryParse(null, path: 'date').errors.first.message,
          equals('date is required'));
    });

    test('can customize default error message on required', () {
      var schema = Validasi.date().required(message: 'fill this!');

      expect(schema.tryParse(null).errors.first.message, equals('fill this!'));
    });

    test('should pass for before rule', () {
      var schema = Validasi.date().before(DateTime(2024, 9, 10));

      expect(schema.parse(DateTime(2024, 9, 9)).isValid, isTrue,
          reason: 'Should pass with default day unit and difference');
    });

    test('should fail for before rule', () {
      var schema = Validasi.date().before(DateTime(2024, 9, 10));

      expect(
          () => schema.parse(DateTime(2024, 9, 10)),
          throwFieldError(
              name: 'before', message: 'field must be before 2024-09-10'));
      expect(
          () => schema.parse(DateTime(2024, 9, 11)),
          throwFieldError(
              name: 'before', message: 'field must be before 2024-09-10'));
    });

    test('should pass for before rule with unit and difference', () {
      var schema = Validasi.date()
          .before(DateTime(2024, 9, 10), unit: DateUnit.day, difference: 2);

      expect(() => schema.parse(DateTime(2024, 9, 9)),
          throwFieldError(name: 'before'));

      expect(schema.parse(DateTime(2024, 9, 8)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 9, 7)).isValid, isTrue);

      var schema2 =
          Validasi.date().before(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema2.parse(DateTime(2024, 9, 9)).isValid, isTrue);

      expect(() => schema2.parse(DateTime(2024, 10, 9)),
          throwFieldError(name: 'before'));

      var schema3 =
          Validasi.date().before(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema3.parse(DateTime(2024, 9, 9)).isValid, isTrue);

      expect(() => schema3.parse(DateTime(2025, 9, 30)),
          throwFieldError(name: 'before'));

      expect(() => schema3.parse(DateTime(2025, 1, 1)),
          throwFieldError(name: 'before'));
    });

    test('can customize path name for before rule', () {
      var schema = Validasi.date().before(DateTime(2024, 9, 10));

      expect(
          schema
              .tryParse(DateTime(2024, 9, 11), path: 'date')
              .errors
              .first
              .message,
          equals('date must be before 2024-09-10'));
    });

    test('can customize message for before rule', () {
      var schema = Validasi.date()
          .before(DateTime(2024, 9, 10), message: 'Must before!');

      expect(schema.tryParse(DateTime(2024, 9, 11)).errors.first.message,
          equals('Must before!'));
    });

    test('should pass for after rule', () {
      var schema = Validasi.date().after(DateTime(2024, 9, 10));

      expect(schema.parse(DateTime(2024, 9, 11)).isValid, isTrue,
          reason: 'Should pass with default day unit and difference');
    });

    test('should fail for after rule', () {
      var schema = Validasi.date().after(DateTime(2024, 9, 10));

      expect(
          () => schema.parse(DateTime(2024, 9, 10)),
          throwFieldError(
              name: 'after', message: 'field must be after 2024-09-10'));
      expect(
          () => schema.parse(DateTime(2024, 9, 9)),
          throwFieldError(
              name: 'after', message: 'field must be after 2024-09-10'));
    });

    test('should pass for after rule with unit and difference', () {
      var schema = Validasi.date()
          .after(DateTime(2024, 9, 10), unit: DateUnit.day, difference: 2);

      expect(() => schema.parse(DateTime(2024, 9, 11)),
          throwFieldError(name: 'after'));

      expect(schema.parse(DateTime(2024, 9, 12)).isValid, isTrue);

      var schema2 =
          Validasi.date().after(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema2.parse(DateTime(2024, 11, 9)).isValid, isTrue);

      expect(() => schema2.parse(DateTime(2024, 10, 6)),
          throwFieldError(name: 'after'));

      var schema3 =
          Validasi.date().after(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema3.parse(DateTime(2026, 1, 1)).isValid, isTrue);

      expect(() => schema3.parse(DateTime(2025, 10, 1)),
          throwFieldError(name: 'after'));

      expect(() => schema3.parse(DateTime(2026, 1, 0)),
          throwFieldError(name: 'after'));

      expect(() => schema3.parse(DateTime(2025, 1, 0)),
          throwFieldError(name: 'after'));
    });

    test('can customize path name for after rule', () {
      var schema = Validasi.date().after(DateTime(2024, 9, 10));

      expect(
          schema
              .tryParse(DateTime(2024, 9, 9), path: 'date')
              .errors
              .first
              .message,
          equals('date must be after 2024-09-10'));
    });

    test('can customize message for after rule', () {
      var schema =
          Validasi.date().after(DateTime(2024, 9, 10), message: 'Must after!');

      expect(schema.tryParse(DateTime(2024, 9, 10)).errors.first.message,
          equals('Must after!'));
    });

    test('should pass for beforeSame rule', () {
      var schema = Validasi.date().beforeSame(DateTime(2024, 9, 10));

      expect(schema.parse(DateTime(2024, 9, 9)).isValid, isTrue,
          reason: 'Should pass with default day unit and difference');

      expect(schema.parse(DateTime(2024, 9, 10)).isValid, isTrue,
          reason: 'Should pass, this is similar to difference = 0');
    });

    test('should fail for beforeSame rule', () {
      var schema = Validasi.date().beforeSame(DateTime(2024, 9, 10));

      expect(
          () => schema.parse(DateTime(2024, 9, 11)),
          throwFieldError(
              name: 'beforeSame',
              message: 'field must be before or equal 2024-09-10'));
    });

    test('should pass for beforeSame rule with unit', () {
      var schema = Validasi.date()
          .beforeSame(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema.parse(DateTime(2024, 9, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 10)).isValid, isTrue);

      expect(() => schema.parse(DateTime(2024, 10, 11)),
          throwFieldError(name: 'beforeSame'));

      var schema2 = Validasi.date()
          .beforeSame(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema2.parse(DateTime(2024, 9, 9)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 1)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 9, 30)).isValid, isTrue,
          reason: 'Still within same year should be allowed');

      expect(() => schema2.parse(DateTime(2025, 10, 2)),
          throwFieldError(name: 'beforeSame'));
    });

    test('can customize path name for beforeSame rule', () {
      var schema = Validasi.date().beforeSame(DateTime(2024, 9, 10));

      expect(getMsg(schema.tryParse(DateTime(2024, 9, 11), path: 'date')),
          equals('date must be before or equal 2024-09-10'));
    });

    test('can customize message for beforeSame rule', () {
      var schema = Validasi.date()
          .beforeSame(DateTime(2024, 9, 10), message: 'Must before or same!');

      expect(getMsg(schema.tryParse(DateTime(2024, 9, 11))),
          equals('Must before or same!'));
    });

    test('should pass for afterSame rule', () {
      var schema = Validasi.date().afterSame(DateTime(2024, 9, 10));

      expect(schema.parse(DateTime(2024, 9, 11)).isValid, isTrue,
          reason: 'Should pass with default day unit and difference');

      expect(schema.parse(DateTime(2024, 9, 10)).isValid, isTrue,
          reason: 'Should pass, this is similar to difference = 0');
    });

    test('should fail for afterSame rule', () {
      var schema = Validasi.date().afterSame(DateTime(2024, 9, 10));
      expect(
          () => schema.parse(DateTime(2024, 9, 9)),
          throwFieldError(
              name: 'afterSame',
              message: 'field must be after or equal 2024-09-10'));
    });

    test('should pass for afterSame rule with unit', () {
      var schema = Validasi.date()
          .afterSame(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema.parse(DateTime(2024, 11, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 11)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 10)).isValid, isTrue);

      expect(() => schema.parse(DateTime(2024, 10, 9)),
          throwFieldError(name: 'afterSame'));

      var schema2 =
          Validasi.date().afterSame(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema2.parse(DateTime(2026, 9, 9)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 1)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 2)).isValid, isTrue,
          reason: 'Still within same year should be allowed');

      expect(() => schema2.parse(DateTime(2025, 9, 30)),
          throwFieldError(name: 'afterSame'));
    });

    test('can customize path name for afterSame rule', () {
      var schema = Validasi.date().afterSame(DateTime(2024, 9, 10));

      expect(getMsg(schema.tryParse(DateTime(2024, 9, 9), path: 'date')),
          equals('date must be after or equal 2024-09-10'));
    });

    test('can customize message for afterSame rule', () {
      var schema = Validasi.date()
          .afterSame(DateTime(2024, 9, 10), message: 'Must after or same!');

      expect(getMsg(schema.tryParse(DateTime(2024, 9, 9))),
          equals('Must after or same!'));
    });
  });
}
