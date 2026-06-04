import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class EndsWith extends Rule<String> {
  const EndsWith(this.suffix, {super.message});

  final String suffix;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !value.endsWith(suffix)) {
      state.addError(
        ValidationError(
          rule: 'EndsWith',
          message: message ?? 'Must end with "$suffix"',
          details: {'suffix': suffix},
        ),
      );
    }
    return value;
  }
}
