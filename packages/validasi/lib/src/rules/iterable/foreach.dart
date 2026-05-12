import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

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
  List<I>? apply(List<I>? value, ValidationState state) {
    if (value == null) return null;

    for (var i = 0; i < value.length; i++) {
      final before = state.errors.length;
      value[i] = itemSchema.execute(value[i], state) as I;
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix('[$i]');
      }
    }
    return value;
  }
}
