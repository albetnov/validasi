import 'package:flutter/widgets.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';
import 'package:validasi_ui/src/models/field_state.dart';
import 'package:validasi_ui/src/widgets/validasi_form_field.dart';
import 'package:validasi_ui/src/widgets/validasi_text_controller.dart';

class ValidasiTextField<T, V> extends StatefulWidget {
  final ValidasiField<T, V> field;
  final ValidasiTextController? controller;
  final Widget Function(
      BuildContext, ValidasiFieldState<V>, ValidasiTextController) builder;
  final ValidationMode? mode;
  final ReValidationMode? reValidateMode;
  final bool disabled;
  final Future<String?> Function(V?)? validator;
  final Duration debounceDuration;
  final bool? shouldUnregister;

  const ValidasiTextField({
    required this.field,
    required this.builder,
    this.controller,
    this.mode,
    this.reValidateMode,
    this.disabled = false,
    this.validator,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.shouldUnregister,
    super.key,
  });

  @override
  State<ValidasiTextField<T, V>> createState() =>
      _ValidasiTextFieldState<T, V>();
}

class _ValidasiTextFieldState<T, V> extends State<ValidasiTextField<T, V>> {
  late final ValidasiTextController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ValidasiTextController();
    _ownsController = widget.controller == null;
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValidasiFormField<T, V>(
      field: widget.field,
      mode: widget.mode,
      reValidateMode: widget.reValidateMode,
      disabled: widget.disabled,
      validator: widget.validator,
      debounceDuration: widget.debounceDuration,
      shouldUnregister: widget.shouldUnregister,
      builder: (context, state) {
        _syncTo(state.value);
        return widget.builder(context, state, _controller);
      },
    );
  }

  void _syncTo(V? value) {
    final str = value?.toString() ?? '';
    if (_controller.text != str) {
      _controller.text = str;
    }
  }
}
