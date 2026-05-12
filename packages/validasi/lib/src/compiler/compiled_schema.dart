import 'package:validasi/src/compiler/compiled_rule.dart';

class CompiledSchema {
  const CompiledSchema({
    required this.rules,
    required this.stringTable,
    required this.nestedRules,
  });

  final List<CompiledRule> rules;
  final List<String> stringTable;
  final List<List<CompiledRule>> nestedRules;
}
