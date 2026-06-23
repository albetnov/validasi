import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Simple {
  @Validate.string([MinLength(2), MaxLength(50)])
  final String name;
  const Simple({required this.name});
}

@ValidateClass()
class Mixed {
  @Validate.string([MinLength(3)])
  final String name;

  final int age;

  @Validate.iterable([MinLength(1)])
  final List<String> tags;

  const Mixed({required this.name, required this.age, required this.tags});
}
