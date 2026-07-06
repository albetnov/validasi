import 'package:validasi_annotation/src/base.dart';

class ExactLength<T> extends Rule<T> {
  final int length;
  const ExactLength(this.length, {super.message});
}
