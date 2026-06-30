import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass(generateFields: true)
class User {
  @Validate<String>([MinLength(2), MaxLength(100)])
  final String name;

  @Validate<String>([MinLength(3), MaxLength(100)])
  final String email;

  @Validate<int>([
    OneOf<int>([1, 2, 3])
  ])
  final int age;

  const User({
    required this.name,
    required this.email,
    required this.age,
  });

  @RefineFn(dependsOn: ['name', 'email'])
  void emailDoesNotStartWithName(
    FailFn fail, {
    String? name,
    String? email,
  }) {
    if (email != null && name != null && email.startsWith(name)) {
      fail(
        message: 'Email should not start with name',
        path: ['email'],
      );
    }
  }
}
