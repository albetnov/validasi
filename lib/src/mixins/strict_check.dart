import 'package:meta/meta.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/utils/message.dart';

mixin StrictCheck<T> {
  bool get strict;
  String? get message;

  @internal
  @protected
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

  @internal
  @protected
  void tryStrictCheck(Result result, dynamic value, String path,
      {String? type}) {
    try {
      strictCheck(value, path, type: type);
    } on FieldError catch (e) {
      result.addError(e);
    }
  }
}
