import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/watch_mixin.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';
import 'package:validasi_ui/src/signals/form_signals.dart';

class _AsyncValidatorState {
  Future<String?> Function(dynamic)? validator;
  Timer? debounceTimer;
  int version = 0;
  Duration debounce = const Duration(milliseconds: 300);

  void cancel() {
    debounceTimer?.cancel();
    version++;
  }
}

class ValidasiFormController<T> extends ChangeNotifier with WatchMixin<T> {
  final _fields = <ValidasiField<T, dynamic>, ValidasiFieldSignals>{};
  final _fieldsByName = <String, ValidasiField<T, dynamic>>{};
  final _subscriptions = <ValidasiField<T, dynamic>, List<void Function()>>{};
  final _asyncValidators = <ValidasiField<T, dynamic>, _AsyncValidatorState>{};
  final _formSignals = ValidasiFormSignals();
  final T Function(ValidasiFormController<T>) assembler;
  final FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)?
      formValidator;

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
        _formSignals.isDirty =
            _fields.values.any((f) => !f.disabled && f.isDirty.value);
        notifyListeners();
      }),
      fc.touchedSignal.subscribe((touched) {
        _formSignals.isTouched =
            _fields.values.any((f) => !f.disabled && f.touched);
        notifyListeners();
      }),
    ];
  }

  void setInitialValues(T model) {
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _initialModel = model;
    for (final entry in _fields.entries) {
      entry.value.setInitialValue(entry.key.extract(model));
      entry.value.isValidating = false;
      entry.value.setAsyncError(null);
    }
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  @override
  V? getValue<V>(ValidasiField<T, V> field) => getFieldController(field).value;

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    final fc = getFieldController(field);
    if (fc.disabled) return;
    fc.value = value;
    fc.markTouched();
    notifyListeners();
  }

  void setFieldDisabled<V>(ValidasiField<T, V> field, bool disabled) {
    final fc = getFieldController(field);
    if (fc.disabled == disabled) return;
    fc.disabled = disabled;
    if (disabled) {
      fc.updateErrors([]);
      fc.setAsyncError(null);
    }
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void setFieldValidator<V>(
    ValidasiField<T, V> field,
    Future<String?> Function(V?)? validator, {
    Duration debounce = const Duration(milliseconds: 300),
  }) {
    if (validator == null) {
      _asyncValidators.remove(field)?.cancel();
      final fc = _fields[field];
      if (fc != null) {
        fc.setAsyncError(null);
        _formSignals.syncFieldErrors(_fields);
        notifyListeners();
      }
      return;
    }
    final state = _asyncValidators.putIfAbsent(
      field,
      () => _AsyncValidatorState(),
    );
    state.validator = (value) => validator(value as V?);
    state.debounce = debounce;
  }

  Future<void> triggerAsyncValidation<V>(ValidasiField<T, V> field) async {
    final state = _asyncValidators[field];
    if (state == null || state.validator == null) return;
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;

    state.cancel();
    final version = ++state.version;
    final value = fc.value;

    state.debounceTimer = Timer(state.debounce, () async {
      fc.isValidating = true;
      notifyListeners();

      try {
        final error = await state.validator!(value);
        if (version != state.version) return;
        fc.setAsyncError(error);
        _formSignals.syncFieldErrors(_fields);
        notifyListeners();
      } catch (_) {
        if (version != state.version) return;
        notifyListeners();
      } finally {
        fc.isValidating = false;
      }
    });
  }

  List<FieldError> getErrors<V>(ValidasiField<T, V> field) =>
      getFieldController(field).errors;

  void _applyErrors(
    ValidasiField<T, dynamic> field,
    List<ValidationError> errors,
  ) {
    final fc = _fields[field]!;
    if (fc.disabled) return;
    fc.updateErrors([
      ...errors.map((e) => FieldValidationError(e)),
    ]);
  }

  void _distributeFormErrors(List<ValidationError> errors) {
    final byPath = groupErrorsByPath(errors);
    for (final fc in _fields.values) {
      if (!fc.disabled) fc.updateErrors([]);
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
        if (fc != null && !fc.disabled) {
          fc.updateErrors([
            ...entry.value.map((e) => FieldValidationError(e)),
          ]);
        }
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
    if (fc.disabled) return true;
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
        if (entry.value.disabled) continue;
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
      if (entry.value.disabled) continue;
      final result = await entry.key.validateAsync(entry.value.value);
      _applyErrors(entry.key, result.errors);
    }
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return isValid;
  }

  bool get isValid =>
      _fields.values.every((fc) => fc.disabled || fc.isValid.value);

  Map<ValidasiField<T, dynamic>, dynamic> getValues() => Map.unmodifiable(
        Map.fromEntries(
          _fields.entries
              .where((e) => !e.value.disabled)
              .map((e) => MapEntry(e.key, e.value.value)),
        ),
      );

  void setError<V>(ValidasiField<T, V> field, String message,
      {String rule = 'Manual'}) {
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;
    fc.updateErrors([
      ...fc.syncErrors,
      FieldValidationError(ValidationError(rule: rule, message: message)),
    ]);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearErrors<V>(ValidasiField<T, V> field) {
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;
    fc.updateErrors([]);
    fc.setAsyncError(null);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearAllErrors() {
    for (final fc in _fields.values) {
      fc.updateErrors([]);
      fc.setAsyncError(null);
    }
    _formSignals.formErrors = [];
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void reset() {
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _formSignals.reset();
    for (final fc in _fields.values) {
      fc.reset();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _asyncValidators.clear();
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
