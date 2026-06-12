import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class CustomMsgModel {
  @Validate.string([
    MinLength(3, message: 'Name too short'),
    MaxLength(50, message: 'Name too long'),
  ])
  final String name;

  const CustomMsgModel({required this.name});
}

@ValidateClass()
class OneOfCustomMsgModel {
  @Validate.string([
    OneOf(['red', 'green', 'blue'], message: 'Must be a valid color')
  ])
  final String color;

  const OneOfCustomMsgModel({required this.color});
}
