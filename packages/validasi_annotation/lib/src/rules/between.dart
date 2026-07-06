import 'package:validasi_annotation/src/base.dart';

class Between<T extends num> extends Rule<T> {
  final T min;
  final T max;
  const Between(this.min, this.max, {super.message});
}
