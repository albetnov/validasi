import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass(generateIndexedFields: true)
class Struct {
  @Validate<String>([MinLength(2)])
  final String name;

  @Validate<int>([
    OneOf<int>([1, 2])
  ])
  final int count;

  const Struct({required this.name, required this.count});
}
