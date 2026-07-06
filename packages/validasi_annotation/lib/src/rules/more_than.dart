import 'package:validasi_annotation/src/base.dart';

class MoreThan<T extends num> extends Rule<T> {
  final T min;
  const MoreThan(this.min, {super.message});
}
