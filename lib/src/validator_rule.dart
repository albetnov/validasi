import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/utils/message.dart';

class ValidatorRule<T> {
  final bool Function(T? value) test;
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

    _isPassed = result;
  }

  bool get passed => _isPassed;

  FieldError toFieldError(String path) => FieldError(
      path: path, name: name, message: Message(path, message: message).parse);
}
