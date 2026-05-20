import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

part 'example.g.dart';

@Validasi()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  User({required this.email});
}
