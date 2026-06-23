import 'package:validasi_annotation/src/base.dart';

class Inline<T> extends Rule<T> {
  final bool Function(T? value) validator;
  final String name;
  final bool runOnNull;

  const Inline(
    this.validator, {
    this.name = 'inline',
    super.message,
    this.runOnNull = false,
  });
}
