import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass(generateFields: true)
class WithFields {
  @Validate<String>([MinLength(2)])
  final String name;
  const WithFields({required this.name});
}

@ValidateClass(generateFields: false)
class WithoutFields {
  @Validate<String>([MinLength(1)])
  final String code;
  const WithoutFields({required this.code});
}
