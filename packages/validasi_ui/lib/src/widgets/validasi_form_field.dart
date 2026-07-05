import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/models/field_state.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';
import 'package:validasi_ui/src/widgets/validasi_form.dart';

class ValidasiFormField<T, V> extends StatefulWidget {
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
  State<ValidasiFormField<T, V>> createState() => _FormFieldState<T, V>();
}

class _FormFieldState<T, V> extends State<ValidasiFormField<T, V>> {
  ValidasiFormController<T>? _controller;

  @override
  void dispose() {
    _controller?.removedFields.add(widget.field);
    super.dispose();
  }

  @override
  void didUpdateWidget(ValidasiFormField<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field != widget.field) {
      final controller = ValidasiForm.of<T>(context);
      _controller = controller;
      controller.removedFields.add(oldWidget.field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    _controller = controller;
    final fc = controller.getFieldController<V>(widget.field);

    controller.setFieldDisabled(widget.field, widget.disabled);
    controller.setFieldValidator(
      widget.field,
      widget.validator,
      debounce: widget.debounceDuration,
    );

    final effectiveShouldUnregister =
        widget.shouldUnregister ?? ValidasiForm.shouldUnregisterOf<T>(context);

    return SignalBuilder(
      builder: (context) {
        final value = fc.value;
        final errors = fc.errors;
        final isDirty = fc.isDirty.value;
        final isTouched = fc.touched;
        final isSubmitted = controller.isSubmitted;
        final isValidating = fc.isValidating;

        final state = ValidasiFieldState<V>(
          value: value,
          errors: errors.map((e) => e.error).toList(),
          onChanged: widget.disabled
              ? (_) {}
              : (v) {
                  controller.setValue<V>(widget.field, v);
                  final (formMode, formReMode) =
                      ValidasiForm.modeOf<T>(context);
                  final effectiveReMode = widget.reValidateMode ?? formReMode;
                  if (isSubmitted) {
                    if (effectiveReMode == ReValidationMode.onChange) {
                      controller.validateField<V>(widget.field);
                    }
                  } else {
                    final effectiveMode = widget.mode ?? formMode;
                    if (effectiveMode == ValidationMode.onChange) {
                      controller.validateField<V>(widget.field);
                    }
                  }
                  controller.triggerAsyncValidation(widget.field);
                },
          validate: () => controller.validateField<V>(widget.field),
          onFocusChange: widget.disabled
              ? null
              : (hasFocus) {
                  if (!hasFocus) {
                    fc.markTouched();
                    final (formMode, formReMode) =
                        ValidasiForm.modeOf<T>(context);
                    final effectiveReMode = widget.reValidateMode ?? formReMode;
                    if (isSubmitted) {
                      if (effectiveReMode == ReValidationMode.onBlur) {
                        controller.validateField<V>(widget.field);
                      }
                      return;
                    }
                    final effectiveMode = widget.mode ?? formMode;
                    if (effectiveMode == ValidationMode.onBlur) {
                      controller.validateField<V>(widget.field);
                    }
                  }
                },
          isDirty: isDirty,
          isTouched: isTouched,
          disabled: widget.disabled,
          isValidating: isValidating,
          setError: widget.disabled
              ? null
              : (message, {overwrite = true}) => controller.setError(
                    widget.field,
                    message,
                    overwrite: overwrite,
                  ),
          clearErrors: widget.disabled
              ? null
              : () => controller.clearErrors(widget.field),
        );

        final child = widget.builder(context, state);

        if (!effectiveShouldUnregister) {
          controller.untrackField(widget.field);
          return child;
        }

        controller.markFieldTracked(widget.field);

        return child;
      },
    );
  }
}
