import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class StartsWith extends Rule<String> {
  const StartsWith(this.prefix, {super.message});

  final String prefix;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !value.startsWith(prefix)) {
      state.addError(
        ValidationError(
          rule: 'StartsWith',
          message: message ?? 'Must start with "$prefix"',
          details: {'prefix': prefix},
        ),
      );
    }
    return value;
  }
}
