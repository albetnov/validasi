import 'package:flutter/foundation.dart';
import 'package:validasi/validasi.dart';

class ValidasiFormController<T> extends ChangeNotifier {
  final _values = <ValidasiField<T, dynamic>, dynamic>{};
  final _errors = <ValidasiField<T, dynamic>, List<ValidationError>>{};
  final _crossErrors = <ValidasiField<T, dynamic>, List<ValidationError>>{};
  final _initialValues = <ValidasiField<T, dynamic>, dynamic>{};
  final _touched = <ValidasiField<T, dynamic>>{};
  final T Function(ValidasiFormController<T>) assembler;

  ValidasiFormController({required this.assembler});

  T? _initialModel;
  bool _isSubmitted = false;

  bool get isSubmitted => _isSubmitted;

  void markSubmitted() {
    _isSubmitted = true;
    notifyListeners();
  }

  VoidCallback submit(void Function(T) onSubmit) {
    return () {
      if (!validate()) {
        markSubmitted();
        return;
      }

      onSubmit(assembler(this));
    };
  }

  void setInitialValues(T model) {
    _initialModel = model;
    for (final key in _values.keys) {
      final extracted = key.extract(model);
      _initialValues[key] = extracted;
      _values[key] = extracted;
    }
    notifyListeners();
  }

  void register<V>(ValidasiField<T, V> field, {V? initialValue}) {
    if (_values.containsKey(field)) return;
    if (_initialModel != null) {
      final extracted = field.extract(_initialModel as T);
      _values[field] = extracted;
      _initialValues[field] = extracted;
    } else {
      _values[field] = initialValue;
      _initialValues[field] = initialValue;
    }
    _errors[field] = [];
  }

  V? getValue<V>(ValidasiField<T, V> field) => _values[field] as V?;

  V? _getField<V>(ValidasiField<T, V> field) => _values[field] as V?;

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    _values[field] = value;
    _errors[field] = [];
    _crossErrors.clear();
    _touched.add(field);
    notifyListeners();
  }

  List<ValidationError> getErrors<V>(ValidasiField<T, V> field) {
    return [
      ...(_errors[field] ?? []),
      ...(_crossErrors[field] ?? []),
    ].cast<ValidationError>();
  }

  void _validateDependentCrossFields(ValidasiField<T, dynamic> source) {
    for (final field in _values.keys) {
      final cv = field.crossValidator;
      if (cv != null &&
          (field.crossDependsOn.contains(source) || field == source)) {
        _crossErrors[field] = cv(_getField);
      }
    }
  }

  bool isFieldDirty<V>(ValidasiField<T, V> field) =>
      _values[field] != _initialValues[field];

  bool isFieldTouched<V>(ValidasiField<T, V> field) => _touched.contains(field);

  bool get isDirty => _values.keys.any((k) => _values[k] != _initialValues[k]);

  bool get isPristine => !isDirty;

  bool get isTouched => _touched.isNotEmpty;

  bool validateField<V>(ValidasiField<T, V> field) {
    final value = _values[field];
    final result = field.validate(value);
    _errors[field] = result.errors;
    _validateDependentCrossFields(field);
    notifyListeners();
    return result.isValid && (_crossErrors[field]?.isEmpty ?? true);
  }

  bool validate() {
    var allValid = true;
    for (final key in _values.keys) {
      final value = _values[key];
      final result = key.validate(value);
      _errors[key] = result.errors;
      if (!result.isValid) allValid = false;
    }
    for (final key in _values.keys) {
      final cv = key.crossValidator;
      if (cv != null) {
        final errors = cv(_getField);
        _crossErrors[key] = errors;
        if (errors.isNotEmpty) allValid = false;
      }
    }
    notifyListeners();
    return allValid;
  }

  bool get isValid =>
      _errors.values.every((e) => e.isEmpty) &&
      _crossErrors.values.every((e) => e.isEmpty);

  void reset() {
    _isSubmitted = false;
    _touched.clear();
    _crossErrors.clear();
    for (final key in _values.keys) {
      _values[key] = _initialValues[key];
      _errors[key] = [];
    }
    notifyListeners();
  }
}
