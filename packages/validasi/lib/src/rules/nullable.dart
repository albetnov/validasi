import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Nullable<T> extends Rule<T> {
  const Nullable();

  @override
  bool get runOnNull => true;

  @override
  T? apply(T? value, ValidationState state) {
    if (value == null) {
      state.isStopped = true;
    }
    return value;
  }
}
