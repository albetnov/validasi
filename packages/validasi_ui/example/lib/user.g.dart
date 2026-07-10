// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const ValidasiSchema<User> schema = _UserSchema();

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
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value!.length < 2) {
      $errors.add(_Errors.minLength([name], 2));
    }
    if (value != null && value!.length > 100) {
      $errors.add(_Errors.maxLength([name], 100));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
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
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value!.length < 3) {
      $errors.add(_Errors.minLength([name], 3));
    }
    if (value != null && value!.length > 100) {
      $errors.add(_Errors.maxLength([name], 100));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
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
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && ![1, 2, 3].contains(value)) {
      $errors.add(_Errors.oneOf([name], [1, 2, 3]));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<int>> validateAsync(int? value) async {
    return validate(value);
  }
}

class _UserSchema extends ValidasiSchema<User> {
  const _UserSchema();

  @override
  User allocate(ValidasiFieldReader<User> reader) {
    return User(
      name: reader.getValue(UserFields.name) as String,
      email: reader.getValue(UserFields.email) as String,
      age: reader.getValue(UserFields.age) as int,
    );
  }
}

extension $UserValidasi on User {
  ValidasiResult<User> validate() {
    final $errors = <ValidationError>[];
    // Field: name
    if (name.length < 2) {
      $errors.add(_Errors.minLength(['name'], 2));
    }
    if (name.length > 100) {
      $errors.add(_Errors.maxLength(['name'], 100));
    }
    // Field: email
    if (email.length < 3) {
      $errors.add(_Errors.minLength(['email'], 3));
    }
    if (email.length > 100) {
      $errors.add(_Errors.maxLength(['email'], 100));
    }
    // Field: age
    if (![1, 2, 3].contains(age)) {
      $errors.add(_Errors.oneOf(['age'], [1, 2, 3]));
    }
    final $fail_User_emailDoesNotStartWithName =
        ({required String message, List<String> path = const []}) {
          $errors.add(
            ValidationError(
              rule: 'Refine',
              message: message,
              path: path.isEmpty ? null : path,
            ),
          );
        };
    User.emailDoesNotStartWithName(
      $fail_User_emailDoesNotStartWithName,
      name: name,
      email: email,
    );
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<User>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: name
    if (name.length < 2) {
      $errors.add(_Errors.minLength(['name'], 2));
    }
    if (name.length > 100) {
      $errors.add(_Errors.maxLength(['name'], 100));
    }
    // Field: email
    if (email.length < 3) {
      $errors.add(_Errors.minLength(['email'], 3));
    }
    if (email.length > 100) {
      $errors.add(_Errors.maxLength(['email'], 100));
    }
    // Field: age
    if (![1, 2, 3].contains(age)) {
      $errors.add(_Errors.oneOf(['age'], [1, 2, 3]));
    }
    final $fail_User_emailDoesNotStartWithName =
        ({required String message, List<String> path = const []}) {
          $errors.add(
            ValidationError(
              rule: 'Refine',
              message: message,
              path: path.isEmpty ? null : path,
            ),
          );
        };
    User.emailDoesNotStartWithName(
      $fail_User_emailDoesNotStartWithName,
      name: name,
      email: email,
    );
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  ValidasiResult<V> validateField<V>(UserFields<V> field) {
    return field.validate(field.extract(this));
  }

  Future<ValidasiResult<V>> validateFieldAsync<V>(UserFields<V> field) async {
    return field.validateAsync(field.extract(this));
  }
}

abstract final class _Errors {
  static ValidationError required(List<String> path, {String? message}) =>
      ValidationError(
        rule: 'Required',
        message: message ?? 'Field is required',
        path: path,
      );

  static ValidationError minLength(
    List<String> path,
    int length, {
    String? message,
  }) => ValidationError(
    rule: 'MinLength',
    message: message ?? 'Minimum length is $length characters',
    details: {'length': '$length'},
    path: path,
  );

  static ValidationError maxLength(
    List<String> path,
    int length, {
    String? message,
  }) => ValidationError(
    rule: 'MaxLength',
    message: message ?? 'Maximum length is $length characters',
    details: {'length': '$length'},
    path: path,
  );

  static ValidationError oneOf(
    List<String> path,
    List<Object?> options, {
    String? message,
  }) => ValidationError(
    rule: 'OneOf',
    message: message ?? 'Value must be one of: ${options.join(", ")}',
    details: {'options': '${options.join(",")}'},
    path: path,
  );
}

abstract final class _Result {
  static ValidasiResult<T> from<T>(List<ValidationError> errors, T? value) =>
      errors.isEmpty
      ? ValidasiResult(errors: const [], isValid: true, data: value)
      : ValidasiResult(errors: errors, isValid: false);

  static ValidasiResult<T> invalidSingle<T>(ValidationError error) =>
      ValidasiResult(errors: [error], isValid: false);
}
