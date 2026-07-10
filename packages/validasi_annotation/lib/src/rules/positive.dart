import 'package:validasi_annotation/src/base.dart';

class Positive<T extends num> extends Rule<T> {
  const Positive({super.message});
}
