import 'package:flutter/widgets.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller.dart';
import 'package:validasi_ui/src/field_state.dart';
import 'package:validasi_ui/src/form.dart';
import 'package:validasi_ui/src/validation_mode.dart';

class ValidasiFormField<T, V> extends StatefulWidget {
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
  State<ValidasiFormField<T, V>> createState() => _FormFieldState<T, V>();
}

class _FormFieldState<T, V> extends State<ValidasiFormField<T, V>> {
  ValidasiFormController<T>? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ValidasiForm.of<T>(context);
    if (controller != _controller) {
      _controller = controller;
      _controller!.register<V>(widget.field);
    }
  }

  void _validateOnBlur() {
    final controller = _controller;
    if (controller == null) return;

    final (formMode, formReMode) = ValidasiForm.modeOf<T>(context);
    final effectiveReMode = widget.reValidateMode ?? formReMode;

    if (controller.isSubmitted) {
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

  void _handleChanged(V? value) {
    final controller = _controller;
    if (controller == null) return;

    controller.setValue<V>(widget.field, value);

    final (formMode, formReMode) = ValidasiForm.modeOf<T>(context);
    final effectiveReMode = widget.reValidateMode ?? formReMode;

    if (controller.isSubmitted) {
      if (effectiveReMode == ReValidationMode.onChange) {
        controller.validateField<V>(widget.field);
      }
      return;
    }

    final effectiveMode = widget.mode ?? formMode;
    if (effectiveMode == ValidationMode.onChange) {
      controller.validateField<V>(widget.field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    final value = controller.getValue<V>(widget.field);
    final errors = controller.getErrors<V>(widget.field);

    final state = ValidasiFieldState<V>(
      value: value,
      errors: errors,
      onChanged: _handleChanged,
      validate: () => controller.validateField<V>(widget.field),
      onFocusChange: (hasFocus) {
        if (!hasFocus) _validateOnBlur();
      },
      isDirty: controller.isFieldDirty(widget.field),
      isTouched: controller.isFieldTouched(widget.field),
    );

    return widget.builder(context, state);
  }
}
