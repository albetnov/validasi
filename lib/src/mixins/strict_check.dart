import 'package:meta/meta.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';

/// The generic implementation of [StrictCheck] to help integrate type check
/// and type conversion. This mixins will add [strict] and [message] property.
mixin StrictCheck<T> {
  /// The [strict] responsible to enforce type and perform runtime check
  /// and throw [FieldError] on `parse` variants, or append `errors` for
  /// `tryParse` variants.
  bool get strict;

  /// The [message] will be used to as a custom message for failing type check
  /// (strict)
  String? get message;

  /// The [strictCheck] function to throw [FieldError]. Should be implemented
  /// for the `parse` variants.
  @internal
  @protected
  @visibleForTesting
  void strictCheck(dynamic value, String path, {String? type}) {
    if (strict && value is! T && value != null) {
      throw FieldError(
        path: path,
        name: 'invalidType',
        message: Message(
          path,
          fallback: ":name is not a valid ${type ?? T.toString()}",
          message: message,
        ).parse,
      );
    }
  }

  /// The `tryParse` variants equivalent for [strictCheck].
  @internal
  @protected
  @visibleForTesting
  void tryStrictCheck(Result result, dynamic value, String path,
      {String? type}) {
    try {
      strictCheck(value, path, type: type);
    } on FieldError catch (e) {
      result.errors.add(e);
    }
  }
}
