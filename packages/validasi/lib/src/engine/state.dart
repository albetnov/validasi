import 'package:validasi/src/engine/error.dart';

class ValidationState {
  final List<ValidationError> errors = [];
  bool isStopped = false;

  void stop() {
    isStopped = true;
  }

  void addError(ValidationError error) {
    errors.add(error);
  }
}
