import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/rule.dart';

class Transform<T> extends Rule<T> {
  const Transform(this.transform, {super.message});

  final T Function(T) transform;

  @override
  void apply(ValidationContext context) {
    context.value = transform(context.value);
  }
}
