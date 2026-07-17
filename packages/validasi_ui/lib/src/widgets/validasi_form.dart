import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/models/validation_mode.dart';

/// Callable submit handle passed to [ValidasiForm]'s builder.
///
/// `submit(onSubmit)` behaves exactly like the old sync-only
/// `SubmitHandler<T>` function it replaces (Dart invokes a `call()`-defining
/// class with function-call syntax), while `submit.async(onSubmit)` exposes
/// the async submit path without growing the builder's parameter list.
class ValidasiSubmit<T> {
  final ValidasiFormController<T> _controller;
  const ValidasiSubmit(this._controller);

  VoidCallback call(void Function(T) onSubmit) => _controller.submit(onSubmit);

  Future<void> Function() async(void Function(T) onSubmit) =>
      _controller.submitAsync(onSubmit);
}

class ValidasiForm<T> extends StatefulWidget {
  final Widget Function(BuildContext context, ValidasiSubmit<T> submit) builder;
  final ValidasiFormController<T>? controller;
  final ValidasiSchema<T>? schema;
  final FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)?
      formValidator;
  final ValidationMode mode;
  final ReValidationMode reValidateMode;
  final T? initialValues;
  final bool shouldUnregister;

  const ValidasiForm({
    required this.builder,
    this.schema,
    this.controller,
    this.formValidator,
    this.mode = ValidationMode.onSubmit,
    this.reValidateMode = ReValidationMode.onChange,
    this.initialValues,
    this.shouldUnregister = false,
    super.key,
  }) : assert(controller != null || schema != null,
            'ValidasiForm needs a `controller` or a `schema`.');

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

  static bool shouldUnregisterOf<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope<T>>();
    assert(scope != null,
        'ValidasiForm.shouldUnregisterOf<$T>() called outside a ValidasiForm<$T>.');
    return scope!.shouldUnregister;
  }

  @override
  State<ValidasiForm<T>> createState() => _FormState<T>();
}

class _FormState<T> extends State<ValidasiForm<T>> {
  late final ValidasiFormController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ValidasiFormController<T>(
          schema: widget.schema!,
          formValidator: widget.formValidator,
        );
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
      shouldUnregister: widget.shouldUnregister,
      child: widget.builder(context, ValidasiSubmit<T>(_controller)),
    );
  }
}

class _FormScope<T> extends InheritedWidget {
  final ValidasiFormController<T> controller;
  final ValidationMode mode;
  final ReValidationMode reValidateMode;
  final bool shouldUnregister;

  const _FormScope({
    required this.controller,
    required this.mode,
    required this.reValidateMode,
    required this.shouldUnregister,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FormScope<T> oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.mode != mode ||
      oldWidget.reValidateMode != reValidateMode ||
      oldWidget.shouldUnregister != shouldUnregister;
}
