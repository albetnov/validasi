import 'dart:async';

import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class AsyncModel {
  @Validate<String>([MinLength(3), AsyncInline(_asyncCheck)])
  final String name;

  final String confirmName;

  const AsyncModel({required this.name, required this.confirmName});
}

FutureOr<bool> _asyncCheck(String? value) async =>
    value != null && !value.contains(' ');
