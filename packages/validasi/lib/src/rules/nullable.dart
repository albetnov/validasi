import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class Nullable<T> extends Rule<T> {
  const Nullable();

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Nullable',
        runOnNull: runOnNull,
        message: message,
      );

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
