import 'package:flutter/material.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';
import 'package:validasi_ui/src/widgets/validasi_form_field.dart';

/// A convenience widget for editing a `String` field with a [TextField].
class ValidasiTextFormField<T> extends StatefulWidget {
  final ValidasiField<T, String> field;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final bool disabled;
  final ValidationMode? mode;
  final ReValidationMode? reValidateMode;
  final Future<String?> Function(String?)? validator;
  final Duration debounceDuration;
  final bool? shouldUnregister;

  const ValidasiTextFormField({
    required this.field,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.disabled = false,
    this.mode,
    this.reValidateMode,
    this.validator,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.shouldUnregister,
    super.key,
  });

  @override
  State<ValidasiTextFormField<T>> createState() =>
      _ValidasiTextFormFieldState<T>();
}

class _ValidasiTextFormFieldState<T> extends State<ValidasiTextFormField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValidasiFormField<T, String>(
      field: widget.field,
      disabled: widget.disabled,
      mode: widget.mode,
      reValidateMode: widget.reValidateMode,
      validator: widget.validator,
      debounceDuration: widget.debounceDuration,
      shouldUnregister: widget.shouldUnregister,
      builder: (context, state) {
        final text = state.value ?? '';
        if (_controller.text != text) {
          _controller.text = text;
        }

        return TextField(
          controller: _controller,
          onChanged: state.onChanged,
          decoration: widget.decoration?.copyWith(errorText: state.errorText) ??
              InputDecoration(errorText: state.errorText),
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          enabled: !widget.disabled,
        );
      },
    );
  }
}
