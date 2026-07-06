import 'package:validasi_annotation/src/base.dart';

class LessThanEqual<T extends num> extends Rule<T> {
  final T max;
  const LessThanEqual(this.max, {super.message});
}
