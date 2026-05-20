// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

extension $UserValidasi on User {
  ValidasiResult<User> validate() {
    final $errors = <ValidationError>[];

    // Field: email

    if (email != null && email.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: ['email'],
        ),
      );
    }

    if (email != null && email.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: ['email'],
        ),
      );
    }

    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: [], isValid: true, data: this);
  }
}
