import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class MinLength extends Rule<String> {
  const MinLength(this.length, {super.message});

  final int length;

  @override
  void apply(ValidationContext context) {
    final value = context.value;
    if (value != null && value.length >= length) {
      return;
    }

    context.addError(
      ValidationError(
        rule: 'MinLength',
        message: message ?? 'Minimum length is $length characters',
        details: {'length': length.toString()},
      ),
    );
  }
}
