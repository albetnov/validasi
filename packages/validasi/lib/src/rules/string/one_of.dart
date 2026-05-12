import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class OneOf extends Rule<String> {
  const OneOf(this.options, {super.message});

  final List<String> options;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'OneOf',
        parameters: {
          'options': options,
        },
        runOnNull: runOnNull,
        message: message,
      );

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !options.contains(value)) {
      state.errors.add(
        ValidationError(
          rule: 'OneOf',
          message: message ?? 'Value must be one of: ${options.join(', ')}',
          details: {'options': options.join(', ')},
        ),
      );
    }
    return value;
  }
}
