import 'package:validasi_annotation/src/base.dart';

class ValidateClass {
  const ValidateClass({this.generateFields});

  final bool? generateFields;
}

class Validate {
  final List<Rule>? rules;

  const Validate(this.rules);

  const Validate.string(List<Rule<String>> this.rules);

  const Validate.iterable(List<Rule<Iterable>> this.rules);
}

class ValidateWith {
  final Function validator;
  final Set<Symbol> dependsOn;
  const ValidateWith(this.validator, {this.dependsOn = const {}});
}
