typedef FailCallback = void Function(String message);

abstract class Transformer<T> {
  const Transformer();

  T? transform(dynamic value, FailCallback fail);
}
