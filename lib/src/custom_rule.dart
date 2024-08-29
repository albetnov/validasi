import 'dart:async';

import 'package:meta/meta.dart';

typedef FailFn = bool Function(String message);

typedef CustomCallback<T> = FutureOr<bool> Function(T? value, FailFn fail);

abstract class CustomRule<T> {
  @mustBeOverridden
  FutureOr<bool> handle(T? value, bool Function(String message) fail);
}
