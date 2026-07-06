import 'package:validasi_annotation/src/base.dart';

class StartsWith<T> extends Rule<T> {
  final String prefix;
  const StartsWith(this.prefix, {super.message});
}
