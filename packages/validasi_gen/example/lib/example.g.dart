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

    // Field: tags

    if (tags != null && tags.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'List must have at least 1 items',
          details: {'length': '1'},
          path: ['tags'],
        ),
      );
    }

    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: [], isValid: true, data: this);
  }
}

extension $CarValidasi on Car {
  ValidasiResult<Car> validate() {
    final $errors = <ValidationError>[];

    // Field: make

    if (make != null && make.length < 2) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: ['make'],
        ),
      );
    }

    // Field: model

    if (model != null && model.length < 2) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: ['model'],
        ),
      );
    }

    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: [], isValid: true, data: this);
  }
}
