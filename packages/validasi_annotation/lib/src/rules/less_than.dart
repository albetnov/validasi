import 'package:validasi_annotation/src/base.dart';

class LessThan<T extends num> extends Rule<T> {
  final T max;
  const LessThan(this.max, {super.message});
}
