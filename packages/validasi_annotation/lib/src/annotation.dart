import 'package:validasi_annotation/src/base.dart';

class ValidateClass {
  const ValidateClass();
}

class Validate {
  final List<Rule>? rules;

  const Validate(this.rules);

  const Validate.string(List<Rule<String>> this.rules);

  const Validate.iterable(List<Rule<Iterable>> this.rules);
}
