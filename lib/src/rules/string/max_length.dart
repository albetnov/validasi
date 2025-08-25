import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class MaxLength extends Rule<String> {
  const MaxLength(
    this.length, {
    super.message,
  });

  final int length;

  @override
  void apply(ValidationContext<String> context) {
    if (context.requireValue.length <= length) {
      return;
    }

    context.addError(
      ValidationError(
        rule: 'MaxLength',
        message: message ?? 'Maximum length is $length characters',
        details: {'length': length.toString()},
      ),
    );
  }
}
