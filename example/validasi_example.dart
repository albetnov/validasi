import 'package:validasi/src/rules/nullable.dart';
import 'package:validasi/src/rules/string/max_length.dart';
import 'package:validasi/src/rules/string/min_length.dart';
import 'package:validasi/validasi.dart';

void main() {
  final schema = Validasi.string([
    Nullable(),
    MinLength(length: 3),
    MaxLength(length: 16),
  ]);

  final result1 = schema.validate(
    123,
    transform: (input) => input.toString(),
  );

  print(
      "is valid: ${result1.isValid}, errors: ${result1.errors.map((e) => e.message).join(', ')}. Type: ${result1.data.runtimeType}");

  final result2 =
      schema.validate(123).transform((value) => value == 'password');

  print(
      "is valid: ${result2.isValid}, errors: ${result2.errors.map((e) => e.message).join(', ')}. Type: ${result2.data.runtimeType}");

  final listSchema = Validasi.list(Validasi.string([Nullable()]));

  final result3 = listSchema.validate(['ok', 123]);

  print(
      "is valid: ${result3.isValid}, errors: ${result3.errors.map((e) => "${e.path}: ${e.message}").join(', ')}. Type: ${result3.data.runtimeType}");
}
