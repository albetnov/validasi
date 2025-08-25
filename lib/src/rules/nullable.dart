import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/rule.dart';

class Nullable<T> extends Rule<T> {
  const Nullable();

  @override
  bool get runOnNull => true;

  @override
  void apply(ValidationContext context) {
    final value = context.value;

    if (value == null) {
      context.stop();
    }
  }
}
