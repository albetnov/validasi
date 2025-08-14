import 'package:validasi/src/engine/error.dart';

class ValidationContext {
  ValidationContext({
    required this.value,
  });

  dynamic value;
  final List<ValidationError> errors = [];
  bool isStopped = false;

  void stop() {
    isStopped = true;
  }
}
