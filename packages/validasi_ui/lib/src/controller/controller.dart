import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/watch_mixin.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';
import 'package:validasi_ui/src/signals/form_signals.dart';

class ValidasiFormController<T> extends ChangeNotifier with WatchMixin<T> {
  final _fields = <ValidasiField<T, dynamic>, ValidasiFieldSignals>{};
  final _fieldsByName = <String, ValidasiField<T, dynamic>>{};
  final _subscriptions = <ValidasiField<T, dynamic>, List<void Function()>>{};
  final _formSignals = ValidasiFormSignals();
  final T Function(ValidasiFormController<T>) assembler;
  final FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)? formValidator;

  ValidasiFormController({
    required this.assembler,
    this.formValidator,
  });

  T? _initialModel;

  bool get isSubmitted => _formSignals.isSubmitted;
  bool get isLoading => _formSignals.isLoading;
  bool get isDirty => _formSignals.isDirty;
  bool get isPristine => !_formSignals.isDirty;
  bool get isTouched => _formSignals.isTouched;
  List<FieldErrors> get fieldErrors => _formSignals.fieldErrors;
  List<ValidationError> get formErrors => _formSignals.formErrors;

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

  Future<void> Function() submitAsync(void Function(T) onSubmit) {
    return () async {
      if (!await validateAsync()) {
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
    _fieldsByName[field.name] = field;

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

  void _applyErrors(
    ValidasiField<T, dynamic> field,
    List<ValidationError> errors,
  ) {
    final fc = _fields[field]!;
    fc.updateErrors([
      ...errors.map((e) => FieldValidationError(e)),
    ]);
  }

  void _distributeFormErrors(List<ValidationError> errors) {
    final byPath = groupErrorsByPath(errors);
    for (final fc in _fields.values) {
      fc.updateErrors([]);
    }
    _formSignals.formErrors = [];
    for (final entry in byPath.entries) {
      final fieldName = entry.key;
      if (fieldName.isEmpty) {
        _formSignals.formErrors = entry.value;
        continue;
      }
      final field = _fieldsByName[fieldName];
      if (field != null) {
        final fc = _fields[field];
        fc?.updateErrors([
          ...entry.value.map((e) => FieldValidationError(e)),
        ]);
      } else {
        _formSignals.formErrors = entry.value;
      }
    }
  }

  bool isFieldDirty<V>(ValidasiField<T, V> field) =>
      getFieldController(field).isDirty.value;

  bool isFieldTouched<V>(ValidasiField<T, V> field) =>
      getFieldController(field).touched;

  bool validateField<V>(ValidasiField<T, V> field) {
    final fc = getFieldController(field);
    final result = field.validate(fc.value);
    _applyErrors(field, result.errors);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return result.isValid;
  }

  bool validate() {
    if (formValidator != null) {
      final resultOrFuture = formValidator!(this);
      if (resultOrFuture is Future<ValidasiResult<T>>) {
        throw StateError(
          'Form has async validators. Use validateAsync() instead of validate().',
        );
      }
      final result = resultOrFuture;
      _distributeFormErrors(result.errors);
      _formSignals.syncFieldErrors(_fields);
      notifyListeners();
      return result.isValid;
    }
    batch(() {
      for (final entry in _fields.entries) {
        final result = entry.key.validate(entry.value.value);
        _applyErrors(entry.key, result.errors);
      }
    });
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return isValid;
  }

  Future<bool> validateAsync() async {
    if (formValidator != null) {
      final result = await formValidator!(this);
      _distributeFormErrors(result.errors);
      _formSignals.syncFieldErrors(_fields);
      notifyListeners();
      return result.isValid;
    }
    for (final entry in _fields.entries) {
      final result = await entry.key.validateAsync(entry.value.value);
      _applyErrors(entry.key, result.errors);
    }
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return isValid;
  }

  bool get isValid => _fields.values.every((fc) => fc.isValid.value);

  Map<ValidasiField<T, dynamic>, dynamic> getValues() =>
      Map.unmodifiable(_fields.map((k, v) => MapEntry(k, v.value)));

  void setError<V>(ValidasiField<T, V> field, String message,
      {String rule = 'Manual'}) {
    final fc = _fields[field];
    if (fc == null) return;
    fc.updateErrors([
      ...fc.errors,
      FieldValidationError(ValidationError(rule: rule, message: message)),
    ]);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearErrors<V>(ValidasiField<T, V> field) {
    final fc = _fields[field];
    if (fc == null) return;
    fc.updateErrors([]);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearAllErrors() {
    for (final fc in _fields.values) {
      fc.updateErrors([]);
    }
    _formSignals.formErrors = [];
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void reset() {
    _formSignals.reset();
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
    _fieldsByName.clear();
    for (final fc in _fields.values) {
      fc.dispose();
    }
    _formSignals.dispose();
    super.dispose();
  }
}
