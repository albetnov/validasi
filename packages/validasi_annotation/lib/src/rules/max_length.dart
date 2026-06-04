import 'package:validasi_annotation/src/base.dart';

class MaxLength<T> extends Rule<T> {
  final int length;
  const MaxLength(this.length, {super.message});
}
