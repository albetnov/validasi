import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Transform<T> extends Rule<T> {
  const Transform(this.transform, {super.message});

  @override
  bool get runOnNull => true;

  final T? Function(T?) transform;

  @override
  T? apply(T? value, ValidationState state) {
    return transform(value);
  }
}
