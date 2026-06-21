import 'package:validasi/validasi.dart';

sealed class FieldError {
  final ValidationError error;
  const FieldError(this.error);

  String get rule => error.rule;
  String get message => error.message;
  Map<String, dynamic>? get details => error.details;
  List<String>? get path => error.path;
}

class FieldValidationError extends FieldError {
  const FieldValidationError(super.error);
}

class FieldErrors {
  final String name;
  final List<FieldError> errors;
  const FieldErrors({required this.name, required this.errors});

  bool get isValid => errors.isEmpty;
  String? get errorText => errors.isEmpty ? null : errors.first.message;
}
