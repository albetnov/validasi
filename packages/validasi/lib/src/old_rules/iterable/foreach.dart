import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class ForEach<I> extends Rule<List<I>> {
  const ForEach(this.itemSchema);

  final ValidasiEngine<I, dynamic> itemSchema;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'ForEach',
        parameters: {'itemType': '$I'},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  Map<String, Object?> get metadataChildren =>
      <String, Object?>{'item': itemSchema};

  @override
  void apply(ValidationContext<List<I>> context) {
    final value = context.requireValue;

    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      final result = itemSchema.validate(item);

      if (!result.isValid) {
        for (final error in result.errors) {
          context.addError(error.withPrefix('[$i]'));
        }
      }
    }
  }
}
