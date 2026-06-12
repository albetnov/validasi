import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';

class ValidasiFormSignals {
  final Signal<bool> _isSubmitted = signal<bool>(false);
  final Signal<bool> _isLoading = signal<bool>(false);
  final Signal<bool> _isDirty = signal<bool>(false);
  final Signal<bool> _isTouched = signal<bool>(false);
  final Signal<List<FieldErrors>> _fieldErrors = signal<List<FieldErrors>>([]);

  bool get isSubmitted => _isSubmitted.value;
  set isSubmitted(bool v) => _isSubmitted.value = v;

  bool get isLoading => _isLoading.value;
  set isLoading(bool v) => _isLoading.value = v;

  bool get isDirty => _isDirty.value;
  set isDirty(bool v) => _isDirty.value = v;

  bool get isTouched => _isTouched.value;
  set isTouched(bool v) => _isTouched.value = v;

  List<FieldErrors> get fieldErrors => _fieldErrors.value;

  void syncFieldErrors(
      Map<ValidasiField<dynamic, dynamic>, ValidasiFieldSignals> fields) {
    _fieldErrors.value = [
      for (final entry in fields.entries)
        FieldErrors(name: entry.key.name, errors: entry.value.errors),
    ];
  }

  void reset() {
    _isSubmitted.value = false;
    _isLoading.value = false;
    _isDirty.value = false;
    _isTouched.value = false;
  }

  void dispose() {
    _isSubmitted.dispose();
    _isLoading.dispose();
    _isDirty.dispose();
    _isTouched.dispose();
    _fieldErrors.dispose();
  }
}
