import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/error.dart';

class ValidasiFieldSignals<V> {
  ValidasiFieldSignals(this.field, {V? initialValue})
      : _value = signal<V?>(initialValue),
        _initialValue = signal<V?>(initialValue),
        _errors = signal<List<FieldError>>([]),
        _touched = signal<bool>(false),
        _disabled = signal<bool>(false),
        _isValidating = signal<bool>(false),
        _asyncError = signal<FieldError?>(null) {
    isDirty = computed(() => _value.value != _initialValue.value);
    isValid = computed(
      () => _errors.value.isEmpty && _asyncError.value == null,
    );
  }

  final ValidasiField<dynamic, V> field;
  final Signal<V?> _value;
  final Signal<V?> _initialValue;
  final Signal<List<FieldError>> _errors;
  final Signal<bool> _touched;
  final Signal<bool> _disabled;
  final Signal<bool> _isValidating;
  final Signal<FieldError?> _asyncError;

  late final ReadonlySignal<bool> isDirty;
  late final ReadonlySignal<bool> isValid;
  ReadonlySignal<bool> get touchedSignal => _touched;
  ReadonlySignal<bool> get disabledSignal => _disabled;
  ReadonlySignal<bool> get isValidatingSignal => _isValidating;

  V? get value => _value.value;
  set value(V? v) => _value.value = v;
  ReadonlySignal<V?> get valueSignal => _value;

  List<FieldError> get syncErrors => _errors.value;
  List<FieldError> get errors => [
        ..._errors.value,
        if (_asyncError.value != null) _asyncError.value!,
      ];
  void updateErrors(List<FieldError> errors) => _errors.value = errors;

  bool get isValidating => _isValidating.value;
  set isValidating(bool v) => _isValidating.value = v;

  void setAsyncError(String? message) {
    if (message != null) {
      _asyncError.value = FieldValidationError(
        ValidationError(rule: 'async', message: message),
      );
    } else {
      _asyncError.value = null;
    }
  }

  bool get touched => _touched.value;
  void markTouched() => _touched.value = true;

  void setInitialValue(V? v) {
    _initialValue.value = v;
    _value.value = v;
  }

  bool get disabled => _disabled.value;
  set disabled(bool v) => _disabled.value = v;

  void reset() {
    _value.value = _initialValue.value;
    _errors.value = [];
    _touched.value = false;
    _disabled.value = false;
    _isValidating.value = false;
    _asyncError.value = null;
  }

  void migrateFrom(ValidasiFieldSignals<V> other) {
    _value.value = other._value.value;
    _initialValue.value = other._initialValue.value;
    _errors.value = List<FieldError>.of(other._errors.value);
    _touched.value = other._touched.value;
    _disabled.value = other._disabled.value;
    _isValidating.value = other._isValidating.value;
    _asyncError.value = other._asyncError.value;
  }

  void swapSignalsWith(ValidasiFieldSignals<V> other) {
    final tmpVal = _value.value;
    final tmpInit = _initialValue.value;
    final tmpErr = List<FieldError>.of(_errors.value);
    final tmpTouched = _touched.value;
    final tmpDisabled = _disabled.value;
    final tmpValidating = _isValidating.value;
    final tmpAsync = _asyncError.value;

    _value.value = other._value.value;
    _initialValue.value = other._initialValue.value;
    _errors.value = List<FieldError>.of(other._errors.value);
    _touched.value = other._touched.value;
    _disabled.value = other._disabled.value;
    _isValidating.value = other._isValidating.value;
    _asyncError.value = other._asyncError.value;

    other._value.value = tmpVal;
    other._initialValue.value = tmpInit;
    other._errors.value = tmpErr;
    other._touched.value = tmpTouched;
    other._disabled.value = tmpDisabled;
    other._isValidating.value = tmpValidating;
    other._asyncError.value = tmpAsync;
  }

  void dispose() {
    _value.dispose();
    _initialValue.dispose();
    _errors.dispose();
    _touched.dispose();
    _disabled.dispose();
    _isValidating.dispose();
    _asyncError.dispose();
    isDirty.dispose();
    isValid.dispose();
  }
}
