import 'package:validasi/src/engine/error.dart';

class ValidationContext {
  ValidationContext({
    required this.value,
  });

  dynamic value;
  final List<ValidationError> errors = [];
  bool isStopped = false;

  void setValue(dynamic to) {
    value = to;
  }

  void stop() {
    isStopped = true;
  }

  void addError(ValidationError error) {
    errors.add(error);
  }
}
