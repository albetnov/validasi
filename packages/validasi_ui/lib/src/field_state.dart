import 'package:validasi/validasi.dart';

class ValidasiFieldState<V> {
  final V? value;
  final List<ValidationError> errors;
  final void Function(V? value) onChanged;
  final void Function() validate;
  final void Function(bool hasFocus)? onFocusChange;

  const ValidasiFieldState({
    required this.value,
    required this.errors,
    required this.onChanged,
    required this.validate,
    this.onFocusChange,
  });

  String? get errorText => errors.isEmpty ? null : errors.first.message;

  bool get hasError => errors.isNotEmpty;
}
