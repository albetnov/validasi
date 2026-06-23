import 'package:validasi_annotation/src/base.dart';

class CustomRule<T> extends Rule<T> {
  final String name;
  final bool runOnNull;

  const CustomRule({
    required this.name,
    super.message,
    this.runOnNull = false,
  });
}
