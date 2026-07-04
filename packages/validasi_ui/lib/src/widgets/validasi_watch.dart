import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller/controller.dart';
import 'package:validasi_ui/src/widgets/validasi_form.dart';

class ValidasiWatchForm<T> extends StatelessWidget {
  final ValidasiFormController<T>? _controller;
  final Widget Function(BuildContext, ValidasiFormController<T>) _builder;

  const ValidasiWatchForm._({
    super.key,
    ValidasiFormController<T>? controller,
    required Widget Function(BuildContext, ValidasiFormController<T>) builder,
  })  : _controller = controller,
        _builder = builder;

  @override
  Widget build(BuildContext context) {
    final controller = _controller ?? ValidasiForm.of<T>(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) => _builder(context, controller),
    );
  }
}

class ValidasiWatchField<T, V> extends StatelessWidget {
  final ValidasiFormController<T>? _controller;
  final ValidasiField<T, V> field;
  final Widget Function(BuildContext, V?) builder;

  const ValidasiWatchField._({
    super.key,
    ValidasiFormController<T>? controller,
    required this.field,
    required this.builder,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    final controller = _controller ?? ValidasiForm.of<T>(context);
    final fc = controller.getFieldController<V>(field);
    return SignalBuilder(
      dependencies: [fc.valueSignal],
      builder: (context) => builder(context, fc.value),
    );
  }
}

abstract final class ValidasiWatch {
  const ValidasiWatch._();

  static ValidasiWatchForm<T> form<T>({
    Key? key,
    ValidasiFormController<T>? controller,
    required Widget Function(BuildContext, ValidasiFormController<T>) builder,
  }) =>
      ValidasiWatchForm<T>._(
        key: key,
        controller: controller,
        builder: builder,
      );

  static ValidasiWatchField<T, V> field<T, V>({
    Key? key,
    ValidasiFormController<T>? controller,
    required ValidasiField<T, V> field,
    required Widget Function(BuildContext, V?) builder,
  }) =>
      ValidasiWatchField<T, V>._(
        key: key,
        controller: controller,
        field: field,
        builder: builder,
      );
}
