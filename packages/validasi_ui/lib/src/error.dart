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

class FieldCrossError extends FieldError {
  final String crossFieldName;
  final Set<ValidasiField<dynamic, dynamic>> dependsOn;

  const FieldCrossError(
    super.error, {
    required this.crossFieldName,
    required this.dependsOn,
  });
}

class FieldErrors {
  final String name;
  final List<FieldError> errors;
  const FieldErrors({required this.name, required this.errors});

  bool get isValid => errors.isEmpty;
  bool get hasCrossErrors => errors.any((e) => e is FieldCrossError);
  String? get errorText => errors.isEmpty ? null : errors.first.message;
}
