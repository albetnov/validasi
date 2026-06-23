import 'package:validasi_gen/src/parsers/rules.dart';

/// Returns Dart source that:
///   1. Defines a local `$fail` closure that appends a `ValidationError`
///      (with `rule: 'Refine'`) to the surrounding `$errors` list.
///   2. Calls the refine method, passing `$fail` plus named field values.
///
/// [fieldAccessors] maps each `dependsOn` field name to the Dart
/// expression that produces its current value — typically:
///   - object-level: `this.field`  →  the field name itself
///   - form-level:   `ctrl.getValue(XFields.field) as F?`
///
/// The `as` cast to the field's declared type is added in form mode where
/// `ctrl.getValue` returns `dynamic`.
String emitRefineInvocation({
  required RefineMethodInfo info,
  required Map<String, String> fieldAccessors,
  required bool isFormContext,
  required bool isAsync,
  String indent = '    ',
}) {
  final accessors = _resolveAccessors(info, fieldAccessors, isFormContext);
  final call = _buildCall(info, accessors, isFormContext);
  final buf = StringBuffer();
  buf.writeln('$indent final \$fail = '
      '({required String message, List<String> path = const []}) {');
  buf.writeln('$indent   \$errors.add(ValidationError(');
  buf.writeln("$indent     rule: 'Refine',");
  buf.writeln('$indent     message: message,');
  buf.writeln('$indent     path: path.isEmpty ? null : path,');
  buf.writeln('$indent   ));');
  buf.writeln('$indent };');
  buf.writeln('$indent${isAsync ? 'await ' : ''}$call');
  return buf.toString();
}

Map<String, String> _resolveAccessors(
  RefineMethodInfo info,
  Map<String, String> fieldAccessors,
  bool isFormContext,
) {
  final result = <String, String>{};
  if (info.dependsOn.isEmpty) {
    result.addAll(fieldAccessors);
  } else {
    for (final name in info.dependsOn) {
      final acc = fieldAccessors[name];
      if (acc == null) {
        throw StateError(
          'Refine method `${info.methodName}` depends on "$name" '
          'which is not a field of the model.',
        );
      }
      result[name] = acc;
    }
  }
  return result;
}

String _buildCall(
  RefineMethodInfo info,
  Map<String, String> accessors,
  bool isFormContext,
) {
  final namedArgs =
      info.parameters.where((p) => accessors.containsKey(p.name)).map((p) {
    final acc = accessors[p.name]!;
    return '${p.name}: $acc';
  }).join(', ');

  if (namedArgs.isEmpty) {
    return '${info.methodName}(\$fail);';
  }
  return '${info.methodName}(\$fail, $namedArgs);';
}
