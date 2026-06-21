import 'package:validasi_annotation/src/base.dart';

class ValidateClass {
  const ValidateClass({
    this.generateFields,
    this.generateAssemble,
    this.generateIndexedFields,
  });

  final bool? generateFields;
  final bool? generateAssemble;
  final bool? generateIndexedFields;
}

class Validate {
  final List<Rule>? rules;

  const Validate(this.rules);

  const Validate.string(List<Rule<String>> this.rules);

  const Validate.iterable(List<Rule<Iterable>> this.rules);
}

class RefineFn {
  final List<String> dependsOn;
  const RefineFn({this.dependsOn = const []});
}

/// Callback passed to a `@RefineFn` method for reporting validation
/// failures. `path` defaults to `[]` (form-level) when omitted.
typedef FailFn = void Function({required String message, List<String> path});
