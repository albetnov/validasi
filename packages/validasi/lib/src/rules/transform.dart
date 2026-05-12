import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class Transform<T> extends Rule<T> {
  const Transform(this.transform, {super.message});

  @override
  bool get runOnNull => true;

  final T? Function(T?) transform;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Transform',
        runOnNull: runOnNull,
        message: message,
        isDynamic: true,
        dynamicReason: 'Transform callback logic cannot be introspected.',
      );

  @override
  T? apply(T? value, ValidationState state) {
    return transform(value);
  }
}
