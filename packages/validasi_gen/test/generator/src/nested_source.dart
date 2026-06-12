import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class UserWithNested {
  @Validate.string([MinLength(3)])
  final String email;

  final Car car;

  final Car? spareCar;

  final List<Car> previousCars;

  const UserWithNested({
    required this.email,
    required this.car,
    this.spareCar,
    required this.previousCars,
  });
}

@ValidateClass()
class Car {
  @Validate.string([MinLength(2)])
  final String make;

  @Validate.string([MinLength(2)])
  final String model;

  const Car({required this.make, required this.model});
}
