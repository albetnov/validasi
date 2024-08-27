import 'package:validasi/src/exceptions/field_error.dart';

class Result<T> {
  final T? value;
  List<FieldError> errors = [];

  Result({this.value, List<FieldError>? errors}) : errors = errors ?? [];

  bool get isValid => errors.isEmpty;

  void addError(FieldError error) => errors.add(error);
}
