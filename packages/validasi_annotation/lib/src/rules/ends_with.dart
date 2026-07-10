import 'package:validasi_annotation/src/base.dart';

class EndsWith<T> extends Rule<T> {
  final String suffix;
  const EndsWith(this.suffix, {super.message});
}
