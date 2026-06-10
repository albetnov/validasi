import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/error.dart';
import 'package:validasi_ui/src/field_signals.dart';

class ValidasiFormSignals {
  final Signal<bool> _isSubmitted = signal<bool>(false);
  final Signal<bool> _isLoading = signal<bool>(false);
  final Signal<List<FieldErrors>> _fieldErrors = signal<List<FieldErrors>>([]);

  bool get isSubmitted => _isSubmitted.value;
  set isSubmitted(bool v) => _isSubmitted.value = v;

  bool get isLoading => _isLoading.value;
  set isLoading(bool v) => _isLoading.value = v;

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
  }

  void dispose() {
    _isSubmitted.dispose();
    _isLoading.dispose();
    _fieldErrors.dispose();
  }
}
