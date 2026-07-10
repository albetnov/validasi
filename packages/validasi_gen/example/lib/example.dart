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

class CustomDataClass {
  final int id;

  const CustomDataClass({required this.id});
}

@ValidateClass(generateSchema: false)
class User {
  @Validate<String>([MinLength(3), MaxLength(100), NoSpaces()])
  final String email;

  @Validate<String>(
      [MinLength(3), MaxLength(100), AsyncInline(_checkUsernameAvailable)])
  final String username;

  @Validate<String>([MinLength(3), MaxLength(100)])
  final String confirmEmail;

  @Validate<List<String>>([MinLength(1), Unique()])
  final List<String> tags;

  @Validate<String>([Email(), EndsWith('@example.com')])
  final String workEmail;

  @Validate<int>([Between(0, 150)])
  final int age;

  final Car car;

  final Car? spareCar;

  final List<Car> previousCars;

  @Validate<CustomDataClass?>([Required(), Inline(_validateCustomClass)])
  final CustomDataClass? customData;

  const User({
    required this.email,
    required this.username,
    required this.confirmEmail,
    required this.tags,
    required this.workEmail,
    required this.age,
    required this.car,
    this.spareCar,
    required this.previousCars,
    this.customData,
  });

  static bool _validateCustomClass(dynamic value) {
    if (value is! CustomDataClass) {
      return false;
    }

    return value.id > 0;
  }

  @RefineFn(dependsOn: ['email', 'confirmEmail'])
  static void emailMatchesConfirm(
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
  @Validate<String>([MinLength(2)])
  final String make;

  @Validate<String>([
    MinLength(2),
  ])
  final String model;

  const Car({required this.make, required this.model});
}

@ValidateClass(generateFields: false)
class InternalFoo {
  @Validate<String>([MinLength(1)])
  final String code;

  const InternalFoo({required this.code});
}

FutureOr<bool> _checkUsernameAvailable(String? value) async {
  await Future<void>.delayed(Duration.zero);
  return value != 'taken';
}

@ValidateClass(generateFields: false, generateSchema: false)
@RequiredAny(['email', 'phone'])
@MatchesField(field: 'password', matchesField: 'passwordConfirmation')
class ContactInfo {
  final String? email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;

  const ContactInfo({
    this.email,
    this.phone,
    this.password,
    this.passwordConfirmation,
  });
}
