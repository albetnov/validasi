import 'package:validasi_annotation/src/base.dart';

class MoreThanEqual<T extends num> extends Rule<T> {
  final T min;
  const MoreThanEqual(this.min, {super.message});
}
