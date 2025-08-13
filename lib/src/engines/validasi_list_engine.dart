import 'package:validasi/src/engines/validasi_engine.dart';
import 'package:validasi/src/validasi_result.dart';

class ValidasiListEngine<T> extends ValidasiEngine<List<T>> {
  const ValidasiListEngine(this.elementValidator);

  final ValidasiEngine<T> elementValidator;

  @override
  ValidasiResult<List<T>> validate(dynamic value) {
    if (value is! List) {
      return ValidasiResult.error(
        error: ValidasiError(
          rule: 'TypeCheck',
          message: 'Expected a List, got ${value.runtimeType}',
          path: [], // Root path
        ),
      );
    }

    List<T> validatedList = [];
    List<ValidasiError> errors = [];

    for (int i = 0; i < value.length; i++) {
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
