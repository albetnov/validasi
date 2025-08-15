import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class MinLength<T> extends Rule<List<T>> {
  const MinLength(this.length);

  final int length;

  @override
  void apply(ValidationContext context) {
    if (context.value.length < length) {
      context.errors.add(ValidationError(
        rule: 'MinLength',
        message: 'List must have at least $length items',
      ));
    }
  }
}
