import 'package:signals/signals.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/src/signals/field_signals.dart';

mixin WatchMixin<T> {
  ValidasiFieldSignals<V> getFieldController<V>(ValidasiField<T, V> field);
  V? getValue<V>(ValidasiField<T, V> field);

  ReadonlySignal<V?> watchValue<V>(ValidasiField<T, V> field) =>
      getFieldController<V>(field).valueSignal;

  ReadonlySignal<R> watch<V, R>(
    List<ValidasiField<T, V>> fields,
    R Function(Map<ValidasiField<T, V>, V> values) selector,
  ) {
    return computed<R>(() {
      final values = <ValidasiField<T, V>, V>{};
      for (final f in fields) {
        final v = getValue<V>(f);
        if (v != null) values[f] = v;
      }
      return selector(values);
    });
  }
}
