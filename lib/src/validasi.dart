import 'package:validasi/src/validators/array_validator.dart';
import 'package:validasi/src/validators/date_validator.dart';
import 'package:validasi/src/validators/number_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/string_validator.dart';
import 'package:validasi/src/validators/validator.dart';

/// This class reponsible to group available Validators to a single class.
class Validasi {
  static StringValidator string({bool strict = true, String? message}) =>
      StringValidator(strict: strict, message: message);

  static ObjectValidator<T> object<T extends Map>(
          Map<String, Validator> schema) =>
      ObjectValidator<T>(schema);

  static ArrayValidator<V, T> array<V extends Validator, T>(V validator) =>
      ArrayValidator<V, T>(validator);

  static NumberValidator number({bool strict = true, String? message}) =>
      NumberValidator(strict: strict, message: message);

  static DateValidator date(
          {String pattern = 'y-MM-dd', bool strict = true, String? message}) =>
      DateValidator(pattern: pattern, strict: strict, message: message);
}
