import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/models/field_state.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';
import 'package:validasi_ui/src/widgets/validasi_form.dart';

class ValidasiFormField<T, V> extends SignalWidget {
  final ValidasiField<T, V> field;
  final Widget Function(BuildContext context, ValidasiFieldState<V> state)
      builder;
  final ValidationMode? mode;
  final ReValidationMode? reValidateMode;
  final bool disabled;
  final Future<String?> Function(V?)? validator;
  final Duration debounceDuration;
  final bool? shouldUnregister;

  const ValidasiFormField({
    required this.field,
    required this.builder,
    this.mode,
    this.reValidateMode,
    this.disabled = false,
    this.validator,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.shouldUnregister,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    final fc = controller.getFieldController<V>(field);

    controller.setFieldDisabled(field, disabled);
    controller.setFieldValidator(
      field,
      validator,
      debounce: debounceDuration,
    );

    final value = fc.value;
    final errors = fc.errors;
    final isDirty = fc.isDirty.value;
    final isTouched = fc.touched;
    final isSubmitted = controller.isSubmitted;
    final isValidating = fc.isValidating;

    final effectiveShouldUnregister =
        shouldUnregister ?? ValidasiForm.shouldUnregisterOf<T>(context);

    final state = ValidasiFieldState<V>(
      value: value,
      errors: errors.map((e) => e.error).toList(),
      onChanged: disabled
          ? (_) {}
          : (v) {
              controller.setValue<V>(field, v);
              final (formMode, formReMode) = ValidasiForm.modeOf<T>(context);
              final effectiveReMode = reValidateMode ?? formReMode;
              if (isSubmitted) {
                if (effectiveReMode == ReValidationMode.onChange) {
                  controller.validateField<V>(field);
                }
              } else {
                final effectiveMode = mode ?? formMode;
                if (effectiveMode == ValidationMode.onChange) {
                  controller.validateField<V>(field);
                }
              }
              controller.triggerAsyncValidation(field);
            },
      validate: () => controller.validateField<V>(field),
      onFocusChange: disabled
          ? null
          : (hasFocus) {
              if (!hasFocus) {
                fc.markTouched();
                final (formMode, formReMode) = ValidasiForm.modeOf<T>(context);
                final effectiveReMode = reValidateMode ?? formReMode;
                if (isSubmitted) {
                  if (effectiveReMode == ReValidationMode.onBlur) {
                    controller.validateField<V>(field);
                  }
                  return;
                }
                final effectiveMode = mode ?? formMode;
                if (effectiveMode == ValidationMode.onBlur) {
                  controller.validateField<V>(field);
                }
              }
            },
      isDirty: isDirty,
      isTouched: isTouched,
      disabled: disabled,
      isValidating: isValidating,
      setError: disabled
          ? null
          : (message, {overwrite = true}) =>
              controller.setError(field, message, overwrite: overwrite),
      clearErrors: disabled ? null : () => controller.clearErrors(field),
    );

    final child = builder(context, state);

    if (!effectiveShouldUnregister) return child;

    return _FieldDisposer<T>(
      controller: controller,
      field: field,
      child: child,
    );
  }
}

class _FieldDisposer<T> extends StatefulWidget {
  final ValidasiFormController<T> controller;
  final ValidasiField<T, dynamic> field;
  final Widget child;

  const _FieldDisposer({
    required this.controller,
    required this.field,
    required this.child,
  });

  @override
  State<_FieldDisposer<T>> createState() => _FieldDisposerState<T>();
}

class _FieldDisposerState<T> extends State<_FieldDisposer<T>> {
  @override
  void dispose() {
    widget.controller.unregister(widget.field);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
