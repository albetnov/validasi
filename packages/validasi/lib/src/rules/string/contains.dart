import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Contains extends Rule<String> {
  const Contains(this.substring, {super.message});

  final String substring;

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !value.contains(substring)) {
      state.addError(
        ValidationError(
          rule: 'Contains',
          message: message ?? 'Must contain "$substring"',
          details: {'substring': substring},
        ),
      );
    }
    return value;
  }
}
