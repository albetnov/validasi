import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class StringModel {
  @Validate.string([MinLength(3)])
  final String name;
  const StringModel({required this.name});
}

@ValidateClass()
class IntModel {
  @Validate([MinLength(5)])
  final int count;
  const IntModel({required this.count});
}

@ValidateClass()
class IterableModel {
  @Validate.iterable([MinLength(1)])
  final List<String> items;
  const IterableModel({required this.items});
}

@ValidateClass()
class DoubleModel {
  @Validate([MaxLength(100)])
  final double price;
  const DoubleModel({required this.price});
}

@ValidateClass()
class OneOfIntModel {
  @Validate([
    OneOf(['a', 'b'])
  ])
  final int code;
  const OneOfIntModel({required this.code});
}
