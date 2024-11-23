import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

class GenericValidator<T> extends Validator<T> {
  GenericValidator({super.transformer});

  @override
  GenericValidator<T> nullable() => super.nullable();

  @override
  GenericValidator<T> custom(CustomCallback<T> callback) =>
      super.custom(callback);

  @override
  GenericValidator<T> customFor(CustomRule<T> customRule) =>
      super.customFor(customRule);
}
