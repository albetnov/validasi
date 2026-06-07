import 'package:flutter/foundation.dart';
import 'package:validasi/validasi.dart';

class ValidasiFormController<T> extends ChangeNotifier {
  final _values = <ValidasiField<T, dynamic>, dynamic>{};
  final _errors = <ValidasiField<T, dynamic>, List<ValidationError>>{};
  final _initialValues = <ValidasiField<T, dynamic>, dynamic>{};
  final _touched = <ValidasiField<T, dynamic>>{};

  T? _initialModel;
  bool _isSubmitted = false;

  bool get isSubmitted => _isSubmitted;

  void markSubmitted() {
    _isSubmitted = true;
    notifyListeners();
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

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    _values[field] = value;
    _errors[field] = [];
    _touched.add(field);
    notifyListeners();
  }

  List<ValidationError> getErrors<V>(ValidasiField<T, V> field) {
    return (_errors[field] ?? []).cast<ValidationError>();
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
    notifyListeners();
    return result.isValid;
  }

  bool validate() {
    var allValid = true;
    for (final key in _values.keys) {
      final value = _values[key];
      final result = key.validate(value);
      _errors[key] = result.errors;
      if (!result.isValid) allValid = false;
    }
    notifyListeners();
    return allValid;
  }

  bool get isValid => _errors.values.every((e) => e.isEmpty);

  void reset() {
    _isSubmitted = false;
    _touched.clear();
    for (final key in _values.keys) {
      _values[key] = _initialValues[key];
      _errors[key] = [];
    }
    notifyListeners();
  }
}
