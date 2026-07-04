import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Simple {
  @Validate<String>([MinLength(2), MaxLength(50)])
  final String name;
  const Simple({required this.name});
}

@ValidateClass()
class Mixed {
  @Validate<String>([MinLength(3)])
  final String name;

  final int age;

  @Validate<List<String>>([MinLength(1)])
  final List<String> tags;

  const Mixed({required this.name, required this.age, required this.tags});
}
