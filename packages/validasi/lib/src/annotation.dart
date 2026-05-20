import 'package:validasi/src/engine/rule.dart';

class Validate {
  final List<Rule<Object?>>? rules;

  const Validate(this.rules);

  const Validate.string(List<Rule<String>> rules) : this(rules);
}
