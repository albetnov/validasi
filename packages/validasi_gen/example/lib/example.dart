import 'dart:async';

import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'example.g.dart';

@ValidateClass(generateAssemble: false)
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate.string(
      [MinLength(3), MaxLength(100), AsyncInline(_checkUsernameAvailable)])
  final String username;

  @Validate.string([MinLength(3), MaxLength(100)])
  @ValidateWith(_checkEmailMatch, dependsOn: {#email})
  final String confirmEmail;

  @Validate.iterable([MinLength(1)])
  final List<String> tags;

  final Car car;

  final Car? spareCar;

  final List<Car> previousCars;

  const User({
    required this.email,
    required this.username,
    required this.confirmEmail,
    required this.tags,
    required this.car,
    this.spareCar,
    required this.previousCars,
  });
}

@ValidateClass(generateAssemble: false)
class Car {
  @Validate.string([MinLength(2)])
  final String make;

  @Validate.string([
    MinLength(2),
  ])
  final String model;

  const Car({required this.make, required this.model});
}

@ValidateClass(generateFields: false)
class InternalFoo {
  @Validate.string([MinLength(1)])
  final String code;

  const InternalFoo({required this.code});
}

String? _checkEmailMatch(V? Function<V>(ValidasiField<User, V>) get) {
  final email = get(UserFields.email);
  final confirm = get(UserFields.confirmEmail);
  if (email != null && confirm != null && email != confirm) {
    return 'Emails do not match';
  }
  return null;
}

FutureOr<bool> _checkUsernameAvailable(String? value) async {
  await Future<void>.delayed(Duration.zero);
  return value != 'taken';
}
