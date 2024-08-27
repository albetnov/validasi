import 'dart:async';

import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/exceptions/field_error.dart';

class ValidatorRule<T> {
  final FutureOr<bool> Function(T? value) test;
  bool _isPassed = false;
  final String message;
  final String name;

  ValidatorRule({
    required this.name,
    required this.test,
    required this.message,
  });

  void check(T? value) {
    var result = test(value);

    if (result is Future) {
      throw ValidasiException(
          'Asyncronous action detected, please use `async` variant (parseAsync, tryParseAsync)');
    }

    _isPassed = result;
  }

  Future<void> checkAsync(T? value) async {
    _isPassed = await test(value);
  }

  bool get passed => _isPassed;

  FieldError toFieldError(String path) => FieldError(
      path: path, name: name, message: message.replaceAll(':name', path));
}
