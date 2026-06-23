import 'package:validasi_annotation/src/base.dart';

class AsyncCustomRule<T> extends Rule<T> {
  final String name;
  final bool runOnNull;

  const AsyncCustomRule({
    required this.name,
    super.message,
    this.runOnNull = false,
  });
}
