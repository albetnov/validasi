import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Registration {
  @Validate<String>([MinLength(3)])
  final String email;

  @Validate<String>([MinLength(3)])
  final String confirmEmail;

  final String? notes;

  const Registration({
    required this.email,
    required this.confirmEmail,
    this.notes,
  });
}

@ValidateClass()
class SimpleCross {
  @Validate<String>([MinLength(2)])
  final String name;
  const SimpleCross({required this.name});
}
