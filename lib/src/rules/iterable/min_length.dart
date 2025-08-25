import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class MinLength<T> extends Rule<List<T>> {
  const MinLength(this.length, {super.message});

  final int length;

  @override
  void apply(ValidationContext<List<T>> context) {
    if (context.requireValue.length < length) {
      context.addError(ValidationError(
        rule: 'MinLength',
        message: message ?? 'List must have at least $length items',
      ));
    }
  }
}
