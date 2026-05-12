import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

abstract class Rule<T> {
  const Rule({this.message});

  final String? message;

  final bool runOnNull = false;

  RuleMetadata get metadata => RuleMetadata.dynamic(
        name: runtimeType.toString(),
        runOnNull: runOnNull,
        message: message,
      );

  Map<String, Object?> get metadataChildren => const <String, Object?>{};

  T? apply(T? value, ValidationState state);
}
