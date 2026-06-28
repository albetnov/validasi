import 'dart:async';

import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';

/// Internal state for a single field's async validation pipeline.
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

/// Coordinates async validation lifecycle for a [ValidasiFormController].
///
/// Owns the async validator state map, field-level validator registration,
/// debounced execution, and cancellation. The controller holds one instance
/// and proxies `setFieldValidator` / `triggerAsyncValidation` here. Never
/// accesses controller internals directly — only through the
/// [ValidasiControllerContext] contract.
class ValidasiAsyncCoordinator<T> {
  final ValidasiControllerContext<T> _ctx;

  ValidasiAsyncCoordinator(this._ctx);

  // ---------------------------------------------------------------------------
  // Async validator state
  // ---------------------------------------------------------------------------

  final _asyncValidators = <ValidasiField<T, dynamic>, _AsyncValidatorState>{};

  // ---------------------------------------------------------------------------
  // Public API (proxied by controller)
  // ---------------------------------------------------------------------------

  /// Register or remove an async field validator.
  void setFieldValidator<V>(
    ValidasiField<T, V> field,
    Future<String?> Function(V?)? validator, {
    Duration debounce = const Duration(milliseconds: 300),
  }) {
    if (validator == null) {
      _asyncValidators.remove(field)?.cancel();
      final fc = _ctx.fieldSignal(field);
      if (fc != null) {
        fc.setAsyncError(null);
        _ctx.syncFieldErrors();
        _ctx.notifyListeners();
      }
      return;
    }
    final state = _asyncValidators.putIfAbsent(
      field,
      () => _AsyncValidatorState(),
    );
    // Safe ternary for values passed as `dynamic` or `Object`;
    // if the value doesn't match V, pass null instead of throwing.
    state.validator = (value) => validator(value is V ? value : null);
    state.debounce = debounce;
  }

  /// Trigger debounced async validation for a single field.
  Future<void> triggerAsyncValidation<V>(ValidasiField<T, V> field) async {
    final state = _asyncValidators[field];
    if (state == null || state.validator == null) return;
    final fc = _ctx.fieldSignal(field);
    if (fc == null || fc.disabled) return;

    state.cancel();
    final version = ++state.version;
    final value = fc.value;

    state.debounceTimer = Timer(state.debounce, () async {
      fc.isValidating = true;
      _ctx.notifyListeners();

      try {
        final error = await state.validator!(value);
        if (version != state.version) return;
        fc.setAsyncError(error);
        _ctx.syncFieldErrors();
        _ctx.notifyListeners();
      } catch (_) {
        if (version != state.version) return;
        _ctx.notifyListeners();
      } finally {
        fc.isValidating = false;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Lifecycle hooks (called by controller)
  // ---------------------------------------------------------------------------

  /// Cancel all pending async validators.
  void cancelAll() {
    for (final state in _asyncValidators.values) {
      state.cancel();
    }
  }

  /// Cancel a single field's async validator.
  void cancelField(ValidasiField<T, dynamic> field) {
    _asyncValidators.remove(field)?.cancel();
  }

  // ---------------------------------------------------------------------------
  // Slot-migration hooks (called by ValidasiArrayRegistry)
  // ---------------------------------------------------------------------------

  /// Migrate async state from [srcField] to [destField].
  ///
  /// If the source was in-flight (validating or debounce pending), the dest
  /// field's validation is re-triggered automatically.
  void migrateValidator(
    ValidasiField<T, dynamic> srcField,
    ValidasiField<T, dynamic> destField,
    ValidasiFieldSignals<dynamic> srcFc,
    ValidasiFieldSignals<dynamic> destFc,
  ) {
    final state = _asyncValidators.remove(srcField);
    if (state == null) return;
    _asyncValidators[destField] = state;
    final wasInFlight =
        srcFc.isValidating || (state.debounceTimer?.isActive ?? false);
    state.cancel();
    destFc.isValidating = false;
    if (wasInFlight) {
      _ctx.triggerAsyncValidation(destField);
    }
  }
}
