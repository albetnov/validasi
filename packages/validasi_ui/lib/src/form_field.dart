import 'package:flutter/widgets.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/controller.dart';
import 'package:validasi_ui/src/field_state.dart';
import 'package:validasi_ui/src/form.dart';

class ValidasiFormField<T, V> extends StatefulWidget {
  final ValidasiField<T, V> field;
  final Widget Function(BuildContext context, ValidasiFieldState<V> state)
      builder;

  const ValidasiFormField({
    required this.field,
    required this.builder,
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

  @override
  Widget build(BuildContext context) {
    final controller = ValidasiForm.of<T>(context);
    final value = controller.getValue<V>(widget.field);
    final errors = controller.getErrors<V>(widget.field);

    final state = ValidasiFieldState<V>(
      value: value,
      errors: errors,
      onChanged: (v) => controller.setValue<V>(widget.field, v),
      validate: () => controller.validateField<V>(widget.field),
    );

    return widget.builder(context, state);
  }
}
