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
  String get name {
    return 'name';
  }

  @override
  String extract(User owner) {
    return owner.name;
  }

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(
        ValidationError(
          rule: 'Required',
          message: 'Field is required',
          path: [name],
        ),
      );
    }
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

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class UserEmailField extends UserFields<String> {
  const UserEmailField() : super._();

  @override
  String get name {
    return 'email';
  }

  @override
  String extract(User owner) {
    return owner.email;
  }

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(
        ValidationError(
          rule: 'Required',
          message: 'Field is required',
          path: [name],
        ),
      );
    }
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

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class UserAgeField extends UserFields<int> {
  const UserAgeField() : super._();

  @override
  String get name {
    return 'age';
  }

  @override
  int extract(User owner) {
    return owner.age;
  }

  @override
  ValidasiResult<int> validate(int? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(
        ValidationError(
          rule: 'Required',
          message: 'Field is required',
          path: [name],
        ),
      );
    }
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
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: ['name'],
        ),
      );
    }
    if (name.length > 100) {
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
    if (email.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: ['email'],
        ),
      );
    }
    if (email.length > 100) {
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
    if (age.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: ['age'],
        ),
      );
    }
    final $fail = ({required String message, List<String> path = const []}) {
      $errors.add(
        ValidationError(
          rule: 'Refine',
          message: message,
          path: path.isEmpty ? null : path,
        ),
      );
    };
    emailDoesNotStartWithName($fail, name: name, email: email);
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<User>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: name
    if (name.length < 2) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 2 characters',
          details: {'length': '2'},
          path: ['name'],
        ),
      );
    }
    if (name.length > 100) {
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
    if (email.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: ['email'],
        ),
      );
    }
    if (email.length > 100) {
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
    if (age.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: ['age'],
        ),
      );
    }
    final $fail = ({required String message, List<String> path = const []}) {
      $errors.add(
        ValidationError(
          rule: 'Refine',
          message: message,
          path: path.isEmpty ? null : path,
        ),
      );
    };
    emailDoesNotStartWithName($fail, name: name, email: email);
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
