import 'package:validasi/src/transformers/transformer.dart';
import 'package:validasi/src/validators/array_validator.dart';
import 'package:validasi/src/validators/date_validator.dart';
import 'package:validasi/src/validators/generic_validator.dart';
import 'package:validasi/src/validators/number_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/string_validator.dart';
import 'package:validasi/src/validators/validator.dart';

/// This class reponsible to group available Validators to a single class.
class Validasi {
  static StringValidator string({Transformer<String>? transformer}) =>
      StringValidator(transformer: transformer);

  static ObjectValidator<T> object<T extends Map>(
          Map<String, Validator> schema) =>
      ObjectValidator<T>(schema);

  static ArrayValidator<V, T> array<V extends Validator, T>(V validator,
          {String? message}) =>
      ArrayValidator<V, T>(validator);

  static NumberValidator number({Transformer<num>? transformer}) =>
      NumberValidator(transformer: transformer);

  static DateValidator date(
          {String pattern = 'y-MM-dd', Transformer<DateTime>? transformer}) =>
      DateValidator(pattern: pattern, transformer: transformer);

  static GenericValidator<T> generic<T>({Transformer<T>? transformer}) =>
      GenericValidator<T>(transformer: transformer);
}
