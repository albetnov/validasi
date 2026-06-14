import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class AsyncTransform<T> extends AsyncRule<T> {
  const AsyncTransform(this.transform, {super.message});

  @override
  bool get runOnNull => true;

  final Future<T?> Function(T?) transform;

  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    return await transform(value);
  }
}
