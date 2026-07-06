import 'package:validasi_annotation/src/base.dart';

class ContainsAll<T> extends Rule<T> {
  final List<Object?> elements;
  const ContainsAll(this.elements, {super.message});
}
