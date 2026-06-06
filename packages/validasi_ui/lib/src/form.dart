import 'package:flutter/widgets.dart';
import 'package:validasi_ui/src/controller.dart';

class ValidasiForm<T> extends StatefulWidget {
  final Widget child;
  final ValidasiFormController<T>? controller;

  const ValidasiForm({required this.child, this.controller, super.key});

  static ValidasiFormController<T> of<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope<T>>();
    assert(scope != null,
        'ValidasiForm.of<$T>() called outside a ValidasiForm<$T>.');
    return scope!.controller;
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
      child: widget.child,
    );
  }
}

class _FormScope<T> extends InheritedWidget {
  final ValidasiFormController<T> controller;

  const _FormScope({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FormScope<T> oldWidget) =>
      oldWidget.controller != controller;
}
