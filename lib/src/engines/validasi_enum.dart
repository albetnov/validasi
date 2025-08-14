import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/validasi_result.dart';

class ValidasiEnum extends ValidasiEngine<String> {
  const ValidasiEnum(this.values);

  final List<String> values;

  @override
  ValidasiResult<String> run(String? value) {
    final isValid = values.contains(value);

    return ValidasiResult(
      errors: isValid
          ? []
          : [
              ValidasiError(
                rule: 'Enum',
                message: "$value does not belong to the enum",
              )
            ],
      isValid: isValid,
      data: value,
    );
  }
}
