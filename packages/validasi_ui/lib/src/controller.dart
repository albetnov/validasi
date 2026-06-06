import 'package:flutter/foundation.dart';
import 'package:validasi/validasi.dart';

class ValidasiFormController<T> extends ChangeNotifier {
  final _values = <ValidasiField<T, dynamic>, dynamic>{};
  final _errors = <ValidasiField<T, dynamic>, List<ValidationError>>{};

  void register<V>(ValidasiField<T, V> field, {V? initialValue}) {
    if (_values.containsKey(field)) return;
    _values[field] = initialValue;
    _errors[field] = [];
  }

  V? getValue<V>(ValidasiField<T, V> field) => _values[field] as V?;

  void setValue<V>(ValidasiField<T, V> field, V? value) {
    _values[field] = value;
    _errors[field] = [];
    notifyListeners();
  }

  List<ValidationError> getErrors<V>(ValidasiField<T, V> field) {
    return (_errors[field] ?? []).cast<ValidationError>();
  }

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
    for (final key in _values.keys) {
      _values[key] = null;
      _errors[key] = [];
    }
    notifyListeners();
  }
}
