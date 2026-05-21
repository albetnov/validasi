import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi_annotation/annotation.dart';

part 'example.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  User({required this.email});
}
