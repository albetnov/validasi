part of 'controller.dart';

/// Narrow contract provided to [ValidasiArrayRegistry] and
/// [ValidasiAsyncCoordinator] so they only access controller functionality
/// through explicit methods — never through raw internal maps.
class ValidasiControllerContext<T> {
  ValidasiControllerContext._(this._ctrl);

  final ValidasiFormController<T> _ctrl;

  /// Returns the field signals for a registered field, or `null` if not found.
  ValidasiFieldSignals<dynamic>? fieldSignal(ValidasiField<T, dynamic> field) =>
      _ctrl._fields[field];

  /// Looks up a registered field by name, or `null` if not found.
  ValidasiField<T, dynamic>? fieldByName(String name) =>
      _ctrl._fieldsByName[name];

  /// Register a new field.
  void register<V>(ValidasiField<T, V> field, {V? initialValue}) =>
      _ctrl.register(field, initialValue: initialValue);

  /// Unregister a single field without recursive sub-field cleanup.
  void unregisterField(ValidasiField<T, dynamic> field) =>
      _ctrl.unregisterField(field);

  /// Get-or-create field controller.
  ValidasiFieldSignals<V> getFieldController<V>(ValidasiField<T, V> field) =>
      _ctrl.getFieldController(field);

  /// Suppress [notifyListeners] until [endBatch] is called.
  void beginBatch() => _ctrl._isBatching = true;

  /// Re-enable [notifyListeners] after [beginBatch].
  void endBatch() => _ctrl._isBatching = false;

  /// Synchronise all field errors into the form-level error signal.
  void syncFieldErrors() => _ctrl._formSignals.syncFieldErrors(_ctrl._fields);

  /// Notify listeners.
  void notifyListeners() => _ctrl.notifyListeners();

  /// Cancel async validation for a single field.
  void cancelAsyncField(ValidasiField<T, dynamic> field) =>
      _ctrl._asyncCoordinator.cancelField(field);

  /// Migrate async validator state during slot migration.
  void migrateAsyncValidator(
    ValidasiField<T, dynamic> srcField,
    ValidasiField<T, dynamic> destField,
    ValidasiFieldSignals<dynamic> srcFc,
    ValidasiFieldSignals<dynamic> destFc,
  ) =>
      _ctrl._asyncCoordinator.migrateValidator(
        srcField,
        destField,
        srcFc,
        destFc,
      );

  /// Trigger debounced async validation for a single field.
  Future<void> triggerAsyncValidation<V>(ValidasiField<T, V> field) =>
      _ctrl.triggerAsyncValidation(field);
}
