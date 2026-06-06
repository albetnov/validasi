// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const UserFields<String> name = UserNameField();
  static const UserFields<String> email = UserEmailField();
  static const UserFields<int> age = UserAgeField();
}

class UserNameField extends UserFields<String> {
  const UserNameField() : super._();

  @override
  String get name => 'name';

  @override
  String extract(User owner) => owner.name;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];

    if (value != null && value.length < 2) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: [name],
        ),
      );
    }

    if (value != null && value.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: [name],
        ),
      );
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

class UserEmailField extends UserFields<String> {
  const UserEmailField() : super._();

  @override
  String get name => 'email';

  @override
  String extract(User owner) => owner.email;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];

    if (value != null && value.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: [name],
        ),
      );
    }

    if (value != null && value.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: [name],
        ),
      );
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

class UserAgeField extends UserFields<int> {
  const UserAgeField() : super._();

  @override
  String get name => 'age';

  @override
  int extract(User owner) => owner.age;

  @override
  ValidasiResult<int> validate(int? value) {
    final $errors = <ValidationError>[];

    if (value != null && value.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: [name],
        ),
      );
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

extension $UserValidasi on User {
  ValidasiResult<User> validate() {
    final $errors = <ValidationError>[];

    // Field: name

    if (name != null && name.length < 2) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: ['name'],
        ),
      );
    }

    if (name != null && name.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: ['name'],
        ),
      );
    }

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

    // Field: age

    if (age != null && age.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: ['age'],
        ),
      );
    }

    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  ValidasiResult<V> validateField<V>(UserFields<V> field) {
    return field.validate(field.extract(this));
  }
}
