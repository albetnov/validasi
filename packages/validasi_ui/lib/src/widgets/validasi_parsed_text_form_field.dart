import 'package:flutter/material.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';
import 'package:validasi_ui/src/widgets/validasi_form_field.dart';

/// A convenience widget for editing a field whose raw value is a [String]
/// but whose model value is of type [V].
class ValidasiParsedTextFormField<T, V> extends StatefulWidget {
  final ValidasiField<T, V> field;
  final V? Function(String text) parser;
  final String? Function(V? value)? format;
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
  final Future<String?> Function(V?)? validator;
  final Duration debounceDuration;
  final bool? shouldUnregister;

  const ValidasiParsedTextFormField({
    required this.field,
    required this.parser,
    this.format,
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
  State<ValidasiParsedTextFormField<T, V>> createState() =>
      _ValidasiParsedTextFormFieldState<T, V>();
}

class _ValidasiParsedTextFormFieldState<T, V>
    extends State<ValidasiParsedTextFormField<T, V>> {
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

  String _format(V? value) {
    if (widget.format != null) return widget.format!(value) ?? '';
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return ValidasiFormField<T, V>(
      field: widget.field,
      disabled: widget.disabled,
      mode: widget.mode,
      reValidateMode: widget.reValidateMode,
      validator: widget.validator,
      debounceDuration: widget.debounceDuration,
      shouldUnregister: widget.shouldUnregister,
      builder: (context, state) {
        final text = _format(state.value);
        if (_controller.text != text) {
          _controller.text = text;
        }

        return TextField(
          controller: _controller,
          onChanged: (raw) => state.onChanged(widget.parser(raw)),
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
