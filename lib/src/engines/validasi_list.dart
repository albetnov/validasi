import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/validasi_result.dart';

class ValidasiList<T> extends ValidasiEngine<List<T>> {
  const ValidasiList(this.elementValidator);

  final ValidasiEngine<T> elementValidator;

  @override
  ValidasiResult<List<T>> validate(dynamic data) {
    final transformedValue = getValue(data);
    if (!transformedValue.isValid) {
      return transformedValue;
    }
    final value = transformedValue.data;

    List<T> validatedList = [];
    List<ValidasiError> errors = [];

    if (value == null || value.isEmpty) {
      return ValidasiResult.success(value);
    }

    for (int i = 0; i < value!.length; i++) {
      final elementResult = elementValidator.validate(value[i]);

      if (!elementResult.isValid) {
        errors.addAll(elementResult.errors.map(
          (e) => ValidasiError(
            rule: e.rule,
            message: e.message,
            details: e.details,
            path: [i, ...e.path], // Prepend the current index to the path
          ),
        ));
      } else if (elementResult.data != null) {
        validatedList.add(elementResult.data!);
      }
    }

    return ValidasiResult<List<T>>(
      errors: errors,
      isValid: errors.isEmpty,
      data: errors.isEmpty ? validatedList : null,
    );
  }
}
