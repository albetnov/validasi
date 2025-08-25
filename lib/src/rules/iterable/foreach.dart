import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';

class ForEach<I> extends Rule<List<I>> {
  const ForEach(this.itemSchema);

  final ValidasiEngine<I> itemSchema;

  @override
  void apply(ValidationContext<List<I>> context) {
    for (var i = 0; i < context.requireValue.length; i++) {
      final item = context.value![i];
      final result = itemSchema.validate(item);

      if (!result.isValid) {
        for (final error in result.errors) {
          context.addError(error.withPrefix('[$i]'));
        }
      }
    }
  }
}
