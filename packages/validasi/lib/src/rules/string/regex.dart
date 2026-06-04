import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Regex extends Rule<String> {
  const Regex(this.pattern, {super.message});

  final String pattern;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !RegExp(pattern).hasMatch(value)) {
      state.addError(
        ValidationError(
          rule: 'Regex',
          message: message ?? 'Must match pattern "$pattern"',
          details: {'pattern': pattern},
        ),
      );
    }
    return value;
  }
}
