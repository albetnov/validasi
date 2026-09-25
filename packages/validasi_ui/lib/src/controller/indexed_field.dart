import 'package:validasi/validasi.dart';

typedef IndexedFieldRegistrar<T> = void Function<V>(
  ValidasiField<T, V> field, {
  V? initialValue,
});

/// A value-type-erased indexed field that preserves its concrete value type
/// when it registers itself with a controller.
abstract interface class IndexedFieldDescriptor<T> {
  String get name;

  Object? extractFromItem(dynamic item);

  ValidasiField<T, dynamic> register(
    IndexedFieldRegistrar<T> registrar,
    Object? initialValue,
  );
}

class IndexedField<T, V> extends ValidasiField<T, V>
    implements IndexedFieldDescriptor<T> {
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

  @override
  V? extractFromItem(dynamic item) => _extractItemFn(item);

  @override
  ValidasiField<T, dynamic> register(
    IndexedFieldRegistrar<T> registrar,
    Object? initialValue,
  ) {
    registrar(this, initialValue: initialValue as V);
    return this;
  }

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
