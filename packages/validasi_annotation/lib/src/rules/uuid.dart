import 'package:validasi_annotation/src/base.dart';

class Uuid<T> extends Rule<T> {
  final List<int> versions;
  const Uuid({this.versions = const [4, 7], super.message});
}
