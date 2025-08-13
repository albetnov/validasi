import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/validasi_result.dart';

class ValidasiEnum extends ValidasiEngine<String> {
  const ValidasiEnum(this.values);

  final List<String> values;

  @override
  ValidasiResult<String> validate(dynamic data) {
    // TODO: explore throw error API for more straightforward handling and remove neccessity of this kinds of IF guards.
    // Also consider to have `validate` as part of the Engine that perform preprocess -> validate type -> run rules (perhaps from `run` method override?)
    final transformedValue = getValue(data);
    if (!transformedValue.isValid) {
      return transformedValue;
    }

    final isValid = values.contains(transformedValue.data);

    return ValidasiResult(
      errors: isValid
          ? []
          : [
              ValidasiError(
                rule: 'Enum',
                message: "$data does not belong to the enum",
              )
            ],
      isValid: isValid,
      data: data,
    );
  }
}
