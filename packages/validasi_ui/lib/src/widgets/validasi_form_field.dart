import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'package:validasi/validasi.dart';
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

  const ValidasiFormField({
    required this.field,
    required this.builder,
    this.mode,
    this.reValidateMode,
    this.disabled = false,
    this.validator,
    this.debounceDuration = const Duration(milliseconds: 300),
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
      setError:
          disabled ? null : (message) => controller.setError(field, message),
      clearErrors: disabled ? null : () => controller.clearErrors(field),
    );

    return builder(context, state);
  }
}
