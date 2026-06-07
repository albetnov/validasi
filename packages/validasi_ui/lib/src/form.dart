import 'package:flutter/widgets.dart';
import 'package:validasi_ui/src/controller.dart';
import 'package:validasi_ui/src/validation_mode.dart';

class ValidasiForm<T> extends StatefulWidget {
  final Widget child;
  final ValidasiFormController<T>? controller;
  final ValidationMode mode;
  final ReValidationMode reValidateMode;
  final T? initialValues;

  const ValidasiForm({
    required this.child,
    this.controller,
    this.mode = ValidationMode.onSubmit,
    this.reValidateMode = ReValidationMode.onChange,
    this.initialValues,
    super.key,
  });

  static ValidasiFormController<T> of<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope<T>>();
    assert(scope != null,
        'ValidasiForm.of<$T>() called outside a ValidasiForm<$T>.');
    return scope!.controller;
  }

  static (ValidationMode, ReValidationMode) modeOf<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope<T>>();
    assert(scope != null,
        'ValidasiForm.modeOf<$T>() called outside a ValidasiForm<$T>.');
    return (scope!.mode, scope.reValidateMode);
  }

  @override
  State<ValidasiForm<T>> createState() => _FormState<T>();
}

class _FormState<T> extends State<ValidasiForm<T>> {
  late final ValidasiFormController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ValidasiFormController<T>();
    if (widget.initialValues != null) {
      _controller.setInitialValues(widget.initialValues as T);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScope<T>(
      controller: _controller,
      mode: widget.mode,
      reValidateMode: widget.reValidateMode,
      child: widget.child,
    );
  }
}

class _FormScope<T> extends InheritedWidget {
  final ValidasiFormController<T> controller;
  final ValidationMode mode;
  final ReValidationMode reValidateMode;

  const _FormScope({
    required this.controller,
    required this.mode,
    required this.reValidateMode,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FormScope<T> oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.mode != mode ||
      oldWidget.reValidateMode != reValidateMode;
}
