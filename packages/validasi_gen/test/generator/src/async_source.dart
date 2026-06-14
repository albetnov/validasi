import 'dart:async';

import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class AsyncModel {
  @Validate.string([MinLength(3), AsyncInline(_asyncCheck)])
  final String name;

  @ValidateWithAsync(_checkMatch, dependsOn: {#name})
  final String confirmName;

  const AsyncModel({required this.name, required this.confirmName});
}

FutureOr<bool> _asyncCheck(String? value) async =>
    value != null && !value.contains(' ');

FutureOr<String?> _checkMatch(
  V? Function<V>(ValidasiField<AsyncModel, V>) get,
) async {
  return null;
}
