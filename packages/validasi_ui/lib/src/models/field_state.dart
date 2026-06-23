import 'package:validasi/validasi.dart';

class ValidasiFieldState<V> {
  final V? value;
  final List<ValidationError> errors;
  final void Function(V? value) onChanged;
  final void Function() validate;
  final void Function(bool hasFocus)? onFocusChange;
  final bool isDirty;
  final bool isTouched;
  final bool isValidating;
  final bool disabled;
  final void Function(String message, {bool overwrite})? setError;
  final void Function()? clearErrors;

  const ValidasiFieldState({
    required this.value,
    required this.errors,
    required this.onChanged,
    required this.validate,
    this.onFocusChange,
    this.isDirty = false,
    this.isTouched = false,
    this.isValidating = false,
    this.disabled = false,
    this.setError,
    this.clearErrors,
  });

  String? get errorText => errors.isEmpty ? null : errors.first.message;

  bool get hasError => errors.isNotEmpty;

  bool get isPristine => !isDirty;
}
