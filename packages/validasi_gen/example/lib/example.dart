import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'example.g.dart';

@ValidateClass()
class User {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate.iterable([MinLength(1)])
  final List<String> tags;

  final Car car;

  final Car? spareCar;

  final List<Car> previousCars;

  const User({
    required this.email,
    required this.tags,
    required this.car,
    this.spareCar,
    required this.previousCars,
  });
}

@ValidateClass()
class Car {
  @Validate.string([MinLength(2)])
  final String make;

  @Validate.string([
    MinLength(2),
  ])
  final String model;

  const Car({required this.make, required this.model});
}
