import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test.mocks.dart';

void main() {
  group('Date Validator Test', () {
    test('passes strict check on value match date or null', () {
      var schema = Validasi.date();

      shouldNotThrow(() {
        schema.parse(DateTime(2024, 9, 9));
        schema.parse(null);
      });
    });

    test('fails strict check on value not match date or not null', () {
      var schema = Validasi.date();

      throwFieldError(() => schema.parse(true),
          name: 'invalidType', message: 'field is not a valid DateTime');

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(getName(result), equals('invalidType'));
      expect(result.value, isNull);
    });

    test('can override message for type check', () {
      var schema = Validasi.date(message: 'Must date!');

      expect(getMsg(schema.tryParse(true)), 'Must date!');
    });

    test('allow conversion to DateTime on strict turned off', () {
      var schema = Validasi.date(strict: false);

      expect(
          schema
              .parse('2024-09-09')
              .value
              ?.isAtSameMomentAs(DateTime(2024, 9, 9)),
          isTrue);

      expect(schema.parse(null).value, isNull,
          reason: 'When passed null it should stay null, not converted');
    });

    test('can customize pattern for conversion on strict off', () {
      var schema = Validasi.date(strict: false, pattern: 'dd/MM/y');

      expect(
          schema
              .parse('09/09/2024')
              .value
              ?.isAtSameMomentAs(DateTime(2024, 9, 9)),
          isTrue);
    });

    test('invalid format resulting in null on strict off', () {
      var schema = Validasi.date(strict: false);

      expect(schema.parse('09/09/2024').value, isNull);
    });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.date(strict: false).custom((value, fail) {
        if (value?.isAtSameMomentAs(DateTime(2024, 9, 9)) ?? false) {
          return fail(':name should not be 2024-09-09');
        }

        return true;
      });

      expect(
          () => schema.parse('2024-09-09'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field should not be 2024-09-09')));

      shouldNotThrow(() => schema.parse('2024-09-10'));

      var mock = MockCustomRule<DateTime>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0] is DateTime &&
            args.positionalArguments[0]
                .isAtSameMomentAs(DateTime(2024, 9, 9))) {
          return args.positionalArguments[1](':name should not be 2024-09-09');
        }

        return true;
      });

      schema.customFor(mock);

      expect(
          () => schema.parse('2024-09-09'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field should not be 2024-09-09')));

      verify(mock.handle(DateTime(2024, 9, 9), any)).called(1);

      shouldNotThrow(() {
        schema.parse('2024-09-10');
      });
    });

    test('parseAsync can also run custom rule', () async {
      var schema =
          Validasi.date().custom((value, fail) async => fail(':name is taken'));

      await expectLater(
          () => schema.parseAsync(DateTime(2024, 9, 10), path: 'date'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'date is taken')));
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
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'before' &&
              e.message == 'field must be before 2024-09-10')));
      expect(
          () => schema.parse(DateTime(2024, 9, 11)),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'before' &&
              e.message == 'field must be before 2024-09-10')));
    });

    test('should pass for before rule with unit and difference', () {
      var schema = Validasi.date()
          .before(DateTime(2024, 9, 10), unit: DateUnit.day, difference: 2);

      expect(() => schema.parse(DateTime(2024, 9, 9)),
          throwsA(predicate((e) => e is FieldError && e.name == 'before')));

      expect(schema.parse(DateTime(2024, 9, 8)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 9, 7)).isValid, isTrue);

      var schema2 =
          Validasi.date().before(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema2.parse(DateTime(2024, 9, 9)).isValid, isTrue);

      expect(() => schema2.parse(DateTime(2024, 10, 9)),
          throwsA(predicate((e) => e is FieldError && e.name == 'before')));

      var schema3 =
          Validasi.date().before(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema3.parse(DateTime(2024, 9, 9)).isValid, isTrue);

      expect(() => schema3.parse(DateTime(2025, 9, 30)),
          throwsA(predicate((e) => e is FieldError && e.name == 'before')));

      expect(() => schema3.parse(DateTime(2025, 1, 1)),
          throwsA(predicate((e) => e is FieldError && e.name == 'before')));
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
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'after' &&
              e.message == 'field must be after 2024-09-10')));
      expect(
          () => schema.parse(DateTime(2024, 9, 9)),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'after' &&
              e.message == 'field must be after 2024-09-10')));
    });

    test('should pass for after rule with unit and difference', () {
      var schema = Validasi.date()
          .after(DateTime(2024, 9, 10), unit: DateUnit.day, difference: 2);

      expect(() => schema.parse(DateTime(2024, 9, 11)),
          throwsA(predicate((e) => e is FieldError && e.name == 'after')));

      expect(schema.parse(DateTime(2024, 9, 12)).isValid, isTrue);

      var schema2 =
          Validasi.date().after(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema2.parse(DateTime(2024, 11, 9)).isValid, isTrue);

      expect(() => schema2.parse(DateTime(2024, 10, 6)),
          throwsA(predicate((e) => e is FieldError && e.name == 'after')));

      var schema3 =
          Validasi.date().after(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema3.parse(DateTime(2026, 1, 1)).isValid, isTrue);

      expect(() => schema3.parse(DateTime(2025, 10, 1)),
          throwsA(predicate((e) => e is FieldError && e.name == 'after')));

      expect(() => schema3.parse(DateTime(2026, 1, 0)),
          throwsA(predicate((e) => e is FieldError && e.name == 'after')));

      expect(() => schema3.parse(DateTime(2025, 1, 0)),
          throwsA(predicate((e) => e is FieldError && e.name == 'after')));
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
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'beforeSame' &&
              e.message == 'field must be before or equal 2024-09-10')));
    });

    test('should pass for beforeSame rule with unit', () {
      var schema = Validasi.date()
          .beforeSame(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema.parse(DateTime(2024, 9, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 10)).isValid, isTrue);

      throwFieldError(() => schema.parse(DateTime(2024, 10, 11)),
          name: 'beforeSame');

      var schema2 = Validasi.date()
          .beforeSame(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema2.parse(DateTime(2024, 9, 9)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 1)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 9, 30)).isValid, isTrue,
          reason: 'Still within same year should be allowed');

      throwFieldError(() => schema2.parse(DateTime(2025, 10, 2)),
          name: 'beforeSame');
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
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'afterSame' &&
              e.message == 'field must be after or equal 2024-09-10')));
    });

    test('should pass for afterSame rule with unit', () {
      var schema = Validasi.date()
          .afterSame(DateTime(2024, 10, 10), unit: DateUnit.month);

      expect(schema.parse(DateTime(2024, 11, 9)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 11)).isValid, isTrue);
      expect(schema.parse(DateTime(2024, 10, 10)).isValid, isTrue);

      throwFieldError(() => schema.parse(DateTime(2024, 10, 9)),
          name: 'afterSame');

      var schema2 =
          Validasi.date().afterSame(DateTime(2025, 10, 1), unit: DateUnit.year);

      expect(schema2.parse(DateTime(2026, 9, 9)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 1)).isValid, isTrue);
      expect(schema2.parse(DateTime(2025, 10, 2)).isValid, isTrue,
          reason: 'Still within same year should be allowed');

      throwFieldError(() => schema2.parse(DateTime(2025, 9, 30)),
          name: 'afterSame');
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
