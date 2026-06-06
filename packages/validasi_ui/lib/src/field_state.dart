import 'package:validasi/validasi.dart';

class ValidasiFieldState<V> {
  final V? value;
  final List<ValidationError> errors;
  final void Function(V? value) onChanged;
  final void Function() validate;

  const ValidasiFieldState({
    required this.value,
    required this.errors,
    required this.onChanged,
    required this.validate,
  });

  String? get errorText => errors.isEmpty ? null : errors.first.message;

  bool get hasError => errors.isNotEmpty;
}
