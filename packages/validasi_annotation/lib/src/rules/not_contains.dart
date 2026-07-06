import 'package:validasi_annotation/src/base.dart';

class NotContains<T> extends Rule<T> {
  final Object? value;
  const NotContains(this.value, {super.message});
}
