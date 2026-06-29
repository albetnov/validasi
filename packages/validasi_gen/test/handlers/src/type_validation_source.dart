import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class StringModel {
  @Validate<String>([MinLength(3)])
  final String name;
  const StringModel({required this.name});
}

@ValidateClass()
class IntModel {
  @Validate<int>([MinLength(5)])
  final int count;
  const IntModel({required this.count});
}

@ValidateClass()
class IterableModel {
  @Validate<List<String>>([MinLength(1)])
  final List<String> items;
  const IterableModel({required this.items});
}

@ValidateClass()
class DoubleModel {
  @Validate<double>([MaxLength(100)])
  final double price;
  const DoubleModel({required this.price});
}

@ValidateClass()
class OneOfIntModel {
  @Validate<int>([
    OneOf<int>([1, 2])
  ])
  final int code;
  const OneOfIntModel({required this.code});
}
