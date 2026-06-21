// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const UserFields<String> email = UserEmailField();

  static const UserFields<String> username = UserUsernameField();

  static const UserFields<String> confirmEmail = UserConfirmEmailField();

  static const UserFields<List<String>> tags = UserTagsField();

  static const UserFields<Car> car = UserCarField();

  static const UserFields<Car?> spareCar = UserSpareCarField();

  static const UserFields<List<Car>> previousCars = UserPreviousCarsField();
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

class UserUsernameField extends UserFields<String> {
  const UserUsernameField() : super._();

  @override
  String get name {
    return 'username';
  }

  @override
  String extract(User owner) {
    return owner.username;
  }

  @override
  ValidasiResult<String> validate(String? value) {
    throw StateError(
      'Async rules cannot be used with validate(). Use validateAsync() instead.',
    );
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
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
    try {
      if (!await _checkUsernameAvailable(value)) {
        $errors.add(
          ValidationError(
            rule: 'async_inline',
            message: 'Validation failed',
            path: [name],
          ),
        );
      }
    } catch (e) {
      $errors.add(
        ValidationError(
          rule: 'async_inline',
          message: e.toString(),
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

class UserConfirmEmailField extends UserFields<String> {
  const UserConfirmEmailField() : super._();

  @override
  String get name {
    return 'confirmEmail';
  }

  @override
  String extract(User owner) {
    return owner.confirmEmail;
  }

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

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class UserTagsField extends UserFields<List<String>> {
  const UserTagsField() : super._();

  @override
  String get name {
    return 'tags';
  }

  @override
  List<String> extract(User owner) {
    return owner.tags;
  }

  @override
  ValidasiResult<List<String>> validate(List<String>? value) {
    final $errors = <ValidationError>[];
    if (value != null && value.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'List must have at least 1 items',
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
  Future<ValidasiResult<List<String>>> validateAsync(
    List<String>? value,
  ) async {
    return validate(value);
  }
}

class UserCarField extends UserFields<Car> {
  const UserCarField() : super._();

  @override
  String get name {
    return 'car';
  }

  @override
  Car extract(User owner) {
    return owner.car;
  }

  @override
  ValidasiResult<Car> validate(Car? value) {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $carResult = value.validate();
    if (!$carResult.isValid) {
      return ValidasiResult(
        errors: $carResult.errors.map((e) => e..prefix(name)).toList(),
        isValid: false,
      );
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }

  @override
  Future<ValidasiResult<Car>> validateAsync(Car? value) async {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $carResult = await value.validateAsync();
    if (!$carResult.isValid) {
      return ValidasiResult(
        errors: $carResult.errors.map((e) => e..prefix(name)).toList(),
        isValid: false,
      );
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

class UserSpareCarField extends UserFields<Car?> {
  const UserSpareCarField() : super._();

  @override
  String get name {
    return 'spareCar';
  }

  @override
  Car? extract(User owner) {
    return owner.spareCar;
  }

  @override
  ValidasiResult<Car?> validate(Car? value) {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $spareCarResult = value.validate();
    if (!$spareCarResult.isValid) {
      return ValidasiResult(
        errors: $spareCarResult.errors.map((e) => e..prefix(name)).toList(),
        isValid: false,
      );
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }

  @override
  Future<ValidasiResult<Car?>> validateAsync(Car? value) async {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $spareCarResult = await value.validateAsync();
    if (!$spareCarResult.isValid) {
      return ValidasiResult(
        errors: $spareCarResult.errors.map((e) => e..prefix(name)).toList(),
        isValid: false,
      );
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

class UserPreviousCarsField extends UserFields<List<Car>> {
  const UserPreviousCarsField() : super._();

  @override
  String get name {
    return 'previousCars';
  }

  @override
  List<Car> extract(User owner) {
    return owner.previousCars;
  }

  @override
  ValidasiResult<List<Car>> validate(List<Car>? value) {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $errors = <ValidationError>[];
    for (var $previousCarsIndex = 0;
        $previousCarsIndex < value.length;
        $previousCarsIndex++) {
      final $previousCarsItem = value[$previousCarsIndex];
      final $previousCarsResult = $previousCarsItem.validate();
      if (!$previousCarsResult.isValid) {
        $errors.addAll(
          $previousCarsResult.errors.map(
            (e) => e..prefix("$name[${$previousCarsIndex}]"),
          ),
        );
      }
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }

  @override
  Future<ValidasiResult<List<Car>>> validateAsync(List<Car>? value) async {
    if (value == null) {
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $errors = <ValidationError>[];
    for (var $previousCarsIndex = 0;
        $previousCarsIndex < value.length;
        $previousCarsIndex++) {
      final $previousCarsItem = value[$previousCarsIndex];
      final $previousCarsResult = await $previousCarsItem.validateAsync();
      if (!$previousCarsResult.isValid) {
        $errors.addAll(
          $previousCarsResult.errors.map(
            (e) => e..prefix("$name[${$previousCarsIndex}]"),
          ),
        );
      }
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: value);
  }
}

extension $UserValidasi on User {
  ValidasiResult<User> validate() {
    throw StateError(
      'Async rules cannot be used with validate(). Use validateAsync() instead.',
    );
  }

  Future<ValidasiResult<User>> validateAsync() async {
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
    // Field: username
    if (username != null && username.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: ['username'],
        ),
      );
    }
    if (username != null && username.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: ['username'],
        ),
      );
    }
    try {
      if (!await _checkUsernameAvailable(username)) {
        $errors.add(
          ValidationError(
            rule: 'async_inline',
            message: 'Validation failed',
            path: ['username'],
          ),
        );
      }
    } catch (e) {
      $errors.add(
        ValidationError(
          rule: 'async_inline',
          message: e.toString(),
          path: ['username'],
        ),
      );
    }
    // Field: confirmEmail
    if (confirmEmail != null && confirmEmail.length < 3) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 3 characters',
          details: {'length': '3'},
          path: ['confirmEmail'],
        ),
      );
    }
    if (confirmEmail != null && confirmEmail.length > 100) {
      $errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: 'Maximum length is 100 characters',
          details: {'length': '100'},
          path: ['confirmEmail'],
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
    // Field: car (nested Car)
    final $carResult = await car.validateAsync();
    if (!$carResult.isValid) {
      $errors.addAll($carResult.errors.map((e) => e..prefix('car')));
    }
    // Field: spareCar (nested Car)
    final $spareCarValue = spareCar;
    if ($spareCarValue != null) {
      final $spareCarResult = await $spareCarValue.validateAsync();
      if (!$spareCarResult.isValid) {
        $errors.addAll(
          $spareCarResult.errors.map((e) => e..prefix('spareCar')),
        );
      }
    }
    // Field: previousCars (nested Car)
    for (var $previousCarsIndex = 0;
        $previousCarsIndex < previousCars.length;
        $previousCarsIndex++) {
      final $previousCarsItem = previousCars[$previousCarsIndex];
      final $previousCarsItemResult = await $previousCarsItem.validateAsync();
      if (!$previousCarsItemResult.isValid) {
        $errors.addAll(
          $previousCarsItemResult.errors.map(
            (e) => e..prefix('previousCars[${$previousCarsIndex}]'),
          ),
        );
      }
    }
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

sealed class CarFields<V> extends ValidasiKey<Car>
    implements ValidasiField<Car, V> {
  const CarFields._();

  static const CarFields<String> make = CarMakeField();

  static const CarFields<String> model = CarModelField();
}

class CarMakeField extends CarFields<String> {
  const CarMakeField() : super._();

  @override
  String get name {
    return 'make';
  }

  @override
  String extract(Car owner) {
    return owner.make;
  }

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

class CarModelField extends CarFields<String> {
  const CarModelField() : super._();

  @override
  String get name {
    return 'model';
  }

  @override
  String extract(Car owner) {
    return owner.model;
  }

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
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<Car>> validateAsync() async {
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
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  ValidasiResult<V> validateField<V>(CarFields<V> field) {
    return field.validate(field.extract(this));
  }

  Future<ValidasiResult<V>> validateFieldAsync<V>(CarFields<V> field) async {
    return field.validateAsync(field.extract(this));
  }
}

extension $InternalFooValidasi on InternalFoo {
  ValidasiResult<InternalFoo> validate() {
    final $errors = <ValidationError>[];
    // Field: code
    if (code != null && code.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: ['code'],
        ),
      );
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<InternalFoo>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: code
    if (code != null && code.length < 1) {
      $errors.add(
        ValidationError(
          rule: 'MinLength',
          message: 'Minimum length is 1 characters',
          details: {'length': '1'},
          path: ['code'],
        ),
      );
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }
}
