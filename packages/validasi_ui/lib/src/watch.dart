import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller.dart';
import 'package:validasi_ui/src/form.dart';

class ValidasiWatchForm<T> extends StatelessWidget {
  final Widget Function(BuildContext, ValidasiFormController<T>) _builder;

  const ValidasiWatchForm._(
      {super.key,
      required Widget Function(BuildContext, ValidasiFormController<T>)
          builder})
      : _builder = builder;

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) => _builder(context, controller),
    );
  }
}

class ValidasiWatchField<T, V> extends StatelessWidget {
  final ValidasiField<T, V> field;
  final Widget Function(BuildContext, V?) builder;

  const ValidasiWatchField._(
      {super.key, required this.field, required this.builder});

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
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
    required Widget Function(BuildContext, ValidasiFormController<T>) builder,
  }) =>
      ValidasiWatchForm<T>._(key: key, builder: builder);

  static ValidasiWatchField<T, V> field<T, V>({
    Key? key,
    required ValidasiField<T, V> field,
    required Widget Function(BuildContext, V?) builder,
  }) =>
      ValidasiWatchField<T, V>._(key: key, field: field, builder: builder);
}
