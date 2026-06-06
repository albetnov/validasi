// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const UserFields<String> email = UserEmailField();
  static const UserFields<List<String>> tags = UserTagsField();
  static const UserFields<Car> car = UserCarField();
  static const UserFields<Car?> spareCar = UserSpareCarField();
  static const UserFields<List<Car>> previousCars = UserPreviousCarsField();
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

class UserTagsField extends UserFields<List<String>> {
  const UserTagsField() : super._();

  @override
  String get name => 'tags';

  @override
  List<String> extract(User owner) => owner.tags;

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
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $carResult = value.validate();
    if (!$carResult.isValid) {
      return ValidasiResult(
        errors: $carResult.errors.map((e) => e.withPrefix(name)).toList(),
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
        errors: $spareCarResult.errors.map((e) => e.withPrefix(name)).toList(),
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
      return const ValidasiResult(errors: [], isValid: true);
    }
    final $errors = <ValidationError>[];
    for (var $previousCarsIndex = 0;
        $previousCarsIndex < value.length;
        $previousCarsIndex++) {
      final $previousCarsItem = value[$previousCarsIndex];
      final $previousCarsResult = $previousCarsItem.validate();
      if (!$previousCarsResult.isValid) {
        $errors.addAll($previousCarsResult.errors
            .map((e) => e.withPrefix("$name[${$previousCarsIndex}]")));
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

    // Field: car (nested Car)
    final $carResult = car.validate();
    if (!$carResult.isValid) {
      $errors.addAll($carResult.errors.map((e) => e.withPrefix('car')));
    }

    // Field: spareCar (nested Car)
    final $spareCarValue = spareCar;
    if ($spareCarValue != null) {
      final $spareCarResult = $spareCarValue.validate();
      if (!$spareCarResult.isValid) {
        $errors.addAll(
            $spareCarResult.errors.map((e) => e.withPrefix('spareCar')));
      }
    }

    // Field: previousCars (nested Car)
    for (var $previousCarsIndex = 0;
        $previousCarsIndex < previousCars.length;
        $previousCarsIndex++) {
      final $previousCarsItem = previousCars[$previousCarsIndex];
      final $previousCarsItemResult = $previousCarsItem.validate();
      if (!$previousCarsItemResult.isValid) {
        $errors.addAll($previousCarsItemResult.errors
            .map((e) => e.withPrefix('previousCars[${$previousCarsIndex}]')));
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

  ValidasiResult<V> validateField<V>(CarFields<V> field) {
    return field.validate(field.extract(this));
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
}
