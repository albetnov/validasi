import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass(generateIndexedFields: true)
class Struct {
  @Validate.string([MinLength(2)])
  final String name;

  @Validate([MinLength(1)])
  final int count;

  const Struct({required this.name, required this.count});
}
