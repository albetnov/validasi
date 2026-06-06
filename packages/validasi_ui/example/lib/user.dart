import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass(generateFields: true)
class User {
  @Validate.string([MinLength(2), MaxLength(100)])
  final String name;

  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate([MinLength(1)])
  final int age;

  const User({
    required this.name,
    required this.email,
    required this.age,
  });
}
