import 'package:validasi_annotation/src/base.dart';

class Having<T> extends Rule<T> {
  final List<Object?> validValues;
  const Having(this.validValues, {super.message});
}
