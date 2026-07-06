import 'package:validasi_annotation/src/base.dart';

class Regex<T> extends Rule<T> {
  final String pattern;
  const Regex(this.pattern, {super.message});
}
