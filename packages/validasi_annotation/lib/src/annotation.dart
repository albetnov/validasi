import 'package:validasi_annotation/src/base.dart';

class ValidateClass {
  const ValidateClass({this.generateFields, this.generateAssemble});

  final bool? generateFields;
  final bool? generateAssemble;
}

class Validate {
  final List<Rule>? rules;

  const Validate(this.rules);

  const Validate.string(List<Rule<String>> this.rules);

  const Validate.iterable(List<Rule<Iterable>> this.rules);
}

class Refine {
  final Function validator;
  final Set<Symbol> dependsOn;
  const Refine(this.validator, {this.dependsOn = const {}});
}

class RefineAsync {
  final Function validator;
  final Set<Symbol> dependsOn;
  const RefineAsync(this.validator, {this.dependsOn = const {}});
}
