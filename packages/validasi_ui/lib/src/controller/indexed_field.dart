import 'package:validasi/validasi.dart';

class IndexedField<T, V> extends ValidasiField<T, V> {
  final String _name;
  final ValidasiResult<V> Function(V?) _validateFn;
  final Future<ValidasiResult<V>> Function(V?) _validateAsyncFn;
  final V? Function(dynamic item) _extractItemFn;

  IndexedField({
    required String fieldName,
    required String parentPath,
    required int index,
    required ValidasiResult<V> Function(V?) validate,
    Future<ValidasiResult<V>> Function(V?)? validateAsync,
    required V? Function(dynamic item) extractFromItem,
  })  : _name = '$parentPath[$index].$fieldName',
        _validateFn = validate,
        _validateAsyncFn = validateAsync ?? ((v) async => validate(v)),
        _extractItemFn = extractFromItem;

  @override
  String get name => _name;

  @override
  V? extract(T owner) => null;

  V? extractFromItem(dynamic item) => _extractItemFn(item);

  @override
  ValidasiResult<V> validate(V? value) => _validateFn(value);

  @override
  Future<ValidasiResult<V>> validateAsync(V? value) => _validateAsyncFn(value);

  @override
  bool operator ==(Object other) =>
      other is IndexedField<T, V> && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
