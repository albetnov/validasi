import 'package:validasi/src/field_error.dart';

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
    _isPassed = test(value);
  }

  bool get passed => _isPassed;

  FieldError toFieldError(String path) => FieldError(
      path: path, name: name, message: message.replaceAll(':name', path));
}
