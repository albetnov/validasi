import 'dart:async';

import 'package:meta/meta.dart';

/// The [FailFn] returns false and accept a message. Allowing the user to
/// set the message according to their needs.
typedef FailFn = bool Function(String message);

/// [CustomCallback] for relatively simple in-line custom user-defined rule.
typedef CustomCallback<T> = FutureOr<bool> Function(T? value, FailFn fail);

/// [CustomRule] is a class based user defined Custom Rule if the user wish
/// to have a complex custom rule. The class itself
/// meant to be extended and thus inheriting it can later be passed on
/// [customFor] method.
abstract class CustomRule<T> {
  /// The [handle] function will be called by [customFor] and could return
  /// `Future<bool>` or just `bool`. If you use [Future] make sure to
  /// run the rule with `async` variants.
  @mustBeOverridden
  FutureOr<bool> handle(T? value, bool Function(String message) fail);
}
