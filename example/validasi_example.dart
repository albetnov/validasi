import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/rules/nullable.dart';
import 'package:validasi/src/rules/string/max_length.dart';
import 'package:validasi/src/rules/string/min_length.dart';
import 'package:validasi/src/rules/transform.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';
import 'package:validasi/validasi.dart';

void log(ValidasiResult result) {
  print(
      "isValid: ${result.isValid}, errors: ${result.errors.map((e) => e.message).join(', ')}, value: ${result.data}, type: ${result.data.runtimeType}");
}

void main() {
  final schema = Validasi.string([
    Nullable(),
    Transform((input) => input.trim()),
    MinLength(3),
    MaxLength(16)
  ]);

  final transformableSchema = schema.withPreprocess(
    ValidasiTransformation(
      (value) => value.toString(),
    ),
  );

  final result = schema.validate('   Hello World!   ');
  log(result);

  final testTransform = transformableSchema.validate(1234);
  log(testTransform);

  final failResult = schema.validate('Hi');
  log(failResult);

  final transformFailResult = transformableSchema.validate(12);
  log(transformFailResult);
}
