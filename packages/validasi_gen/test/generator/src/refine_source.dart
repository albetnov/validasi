import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Registration {
  @Validate<String>([MinLength(3)])
  final String name;

  @Validate<String>([MinLength(3)])
  final String email;

  const Registration({required this.name, required this.email});

  @RefineFn(dependsOn: ['name', 'email'])
  void emailMustContainName(
    FailFn fail, {
    String? name,
    String? email,
  }) {
    if (email != null && name != null && !email.contains(name)) {
      fail(message: 'Email must contain name', path: ['email']);
    }
  }
}
