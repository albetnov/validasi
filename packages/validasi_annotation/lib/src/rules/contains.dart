import 'package:validasi_annotation/src/base.dart';

class Contains<T> extends Rule<T> {
  final Object? value;
  const Contains(this.value, {super.message});
}
