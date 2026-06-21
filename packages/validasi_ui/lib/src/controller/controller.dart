import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/indexed_field.dart';
import 'package:validasi_ui/src/controller/watch_mixin.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';
import 'package:validasi_ui/src/signals/form_signals.dart';

class _ArrayItemField<T, V> extends ValidasiField<T, V> {
  final String _name;
  const _ArrayItemField(this._name);

  @override
  String get name => _name;

  @override
  V? extract(T owner) => null;

  @override
  ValidasiResult<V> validate(V? value) => ValidasiResult.success(value as V);

  @override
  bool operator ==(Object other) =>
      other is _ArrayItemField<T, V> && _name == other._name;

  @override
  int get hashCode => _name.hashCode;
}

class _ObjectArrayStructure<T> {
  final List<ValidasiField<T, dynamic>> Function(int index) indexedFields;
  final dynamic Function(ValidasiFormController<T>, int) reconstructItem;
  final List<dynamic> Function(ValidasiFormController<T>) reconstructAll;

  _ObjectArrayStructure({
    required this.indexedFields,
    required this.reconstructItem,
    required this.reconstructAll,
  });
}

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
  final _arrayItemFields = <ValidasiField<T, dynamic>>{};
  final _arrayItemParents =
      <ValidasiField<T, dynamic>, ValidasiField<T, dynamic>>{};
  final _objectArrayStructures =
      <ValidasiField<T, dynamic>, _ObjectArrayStructure<T>>{};
  final _formSignals = ValidasiFormSignals();
  final T Function(ValidasiFormController<T>) assembler;
  final FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)?
      formValidator;

  ValidasiFormController({
    required this.assembler,
    this.formValidator,
  });

  T? _initialModel;

  bool get isSubmitted {
    _throwIfDisposed();
    return _formSignals.isSubmitted;
  }

  bool get isLoading {
    _throwIfDisposed();
    return _formSignals.isLoading;
  }

  bool get isDirty {
    _throwIfDisposed();
    return _formSignals.isDirty;
  }

  bool get isPristine {
    _throwIfDisposed();
    return !_formSignals.isDirty;
  }

  bool get isTouched {
    _throwIfDisposed();
    return _formSignals.isTouched;
  }

  List<FieldErrors> get fieldErrors {
    _throwIfDisposed();
    return _formSignals.fieldErrors;
  }

  List<ValidationError> get formErrors {
    _throwIfDisposed();
    return _formSignals.formErrors;
  }

  @override
  ValidasiFieldSignals<V> getFieldController<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    if (!_fields.containsKey(field)) {
      register(field);
    }
    return _fields[field] as ValidasiFieldSignals<V>;
  }

  void markSubmitted() {
    _throwIfDisposed();
    _formSignals.isSubmitted = true;
    notifyListeners();
  }

  VoidCallback submit(void Function(T) onSubmit) {
    _throwIfDisposed();
    return () {
      if (!validate()) {
        markSubmitted();
        return;
      }
      onSubmit(assembler(this));
    };
  }

  Future<void> Function() submitAsync(void Function(T) onSubmit) {
    _throwIfDisposed();
    return () async {
      if (!await validateAsync()) {
        markSubmitted();
        return;
      }
      onSubmit(assembler(this));
    };
  }

  void register<V>(ValidasiField<T, V> field, {V? initialValue}) {
    _throwIfDisposed();
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
    _throwIfDisposed();
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _initialModel = model;
    for (final entry in _fields.entries) {
      entry.value.setInitialValue(entry.key.extract(model));
      entry.value.isValidating = false;
      entry.value.setAsyncError(null);
    }
    for (final parentField in _objectArrayStructures.keys) {
      _rebuildArrayItems(parentField as ValidasiField<T, List<dynamic>>);
    }
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  @override
  V? getValue<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final structure =
        _objectArrayStructures[field as ValidasiField<T, dynamic>];
    if (structure != null) {
      return structure.reconstructAll(this) as V?;
    }
    return getFieldController(field).value;
  }

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    _throwIfDisposed();
    final fc = getFieldController(field);
    if (fc.disabled) return;
    fc.value = value;
    fc.markTouched();

    final parentField = _arrayItemParents[field];
    if (parentField != null) {
      final name = field.name;
      final start = name.lastIndexOf('[');
      final end = name.lastIndexOf(']');
      if (start != -1 && end != -1) {
        final dotAfterBracket = name.indexOf('.', end);
        if (dotAfterBracket != -1) return;
        final index = int.parse(name.substring(start + 1, end));
        final parentFc = _fields[parentField]!;
        final list = parentFc.value is List
            ? List<V>.from(parentFc.value as List)
            : <V>[];
        if (index >= 0 && index < list.length) {
          list[index] = value as V;
          parentFc.value = list;
        }
      }
    }

    notifyListeners();
  }

  void _unregister(ValidasiField<T, dynamic> field) {
    _asyncValidators.remove(field)?.cancel();
    _objectArrayStructures.remove(field);
    final subs = _subscriptions.remove(field);
    if (subs != null) {
      for (final sub in subs) {
        sub();
      }
    }
    final fc = _fields.remove(field);
    fc?.dispose();
    _fieldsByName.remove(field.name);
    _arrayItemFields.remove(field);
    _arrayItemParents.remove(field);
    if (!_disposed) {
      _formSignals.isDirty =
          _fields.values.any((f) => !f.disabled && f.isDirty.value);
      _formSignals.isTouched =
          _fields.values.any((f) => !f.disabled && f.touched);
    }
  }

  void unregister<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final key = field as ValidasiField<T, dynamic>;
    for (final name in _fieldsByName.keys.toList()) {
      if (name.startsWith('${key.name}[')) {
        _unregister(_fieldsByName[name]!);
      }
    }
    _unregister(key);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void _unregisterArrayItem(ValidasiField<T, dynamic> field) {
    _unregister(field);
  }

  void _rebuildArrayItems<V>(ValidasiField<T, List<V>> field) {
    for (final name in _fieldsByName.keys.toList()) {
      if (name.startsWith('${field.name}[')) {
        _unregisterArrayItem(_fieldsByName[name]!);
      }
    }

    final parentFc = getFieldController<List<V>>(field);
    final list = parentFc.value ?? <V>[];
    final structure = _objectArrayStructures[field];

    for (var i = 0; i < list.length; i++) {
      if (structure != null) {
        final subFields = structure.indexedFields(i);
        for (final subField in subFields) {
          register(subField);
          final item = list[i];
          final indexedField = subField as IndexedField<T, dynamic>;
          final subValue = indexedField.extractFromItem(item);
          final fc = _fields[subField]!;
          fc.setInitialValue(subValue);
          _arrayItemFields.add(subField);
          _arrayItemParents[subField] = field as ValidasiField<T, dynamic>;
        }
      } else {
        final itemField = _ArrayItemField<T, V>('${field.name}[$i]');
        register(itemField, initialValue: list[i]);
        _arrayItemFields.add(itemField);
        _arrayItemParents[itemField] = field as ValidasiField<T, dynamic>;
      }
    }
  }

  ValidasiField<T, V>? getArrayItemField<V>(
    ValidasiField<T, List<V>> field,
    int index,
  ) {
    _throwIfDisposed();
    final name = '${field.name}[$index]';
    return _fieldsByName[name] as ValidasiField<T, V>?;
  }

  int getArrayItemCount(ValidasiField<T, dynamic> field) {
    _throwIfDisposed();
    final fc = _fields[field];
    if (fc == null) return 0;
    final list = fc.value;
    if (list is List) return list.length;
    return 0;
  }

  ValidasiField<T, SubV>? getArraySubField<SubV>(
    ValidasiField<T, dynamic> field,
    int index,
    String fieldName,
  ) {
    _throwIfDisposed();
    final name = '${field.name}[$index].$fieldName';
    return _fieldsByName[name] as ValidasiField<T, SubV>?;
  }

  void appendArrayItem<V>(
    ValidasiField<T, List<V>> field,
    V value, {
    List<ValidasiField<T, dynamic>> Function(int index)? indexedFields,
    dynamic Function(ValidasiFormController<T>, int)? reconstructItem,
    List<dynamic> Function(ValidasiFormController<T>)? reconstructAll,
  }) {
    _throwIfDisposed();
    final key = field as ValidasiField<T, dynamic>;
    if (indexedFields != null &&
        reconstructItem != null &&
        reconstructAll != null) {
      _objectArrayStructures[key] = _ObjectArrayStructure<T>(
        indexedFields: indexedFields,
        reconstructItem: reconstructItem,
        reconstructAll: reconstructAll,
      );
    }
    final parentFc = getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[], value];
    parentFc.value = list;
    _rebuildArrayItems(field);
    notifyListeners();
  }

  void insertArrayItem<V>(
    ValidasiField<T, List<V>> field,
    int index,
    V value, {
    List<ValidasiField<T, dynamic>> Function(int index)? indexedFields,
    dynamic Function(ValidasiFormController<T>, int)? reconstructItem,
    List<dynamic> Function(ValidasiFormController<T>)? reconstructAll,
  }) {
    _throwIfDisposed();
    final key = field as ValidasiField<T, dynamic>;
    if (indexedFields != null &&
        reconstructItem != null &&
        reconstructAll != null) {
      _objectArrayStructures[key] = _ObjectArrayStructure<T>(
        indexedFields: indexedFields,
        reconstructItem: reconstructItem,
        reconstructAll: reconstructAll,
      );
    }
    final parentFc = getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (index < 0 || index > list.length) return;
    list.insert(index, value);
    parentFc.value = list;
    _rebuildArrayItems(field);
    notifyListeners();
  }

  void removeArrayItem<V>(ValidasiField<T, List<V>> field, int index) {
    _throwIfDisposed();
    final parentFc = getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    parentFc.value = list;
    _rebuildArrayItems(field);
    notifyListeners();
  }

  void swapArrayItems<V>(ValidasiField<T, List<V>> field, int i, int j) {
    _throwIfDisposed();
    final parentFc = getFieldController<List<V>>(field);
    final list = <V>[...parentFc.value ?? <V>[]];
    if (i < 0 || i >= list.length || j < 0 || j >= list.length) return;
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
    parentFc.value = list;
    _rebuildArrayItems(field);
    notifyListeners();
  }

  void setFieldDisabled<V>(ValidasiField<T, V> field, bool disabled) {
    _throwIfDisposed();
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
    _throwIfDisposed();
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
    _throwIfDisposed();
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

  List<FieldError> getErrors<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    return getFieldController(field).errors;
  }

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

  bool isFieldDirty<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    return getFieldController(field).isDirty.value;
  }

  bool isFieldTouched<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    return getFieldController(field).touched;
  }

  bool validateField<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final fc = getFieldController(field);
    if (fc.disabled) return true;
    final result = field.validate(fc.value);
    _applyErrors(field, result.errors);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
    return result.isValid;
  }

  bool validate() {
    _throwIfDisposed();
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
    _throwIfDisposed();
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

  bool get isValid {
    _throwIfDisposed();
    return _fields.values.every((fc) => fc.disabled || fc.isValid.value);
  }

  Map<ValidasiField<T, dynamic>, dynamic> getValues() {
    _throwIfDisposed();
    return Map.unmodifiable(
      Map.fromEntries(
        _fields.entries
            .where(
              (e) => !_arrayItemFields.contains(e.key) && !e.value.disabled,
            )
            .map((e) => MapEntry(
                  e.key,
                  _objectArrayStructures.containsKey(e.key)
                      ? getValue(e.key)
                      : e.value.value,
                )),
      ),
    );
  }

  void setError<V>(ValidasiField<T, V> field, String message,
      {String rule = 'Manual', bool overwrite = true}) {
    _throwIfDisposed();
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;
    if (!overwrite && fc.syncErrors.isNotEmpty) return;
    fc.updateErrors([
      FieldValidationError(ValidationError(rule: rule, message: message)),
    ]);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearErrors<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;
    fc.updateErrors([]);
    fc.setAsyncError(null);
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void clearAllErrors() {
    _throwIfDisposed();
    for (final fc in _fields.values) {
      fc.updateErrors([]);
      fc.setAsyncError(null);
    }
    _formSignals.formErrors = [];
    _formSignals.syncFieldErrors(_fields);
    notifyListeners();
  }

  void reset() {
    _throwIfDisposed();
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _formSignals.reset();
    for (final fc in _fields.values) {
      fc.reset();
    }
    for (final parentField in _fields.keys.toList()) {
      if (parentField is _ArrayItemField) continue;
      final fc = _fields[parentField];
      if (fc != null && fc.value is List) {
        _rebuildArrayItems(parentField as ValidasiField<T, List<dynamic>>);
      }
    }
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  bool _disposed = false;

  void _throwIfDisposed() {
    if (_disposed) {
      throw StateError(
        'Cannot use a disposed ValidasiFormController. '
        'The form controller has been disposed and can no longer be accessed.',
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
    _asyncValidators.clear();
    _objectArrayStructures.clear();
    for (final field in _fields.keys.toList()) {
      _unregister(field);
    }
    _formSignals.dispose();
    super.dispose();
  }
}
