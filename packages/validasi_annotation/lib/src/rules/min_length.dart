import 'package:validasi_annotation/src/base.dart';

class MinLength<T> extends Rule<T> {
  final int length;
  const MinLength(this.length, {super.message});
}
