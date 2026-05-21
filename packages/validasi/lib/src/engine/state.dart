import 'package:validasi/src/engine/error.dart';

class ValidationState {
  List<ValidationError>? _errors;
  bool isStopped = false;

  void addError(ValidationError error) {
    (_errors ??= []).add(error);
  }

  bool get isValid => _errors == null;

  List<ValidationError> get errors => _errors ?? const [];
}
