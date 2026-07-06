// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const UserFields<String> email = UserEmailField();

  static const UserFields<String> username = UserUsernameField();

  static const UserFields<String> confirmEmail = UserConfirmEmailField();

  static const UserFields<List<String>> tags = UserTagsField();

  static const UserFields<String> workEmail = UserWorkEmailField();

  static const UserFields<int> age = UserAgeField();

  static const UserFields<Car> car = UserCarField();

  static const UserFields<Car?> spareCar = UserSpareCarField();

  static const UserFields<List<Car>> previousCars = UserPreviousCarsField();

  static const UserFields<CustomDataClass?> customData = UserCustomDataField();
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
    if (value != null && value.length < 3) {
      $errors.add(_Errors.minLength([name], 3));
    }
    if (value != null && value.length > 100) {
      $errors.add(_Errors.maxLength([name], 100));
    }
    if (value != null && !NoSpaces.check(value)) {
      $errors.add(
        _Errors.inline([name], 'noSpaces', 'noSpaces: validation failed.'),
      );
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class UserUsernameField extends UserFields<String> {
  const UserUsernameField() : super._();

  @override
  String get name => 'username';

  @override
  String extract(User owner) => owner.username;

  @override
  ValidasiResult<String> validate(String? value) {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
    }
    throw StateError(
      'Async rules cannot be used with validate(). Use validateAsync() instead.',
    );
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value.length < 3) {
      $errors.add(_Errors.minLength([name], 3));
    }
    if (value != null && value.length > 100) {
      $errors.add(_Errors.maxLength([name], 100));
    }
    try {
      if (!await _checkUsernameAvailable(value)) {
        $errors.add(
          _Errors.inline([name], 'async_inline', 'Validation failed'),
        );
      }
    } catch (e) {
      $errors.add(_Errors.inline([name], 'async_inline', e.toString()));
    }
    return _Result.from($errors, value);
  }
}

class UserConfirmEmailField extends UserFields<String> {
  const UserConfirmEmailField() : super._();

  @override
  String get name => 'confirmEmail';

  @override
  String extract(User owner) => owner.confirmEmail;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value.length < 3) {
      $errors.add(_Errors.minLength([name], 3));
    }
    if (value != null && value.length > 100) {
      $errors.add(_Errors.maxLength([name], 100));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class UserTagsField extends UserFields<List<String>> {
  const UserTagsField() : super._();

  @override
  String get name => 'tags';

  @override
  List<String> extract(User owner) => owner.tags;

  @override
  ValidasiResult<List<String>> validate(List<String>? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value.length < 1) {
      $errors.add(_Errors.itMinLength([name], 1));
    }
    if (value != null && value.toSet().length != value.length) {
      $errors.add(_Errors.unique([name]));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<List<String>>> validateAsync(
    List<String>? value,
  ) async {
    return validate(value);
  }
}

class UserWorkEmailField extends UserFields<String> {
  const UserWorkEmailField() : super._();

  @override
  String get name => 'workEmail';

  @override
  String extract(User owner) => owner.workEmail;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null &&
        (() {
          final v = value;
          final at = v.lastIndexOf('@');
          if (at <= 0 || at == v.length - 1) return true;
          final local = v.substring(0, at);
          final domain = v.substring(at + 1);
          if (local.isEmpty || local.length > 64) return true;
          if (local.startsWith('.') || local.endsWith('.')) return true;
          if (local.contains('..')) return true;
          if (!RegExp('^[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~.-]+\$').hasMatch(local))
            return true;
          if (domain.isEmpty || domain.length > 255) return true;
          if (!RegExp(
            '^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\$',
          ).hasMatch(domain))
            return true;
          final labels = domain.split('.');
          if (!false && labels.length < 2) return true;
          for (final label in labels) {
            if (label.isEmpty || label.length > 63) return true;
          }
          final tld = labels.last;
          if (!false && (tld.length < 2 || RegExp(r'^[0-9]+$').hasMatch(tld)))
            return true;
          return false;
        })()) {
      $errors.add(_Errors.email([name]));
    }
    if (value != null && !value.endsWith('@example.com')) {
      $errors.add(_Errors.endsWith([name], '@example.com'));
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
    if (value != null && (value < 0 || value > 150)) {
      $errors.add(_Errors.between([name], 0, 150));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<int>> validateAsync(int? value) async {
    return validate(value);
  }
}

class UserCarField extends UserFields<Car> {
  const UserCarField() : super._();

  @override
  String get name => 'car';

  @override
  Car extract(User owner) => owner.car;

  @override
  ValidasiResult<Car> validate(Car? value) {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
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
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
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
  String get name => 'spareCar';

  @override
  Car? extract(User owner) => owner.spareCar;

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
  String get name => 'previousCars';

  @override
  List<Car> extract(User owner) => owner.previousCars;

  @override
  ValidasiResult<List<Car>> validate(List<Car>? value) {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
    }
    final $errors = <ValidationError>[];
    for (
      var $previousCarsIndex = 0;
      $previousCarsIndex < value.length;
      $previousCarsIndex++
    ) {
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
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<List<Car>>> validateAsync(List<Car>? value) async {
    if (value == null) {
      return _Result.invalidSingle(
        _Errors.required([name], message: 'Field is required'),
      );
    }
    final $errors = <ValidationError>[];
    for (
      var $previousCarsIndex = 0;
      $previousCarsIndex < value.length;
      $previousCarsIndex++
    ) {
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
    return _Result.from($errors, value);
  }
}

class UserCustomDataField extends UserFields<CustomDataClass?> {
  const UserCustomDataField() : super._();

  @override
  String get name => 'customData';

  @override
  CustomDataClass? extract(User owner) => owner.customData;

  @override
  ValidasiResult<CustomDataClass?> validate(CustomDataClass? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && !_validateCustomClass(value)) {
      $errors.add(
        _Errors.inline([name], 'inline', 'inline: validation failed.'),
      );
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<CustomDataClass?>> validateAsync(
    CustomDataClass? value,
  ) async {
    return validate(value);
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
    if (email.length < 3) {
      $errors.add(_Errors.minLength(['email'], 3));
    }
    if (email.length > 100) {
      $errors.add(_Errors.maxLength(['email'], 100));
    }
    if (!NoSpaces.check(email)) {
      $errors.add(
        _Errors.inline(['email'], 'noSpaces', 'noSpaces: validation failed.'),
      );
    }
    // Field: username
    if (username.length < 3) {
      $errors.add(_Errors.minLength(['username'], 3));
    }
    if (username.length > 100) {
      $errors.add(_Errors.maxLength(['username'], 100));
    }
    try {
      if (!await _checkUsernameAvailable(username)) {
        $errors.add(
          _Errors.inline(['username'], 'async_inline', 'Validation failed'),
        );
      }
    } catch (e) {
      $errors.add(_Errors.inline(['username'], 'async_inline', e.toString()));
    }
    // Field: confirmEmail
    if (confirmEmail.length < 3) {
      $errors.add(_Errors.minLength(['confirmEmail'], 3));
    }
    if (confirmEmail.length > 100) {
      $errors.add(_Errors.maxLength(['confirmEmail'], 100));
    }
    // Field: tags
    if (tags.length < 1) {
      $errors.add(_Errors.itMinLength(['tags'], 1));
    }
    if (tags.toSet().length != tags.length) {
      $errors.add(_Errors.unique(['tags']));
    }
    // Field: workEmail
    if ((() {
      final v = workEmail;
      final at = v.lastIndexOf('@');
      if (at <= 0 || at == v.length - 1) return true;
      final local = v.substring(0, at);
      final domain = v.substring(at + 1);
      if (local.isEmpty || local.length > 64) return true;
      if (local.startsWith('.') || local.endsWith('.')) return true;
      if (local.contains('..')) return true;
      if (!RegExp('^[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~.-]+\$').hasMatch(local))
        return true;
      if (domain.isEmpty || domain.length > 255) return true;
      if (!RegExp(
        '^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\$',
      ).hasMatch(domain))
        return true;
      final labels = domain.split('.');
      if (!false && labels.length < 2) return true;
      for (final label in labels) {
        if (label.isEmpty || label.length > 63) return true;
      }
      final tld = labels.last;
      if (!false && (tld.length < 2 || RegExp(r'^[0-9]+$').hasMatch(tld)))
        return true;
      return false;
    })()) {
      $errors.add(_Errors.email(['workEmail']));
    }
    if (!workEmail.endsWith('@example.com')) {
      $errors.add(_Errors.endsWith(['workEmail'], '@example.com'));
    }
    // Field: age
    if ((age < 0 || age > 150)) {
      $errors.add(_Errors.between(['age'], 0, 150));
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
    for (
      var $previousCarsIndex = 0;
      $previousCarsIndex < previousCars.length;
      $previousCarsIndex++
    ) {
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
    // Field: customData
    if (customData != null && !_validateCustomClass(customData)) {
      $errors.add(
        _Errors.inline(['customData'], 'inline', 'inline: validation failed.'),
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
    emailMatchesConfirm($fail, email: email, confirmEmail: confirmEmail);
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
  String get name => 'make';

  @override
  String extract(Car owner) => owner.make;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value.length < 2) {
      $errors.add(_Errors.minLength([name], 2));
    }
    return _Result.from($errors, value);
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return validate(value);
  }
}

class CarModelField extends CarFields<String> {
  const CarModelField() : super._();

  @override
  String get name => 'model';

  @override
  String extract(Car owner) => owner.model;

  @override
  ValidasiResult<String> validate(String? value) {
    final $errors = <ValidationError>[];
    if (value == null) {
      $errors.add(_Errors.required([name]));
    }
    if (value != null && value.length < 2) {
      $errors.add(_Errors.minLength([name], 2));
    }
    return _Result.from($errors, value);
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
    if (make.length < 2) {
      $errors.add(_Errors.minLength(['make'], 2));
    }
    // Field: model
    if (model.length < 2) {
      $errors.add(_Errors.minLength(['model'], 2));
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<Car>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: make
    if (make.length < 2) {
      $errors.add(_Errors.minLength(['make'], 2));
    }
    // Field: model
    if (model.length < 2) {
      $errors.add(_Errors.minLength(['model'], 2));
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
    if (code.length < 1) {
      $errors.add(_Errors.minLength(['code'], 1));
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
  }

  Future<ValidasiResult<InternalFoo>> validateAsync() async {
    final $errors = <ValidationError>[];
    // Field: code
    if (code.length < 1) {
      $errors.add(_Errors.minLength(['code'], 1));
    }
    if ($errors.isNotEmpty) {
      return ValidasiResult(errors: $errors, isValid: false);
    }
    return ValidasiResult(errors: const [], isValid: true, data: this);
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

  static ValidationError inline(
    List<String> path,
    String rule,
    String message,
  ) => ValidationError(rule: rule, message: message, path: path);

  static ValidationError itMinLength(
    List<String> path,
    int length, {
    String? message,
  }) => ValidationError(
    rule: 'MinLength',
    message: message ?? 'List must have at least $length items',
    details: {'length': '$length'},
    path: path,
  );

  static ValidationError unique(List<String> path, {String? message}) =>
      ValidationError(
        rule: 'Unique',
        message: message ?? 'List must contain only unique items',
        path: path,
      );

  static ValidationError email(List<String> path, {String? message}) =>
      ValidationError(
        rule: 'Email',
        message: message ?? 'Must be a valid email address',
        path: path,
      );

  static ValidationError endsWith(
    List<String> path,
    String suffix, {
    String? message,
  }) => ValidationError(
    rule: 'EndsWith',
    message: message ?? 'Must end with "$suffix"',
    details: {'suffix': suffix},
    path: path,
  );

  static ValidationError between(
    List<String> path,
    num min,
    num max, {
    String? message,
  }) => ValidationError(
    rule: 'Between',
    message: message ?? 'Value must be between $min and $max',
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
