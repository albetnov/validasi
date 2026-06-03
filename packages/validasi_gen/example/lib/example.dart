import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'example.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate.iterable([MinLength(1)])
  final List<String> tags;

  User({required this.email, required this.tags});
}
