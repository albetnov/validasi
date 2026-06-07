import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

String? _emailMatchesName(V? Function<V>(ValidasiField<User, V>) get) {
  final email = get(UserFields.email);
  final name = get(UserFields.name);
  if (email != null && name != null && email.startsWith(name)) {
    return 'Email should not start with name';
  }
  return null;
}

@ValidateClass(generateFields: true)
class User {
  @Validate.string([MinLength(2), MaxLength(100)])
  final String name;

  @Validate.string([MinLength(3), MaxLength(100)])
  @ValidateWith(_emailMatchesName, dependsOn: {#name})
  final String email;

  @Validate([MinLength(1)])
  final int age;

  const User({
    required this.name,
    required this.email,
    required this.age,
  });
}
