import 'package:validasi/src/engine/error.dart';

class ValidationContext<T> {
  ValidationContext({
    required this.value,
  });

  T? value;
  T get requireValue => value!;

  final List<ValidationError> errors = [];
  bool isStopped = false;

  void setValue(T? to) {
    value = to;
  }

  void stop() {
    isStopped = true;
  }

  void addError(ValidationError error) {
    errors.add(error);
  }
}
