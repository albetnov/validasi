import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/watch_mixin.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';
import 'package:validasi_ui/src/signals/form_signals.dart';

class ValidasiFormController<T> extends ChangeNotifier with WatchMixin<T> {
  final _fields = <ValidasiField<T, dynamic>, ValidasiFieldSignals>{};
  final _crossErrors = <ValidasiField<T, dynamic>, List<ValidationError>>{};
  final _subscriptions = <ValidasiField<T, dynamic>, List<void Function()>>{};
  final _formSignals = ValidasiFormSignals();
  final T Function(ValidasiFormController<T>) assembler;

  ValidasiFormController({required this.assembler});

  T? _initialModel;

  bool get isSubmitted => _formSignals.isSubmitted;
  bool get isLoading => _formSignals.isLoading;
  bool get isDirty => _formSignals.isDirty;
  bool get isPristine => !_formSignals.isDirty;
  bool get isTouched => _formSignals.isTouched;
  List<FieldErrors> get fieldErrors => _formSignals.fieldErrors;

  @override
  ValidasiFieldSignals<V> getFieldController<V>(ValidasiField<T, V> field) {
    if (!_fields.containsKey(field)) {
      register(field);
    }
    return _fields[field] as ValidasiFieldSignals<V>;
  }

  void markSubmitted() {
    _formSignals.isSubmitted = true;
    notifyListeners();
  }

  VoidCallback submit(void Function(T) onSubmit) {
    return () {
      if (!validate()) {
        markSubmitted();
        return;
      }
      onSubmit(assembler(this));
    };
  }

  void register<V>(ValidasiField<T, V> field, {V? initialValue}) {
    if (_fields.containsKey(field)) return;
    V? initial;
    if (_initialModel != null) {
      initial = field.extract(_initialModel as T);
    } else {
      initial = initialValue;
    }
    final fc = ValidasiFieldSignals<V>(field, initialValue: initial);
    _fields[field] = fc;

    _subscriptions[field] = [
      fc.isDirty.subscribe((dirty) {
        _formSignals.isDirty = _fields.values.any((f) => f.isDirty.value);
        notifyListeners();
      }),
      fc.touchedSignal.subscribe((touched) {
        _formSignals.isTouched = _fields.values.any((f) => f.touched);
        notifyListeners();
      }),
    ];
  }

  void setInitialValues(T model) {
    _initialModel = model;
    for (final entry in _fields.entries) {
      entry.value.setInitialValue(entry.key.extract(model));
    }
    notifyListeners();
  }

  @override
  V? getValue<V>(ValidasiField<T, V> field) => getFieldController(field).value;

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    final fc = getFieldController(field);
    fc.value = value;
    fc.markTouched();
    notifyListeners();
  }

  List<FieldError> getErrors<V>(ValidasiField<T, V> field) =>
      getFieldController(field).errors;

  void _mergeErrorsForField(
    ValidasiField<T, dynamic> field,
    List<ValidationError> ownErrors,
  ) {
    final fc = _fields[field]!;
    final crossRaw = _crossErrors[field];
    fc.updateErrors([
      ...ownErrors.map((e) => FieldValidationError(e)),
      if (crossRaw != null)
        ...crossRaw.map((e) => FieldCrossError(
              e,
              crossFieldName: field.crossFieldKey?.name ?? field.name,
              dependsOn: field.crossDependsOn,
            )),
    ]);
  }

  bool isFieldDirty<V>(ValidasiField<T, V> field) =>
      getFieldController(field).isDirty.value;

  bool isFieldTouched<V>(ValidasiField<T, V> field) =>
      getFieldController(field).touched;

  bool validateField<V>(ValidasiField<T, V> field) {
    final fc = getFieldController(field);
    final result = field.validate(fc.value);
    _crossErrors.remove(field);
    _mergeErrorsForField(field, result.errors);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return result.isValid;
  }

  bool validate() {
    final ownErrors = <ValidasiField<T, dynamic>, List<ValidationError>>{};
    batch(() {
      for (final entry in _fields.entries) {
        ownErrors[entry.key] = entry.key.validate(entry.value.value).errors;
      }
      _crossErrors.clear();
      for (final entry in _fields.entries) {
        final cv = entry.key.crossValidator;
        if (cv != null) {
          _crossErrors[entry.key] = cv(<V>(f) => getFieldController(f).value);
        }
      }
      for (final entry in _fields.entries) {
        _mergeErrorsForField(entry.key, ownErrors[entry.key]!);
      }
    });
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return isValid;
  }

  bool get isValid =>
      _fields.values.every((fc) => fc.isValid.value) &&
      _crossErrors.values.every((e) => e.isEmpty);

  Map<ValidasiField<T, dynamic>, dynamic> getValues() =>
      Map.unmodifiable(_fields.map((k, v) => MapEntry(k, v.value)));

  void reset() {
    _formSignals.reset();
    _crossErrors.clear();
    for (final fc in _fields.values) {
      fc.reset();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subs in _subscriptions.values) {
      for (final sub in subs) {
        sub();
      }
    }
    _subscriptions.clear();
    for (final fc in _fields.values) {
      fc.dispose();
    }
    _crossErrors.clear();
    _formSignals.dispose();
    super.dispose();
  }
}
