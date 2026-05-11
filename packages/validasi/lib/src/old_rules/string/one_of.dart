import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

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
  void apply(ValidationContext<String> context) {
    if (options.contains(context.requireValue)) {
      return;
    }

    context.addError(
      ValidationError(
        rule: 'OneOf',
        message: message ?? 'Value must be one of: ${options.join(', ')}',
        details: {'options': options.join(', ')},
      ),
    );
  }
}
