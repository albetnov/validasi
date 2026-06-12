import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/error.dart';

class ValidasiFieldSignals<V> {
  ValidasiFieldSignals(this.field, {V? initialValue})
      : _value = signal<V?>(initialValue),
        _initialValue = signal<V?>(initialValue),
        _errors = signal<List<FieldError>>([]),
        _touched = signal<bool>(false) {
    isDirty = computed(() => _value.value != _initialValue.value);
    isValid = computed(() => _errors.value.isEmpty);
  }

  final ValidasiField<dynamic, V> field;
  final Signal<V?> _value;
  final Signal<V?> _initialValue;
  final Signal<List<FieldError>> _errors;
  final Signal<bool> _touched;

  late final ReadonlySignal<bool> isDirty;
  late final ReadonlySignal<bool> isValid;
  ReadonlySignal<bool> get touchedSignal => _touched;

  V? get value => _value.value;
  set value(V? v) => _value.value = v;
  ReadonlySignal<V?> get valueSignal => _value;

  List<FieldError> get errors => _errors.value;
  void updateErrors(List<FieldError> errors) => _errors.value = errors;

  bool get touched => _touched.value;
  void markTouched() => _touched.value = true;

  void setInitialValue(V? v) {
    _initialValue.value = v;
    _value.value = v;
  }

  void reset() {
    _value.value = _initialValue.value;
    _errors.value = [];
    _touched.value = false;
  }

  void dispose() {
    _value.dispose();
    _initialValue.dispose();
    _errors.dispose();
    _touched.dispose();
  }
}
