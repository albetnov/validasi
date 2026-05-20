import 'package:validasi/src/engine/rule.dart';

class FieldRules<T> {
  final List<Rule<T>> rules;
  const FieldRules(this.rules);
}
