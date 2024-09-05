import 'package:test/test.dart';
import 'package:validasi/src/validasi.dart';
import 'package:validasi/src/validators/array_validator.dart';
import 'package:validasi/src/validators/date_validator.dart';
import 'package:validasi/src/validators/number_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/string_validator.dart';
import 'package:validasi/src/validators/validator.dart';

void main() {
  group('Validasi Test', () {
    test('return valid String signature', () {
      expect(Validasi.string,
          isA<StringValidator Function({bool strict, String? message})>());

      expect(Validasi.string(), isA<StringValidator>());
    });

    test('return valid Number signature', () {
      expect(Validasi.number,
          isA<NumberValidator Function({bool strict, String? message})>());

      expect(Validasi.number(), isA<NumberValidator>());
    });

    test('return valid Array signature', () {
      expect(Validasi.array,
          isA<ArrayValidator<V, T> Function<V extends Validator, T>(V)>());

      expect(Validasi.array(Validasi.string()),
          isA<ArrayValidator<StringValidator, dynamic>>());
    });

    test('return valid Object signature', () {
      expect(
          Validasi.object,
          isA<
              ObjectValidator<T> Function<T extends Map>(
                  Map<String, Validator>)>());

      expect(Validasi.object({}), isA<ObjectValidator>());
    });

    test('return valid Date signature', () {
      expect(
          Validasi.date,
          isA<
              DateValidator Function(
                  {String pattern, bool strict, String? message})>());

      expect(Validasi.date(), isA<DateValidator>());
    });
  });
}
