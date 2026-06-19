import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void log(ValidasiResult result) {
  print(
      "isValid: ${result.isValid}, errors: ${result.errors.map((e) => e.message).join(', ')}, value: ${result.data}, type: ${result.data.runtimeType}");
}

void main() {
  final schema = Validasi.string([
    Rules.nullable<String>(),
    Rules.transform<String>((input) => input?.trim()),
    Rules.string.minLength(3),
    Rules.string.maxLength(16)
  ]);

  final testNullable = schema.validate(null);
  log(testNullable);

  final transformableSchema =
      schema.withPreprocess<int>((value) => value.toString());

  final result = schema.validate('   Hello World!   ');
  log(result);

  final testTransform = transformableSchema.validate(1234);

  log(testTransform);

  final failResult = schema.validate('Hi');
  log(failResult);

  final transformFailResult = transformableSchema.validate(12);
  log(transformFailResult);
}
