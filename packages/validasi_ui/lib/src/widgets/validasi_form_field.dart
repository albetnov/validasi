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

  const ValidasiFormField({
    required this.field,
    required this.builder,
    this.mode,
    this.reValidateMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    final fc = controller.getFieldController<V>(field);

    final value = fc.value;
    final errors = fc.errors;
    final isDirty = fc.isDirty.value;
    final isTouched = fc.touched;
    final isSubmitted = controller.isSubmitted;

    final state = ValidasiFieldState<V>(
      value: value,
      errors: errors.map((e) => e.error).toList(),
      onChanged: (v) {
        controller.setValue<V>(field, v);
        final (formMode, formReMode) = ValidasiForm.modeOf<T>(context);
        final effectiveReMode = reValidateMode ?? formReMode;
        if (isSubmitted) {
          if (effectiveReMode == ReValidationMode.onChange) {
            controller.validateField<V>(field);
          }
          return;
        }
        final effectiveMode = mode ?? formMode;
        if (effectiveMode == ValidationMode.onChange) {
          controller.validateField<V>(field);
        }
      },
      validate: () => controller.validateField<V>(field),
      onFocusChange: (hasFocus) {
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
    );

    return builder(context, state);
  }
}
