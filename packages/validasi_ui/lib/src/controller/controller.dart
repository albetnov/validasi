library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/array_field_names.dart';
import 'package:validasi_ui/src/controller/array_registry.dart';
import 'package:validasi_ui/src/controller/async_coordinator.dart';
import 'package:validasi_ui/src/controller/watch_mixin.dart';
import 'package:validasi_ui/src/models/error.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';
import 'package:validasi_ui/src/signals/form_signals.dart';

part 'context.dart';

class ValidasiFormController<T> extends ChangeNotifier
    with WatchMixin<T>
    implements ValidasiFieldReader<T> {
  // ── Internal state (only accessed by [ValidasiControllerContext]) ──

  final _fields = <ValidasiField<T, dynamic>, ValidasiFieldSignals>{};
  final _fieldsByName = <String, ValidasiField<T, dynamic>>{};
  final _formSignals = ValidasiFormSignals();
  bool _isBatching = false;

  // ── Coordinators ──

  late final ValidasiArrayRegistry<T> _arrayRegistry;
  late final ValidasiAsyncCoordinator<T> _asyncCoordinator;

  // ── Subscriptions ──

  final _subscriptions = <ValidasiField<T, dynamic>, List<void Function()>>{};

  // ── Configuration ──

  final ValidasiSchema<T> schema;
  final FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)?
      formValidator;

  ValidasiFormController({
    required this.schema,
    this.formValidator,
  }) {
    final ctx = ValidasiControllerContext<T>._(this);
    _asyncCoordinator = ValidasiAsyncCoordinator<T>(ctx);
    _arrayRegistry = ValidasiArrayRegistry<T>(ctx, this);
  }

  T? _initialModel;

  // ── Form-level getters ──

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

  // ── Field lifecycle ──

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
      onSubmit(schema.allocate(this));
    };
  }

  Future<void> Function() submitAsync(void Function(T) onSubmit) {
    _throwIfDisposed();
    return () async {
      if (!await validateAsync()) {
        markSubmitted();
        return;
      }
      onSubmit(schema.allocate(this));
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

    _formSignals.isDirty =
        _fields.values.any((f) => !f.disabled && f.isDirty.value);
    _formSignals.isTouched =
        _fields.values.any((f) => !f.disabled && f.touched);

    _subscriptions[field] = [
      fc.isDirty.subscribe((dirty) {
        final newIsDirty =
            _fields.values.any((f) => !f.disabled && f.isDirty.value);
        if (_formSignals.isDirty != newIsDirty) {
          _formSignals.isDirty = newIsDirty;
          notifyListeners();
        }
      }),
      fc.touchedSignal.subscribe((touched) {
        final newIsTouched =
            _fields.values.any((f) => !f.disabled && f.touched);
        if (_formSignals.isTouched != newIsTouched) {
          _formSignals.isTouched = newIsTouched;
          notifyListeners();
        }
      }),
    ];
  }

  void unregisterField(ValidasiField<T, dynamic> field) {
    _asyncCoordinator.cancelField(field);
    final subs = _subscriptions.remove(field);
    if (subs != null) {
      for (final sub in subs) {
        sub();
      }
    }
    final fc = _fields.remove(field);
    fc?.dispose();
    _fieldsByName.remove(field.name);
    _arrayRegistry.onFieldUnregistered(field);
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
    _arrayRegistry.unregisterSubFields(key);
    unregisterField(key);
    syncFieldErrors();
    notifyListeners();
  }

  // ── Wrappers used by [ValidasiControllerContext] (and internally) ──

  void syncFieldErrors() => _formSignals.syncFieldErrors(_fields);

  // ── Initial values ──

  void setInitialValues(T model) {
    _throwIfDisposed();
    _asyncCoordinator.cancelAll();
    _initialModel = model;
    for (final entry in _fields.entries) {
      entry.value.setInitialValue(entry.key.extract(model));
      entry.value.isValidating = false;
      entry.value.setAsyncError(null);
    }
    _arrayRegistry.rebuildAllArrayItems();
    syncFieldErrors();
    notifyListeners();
  }

  // ── Value get/set ──

  @override
  V? getValue<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final key = field as ValidasiField<T, dynamic>;
    if (_arrayRegistry.hasArrayStructure(key)) {
      return _arrayRegistry.reconstructAll(key) as V?;
    }
    return getFieldController(field).value;
  }

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    _throwIfDisposed();
    assert(
      // Runtime guard for values passed as `dynamic` or `Object`,
      // where the static type system can't enforce the concrete type.
      value == null || value is V, // ignore: unnecessary_type_check
      'Type mismatch for field "${field.name}": '
      'expected $V, got ${value.runtimeType}. '
      'This is a developer error — check the onChanged callback or parser.',
    );
    final fc = getFieldController(field);
    if (fc.disabled) return;
    fc.value = value;
    fc.markTouched();

    final parentField = _arrayRegistry.getArrayItemParent(field);
    if (parentField != null) {
      final name = field.name;
      final index = ArrayFieldName.slotIndex(name);
      if (index != null && !ArrayFieldName.isObjectSubField(name)) {
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

  // ── Array operations (proxied to registry) ──

  ValidasiField<T, V>? getArrayItemField<V>(
    ValidasiField<T, List<V>> field,
    int index,
  ) {
    _throwIfDisposed();
    return _arrayRegistry.getArrayItemField(field, index);
  }

  int getArrayItemCount(ValidasiField<T, dynamic> field) {
    _throwIfDisposed();
    return _arrayRegistry.getArrayItemCount(field);
  }

  ValidasiField<T, SubV>? getArraySubField<SubV>(
    ValidasiField<T, dynamic> field,
    int index,
    String fieldName,
  ) {
    _throwIfDisposed();
    return _arrayRegistry.getArraySubField(field, index, fieldName);
  }

  void appendArrayItem<V>(
    ValidasiField<T, List<V>> field,
    V value, {
    List<ValidasiField<T, dynamic>> Function(int index)? indexedFields,
    dynamic Function(ValidasiFormController<T>, int)? reconstructItem,
    List<dynamic> Function(ValidasiFormController<T>)? reconstructAll,
  }) {
    _throwIfDisposed();
    _arrayRegistry.appendArrayItem(
      field,
      value,
      indexedFields: indexedFields,
      reconstructItem: reconstructItem,
      reconstructAll: reconstructAll,
    );
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
    _arrayRegistry.insertArrayItem(
      field,
      index,
      value,
      indexedFields: indexedFields,
      reconstructItem: reconstructItem,
      reconstructAll: reconstructAll,
    );
  }

  void removeArrayItem<V>(ValidasiField<T, List<V>> field, int index) {
    _throwIfDisposed();
    _arrayRegistry.removeArrayItem(field, index);
  }

  void swapArrayItems<V>(ValidasiField<T, List<V>> field, int i, int j) {
    _throwIfDisposed();
    _arrayRegistry.swapArrayItems(field, i, j);
  }

  // ── Field state manipulation ──

  void setFieldDisabled<V>(ValidasiField<T, V> field, bool disabled) {
    _throwIfDisposed();
    final fc = getFieldController(field);
    if (fc.disabled == disabled) return;
    fc.disabled = disabled;
    if (disabled) {
      fc.updateErrors([]);
      fc.setAsyncError(null);
    }
    syncFieldErrors();
    notifyListeners();
  }

  void setFieldValidator<V>(
    ValidasiField<T, V> field,
    Future<String?> Function(V?)? validator, {
    Duration debounce = const Duration(milliseconds: 300),
  }) {
    _throwIfDisposed();
    _asyncCoordinator.setFieldValidator(
      field,
      validator,
      debounce: debounce,
    );
  }

  Future<void> triggerAsyncValidation<V>(ValidasiField<T, V> field) async {
    _throwIfDisposed();
    await _asyncCoordinator.triggerAsyncValidation(field);
  }

  // ── Error management ──

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
    syncFieldErrors();
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
      syncFieldErrors();
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
    syncFieldErrors();
    notifyListeners();
    return isValid;
  }

  Future<bool> validateAsync() async {
    _throwIfDisposed();
    if (formValidator != null) {
      final result = await formValidator!(this);
      _distributeFormErrors(result.errors);
      syncFieldErrors();
      notifyListeners();
      return result.isValid;
    }
    for (final entry in _fields.entries) {
      if (entry.value.disabled) continue;
      final result = await entry.key.validateAsync(entry.value.value);
      _applyErrors(entry.key, result.errors);
    }
    syncFieldErrors();
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
              (e) =>
                  !_arrayRegistry.isArrayItemField(e.key) && !e.value.disabled,
            )
            .map((e) => MapEntry(
                  e.key,
                  _arrayRegistry.hasArrayStructure(e.key)
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
    syncFieldErrors();
    notifyListeners();
  }

  void clearErrors<V>(ValidasiField<T, V> field) {
    _throwIfDisposed();
    final fc = _fields[field];
    if (fc == null || fc.disabled) return;
    fc.updateErrors([]);
    fc.setAsyncError(null);
    syncFieldErrors();
    notifyListeners();
  }

  void clearAllErrors() {
    _throwIfDisposed();
    for (final fc in _fields.values) {
      fc.updateErrors([]);
      fc.setAsyncError(null);
    }
    _formSignals.formErrors = [];
    syncFieldErrors();
    notifyListeners();
  }

  // ── Reset ──

  void reset() {
    _throwIfDisposed();
    _asyncCoordinator.cancelAll();
    _formSignals.reset();
    for (final fc in _fields.values) {
      fc.reset();
    }
    _arrayRegistry.rebuildListFields(_fields.keys.toList());
    notifyListeners();
  }

  // ── Notification / Lifecycle ──

  @override
  void notifyListeners() {
    if (_disposed || _isBatching) return;
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
    _asyncCoordinator.cancelAll();
    _arrayRegistry.clear();
    for (final field in _fields.keys.toList()) {
      unregisterField(field);
    }
    _formSignals.dispose();
    super.dispose();
  }
}
