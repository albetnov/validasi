import 'package:validasi_annotation/src/base.dart';

class OneOf<T> extends Rule<T> {
  final List<T> options;
  const OneOf(this.options, {super.message});
}
