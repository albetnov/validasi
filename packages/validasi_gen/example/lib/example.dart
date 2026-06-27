import 'dart:async';

import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'example.g.dart';

// Custom rule example — define a class extending CustomRule<T>,
// with a static bool check(T? value, {required ...}) method.
class NoSpaces extends CustomRule<String> {
  const NoSpaces({String? message, super.runOnNull})
      : super(name: 'noSpaces', message: message);

  static bool check(String? value) => value == null || !value.contains(' ');
}

@ValidateClass(generateSchema: false)
class User {
  @Validate.string([MinLength(3), MaxLength(100), NoSpaces()])
  final String email;

  @Validate.string(
      [MinLength(3), MaxLength(100), AsyncInline(_checkUsernameAvailable)])
  final String username;

  @Validate.string([MinLength(3), MaxLength(100)])
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

  @RefineFn(dependsOn: ['email', 'confirmEmail'])
  void emailMatchesConfirm(
    FailFn fail, {
    String? email,
    String? confirmEmail,
  }) {
    if (email != null && confirmEmail != null && email != confirmEmail) {
      fail(message: 'Emails do not match', path: ['confirmEmail']);
    }
  }
}

@ValidateClass(generateSchema: false)
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

FutureOr<bool> _checkUsernameAvailable(String? value) async {
  await Future<void>.delayed(Duration.zero);
  return value != 'taken';
}
