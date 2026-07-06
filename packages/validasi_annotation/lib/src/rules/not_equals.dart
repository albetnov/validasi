import 'package:validasi_annotation/src/base.dart';

class NotEquals<T> extends Rule<T> {
  final Object? unexpected;
  const NotEquals(this.unexpected, {super.message});
}
