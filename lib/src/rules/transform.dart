import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/rule.dart';

class Transform<T> extends Rule<T> {
  const Transform(this.transform, {super.message});

  @override
  bool get runOnNull => true;

  final T? Function(T?) transform;

  @override
  void apply(ValidationContext<T> context) {
    context.setValue(transform(context.value));
  }
}
