import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Registration {
  @Validate.string([MinLength(3)])
  final String email;

  @Validate.string([MinLength(3)])
  @ValidateWith(_checkEmailMatch, dependsOn: {#email})
  final String confirmEmail;

  const Registration({required this.email, required this.confirmEmail});
}

String? _checkEmailMatch(V? Function<V>(ValidasiField<Registration, V>) get) {
  return null;
}

@ValidateClass()
class SimpleCross {
  @Validate.string([MinLength(2)])
  final String name;
  const SimpleCross({required this.name});
}
