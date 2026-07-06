import 'package:validasi_annotation/src/base.dart';

class Equals<T> extends Rule<T> {
  final Object? expected;
  const Equals(this.expected, {super.message});
}
