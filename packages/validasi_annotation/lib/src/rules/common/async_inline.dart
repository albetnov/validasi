import 'package:validasi_annotation/src/base.dart';

class AsyncInline<T> extends Rule<T> {
  final Function validator;
  final String name;
  const AsyncInline(
    this.validator, {
    super.message,
    this.name = 'async_inline',
  });
}
