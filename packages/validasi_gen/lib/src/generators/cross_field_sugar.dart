import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/parsers/cross_field_rules.dart';
import 'package:validasi_gen/src/parsers/rules.dart';
import 'package:validasi_gen/src/utils.dart';

class DesugaredCrossFieldRule {
  final RefineMethodInfo refine;
  final String helperMethodSource;

  const DesugaredCrossFieldRule(this.refine, this.helperMethodSource);
}

const _twoDistinctFieldKinds = {
  'DependsOn',
  'MutuallyExclusive',
  'MatchesField',
};
const _multiFieldKinds = {'RequiredAny', 'RequiredOneOf', 'RequiredAll'};

List<DesugaredCrossFieldRule> desugarCrossFieldRules(
  String className,
  ClassElement cls,
  List<CrossFieldRuleInfo> infos,
) {
  final helperClassName = '_${className}CrossFieldRules';
  final counters = <String, int>{};
  final results = <DesugaredCrossFieldRule>[];
  final fieldNames =
      cls.fields.where((f) => !f.isStatic).map((f) => f.name!).toSet();

  for (final info in infos) {
    _validateFields(className, info, fieldNames);

    final idx = counters.update(info.kind, (v) => v + 1, ifAbsent: () => 0);
    final methodName = '${_camel(info.kind)}_$idx';
    final qualifiedName = '$helperClassName.$methodName';

    final parameters = info.fields
        .map((f) => RefineParamInfo(
              name: f,
              type: cls.fields.firstWhere((fe) => fe.name == f).type,
            ))
        .toList();

    results.add(DesugaredCrossFieldRule(
      RefineMethodInfo(
        methodName: qualifiedName,
        dependsOn: info.fields,
        parameters: parameters,
        isAsync: false,
        ruleName: info.kind,
      ),
      _generateHelperBody(methodName, info),
    ));
  }

  return results;
}

void _validateFields(
    String className, CrossFieldRuleInfo info, Set<String> fieldNames) {
  for (final f in info.fields) {
    if (!fieldNames.contains(f)) {
      throw InvalidGenerationSourceError(
        '${info.kind} on $className references unknown field "$f".',
      );
    }
  }
  if (_twoDistinctFieldKinds.contains(info.kind) &&
      info.fields[0] == info.fields[1]) {
    throw InvalidGenerationSourceError(
      '${info.kind} on $className must reference two distinct fields, '
      'got "${info.fields[0]}" twice.',
    );
  }
  if (_multiFieldKinds.contains(info.kind) && info.fields.length < 2) {
    throw InvalidGenerationSourceError(
      '${info.kind} on $className requires at least 2 fields, '
      'got ${info.fields.length}.',
    );
  }
}

String _camel(String kind) => kind[0].toLowerCase() + kind.substring(1);

String _generateHelperBody(String methodName, CrossFieldRuleInfo info) {
  final params = info.fields.map((f) => 'Object? $f').join(', ');
  final buf = StringBuffer();
  buf.writeln('  static void $methodName(FailFn fail, {$params}) {');
  buf.write(_bodyFor(info));
  buf.writeln('  }');
  return buf.toString();
}

String _bodyFor(CrossFieldRuleInfo info) {
  final buf = StringBuffer();
  final messageArg =
      info.message != null ? escapeDartString(info.message!) : null;

  switch (info.kind) {
    case 'RequiredAny':
      final checks = info.fields.map((f) => '$f != null').join(' || ');
      buf.writeln('    final hasAny = $checks;');
      buf.writeln('    if (!hasAny) {');
      buf.writeln('      fail(message: ${messageArg ?? escapeDartString(
            'At least one of ${info.fields.join(', ')} is required',
          )});');
      buf.writeln('    }');
    case 'RequiredOneOf':
      buf.writeln('    var presentCount = 0;');
      for (final f in info.fields) {
        buf.writeln('    if ($f != null) presentCount++;');
      }
      buf.writeln('    if (presentCount != 1) {');
      buf.writeln('      fail(message: ${messageArg ?? escapeDartString(
            'Exactly one of the following fields must be present: ${info.fields.join(', ')}',
          )});');
      buf.writeln('    }');
    case 'RequiredAll':
      final anyChecks = info.fields.map((f) => '$f != null').join(' || ');
      final missingChecks = info.fields.map((f) => '$f == null').join(' || ');
      buf.writeln('    final anyPresent = $anyChecks;');
      buf.writeln('    if (anyPresent) {');
      buf.writeln('      final missingAny = $missingChecks;');
      buf.writeln('      if (missingAny) {');
      buf.writeln('        fail(message: ${messageArg ?? escapeDartString(
            'All fields must be present: ${info.fields.join(', ')}',
          )});');
      buf.writeln('      }');
      buf.writeln('    }');
    case 'DependsOn':
      final field = info.fields[0];
      final dependsOn = info.fields[1];
      buf.writeln('    final hasField = $field != null;');
      buf.writeln('    final hasDependency = $dependsOn != null;');
      buf.writeln('    if (hasField && !hasDependency) {');
      buf.writeln('      fail(message: ${messageArg ?? escapeDartString(
            'Field $field requires $dependsOn',
          )});');
      buf.writeln('    }');
    case 'MutuallyExclusive':
      final a = info.fields[0];
      final b = info.fields[1];
      buf.writeln('    final hasA = $a != null;');
      buf.writeln('    final hasB = $b != null;');
      buf.writeln('    if (hasA && hasB) {');
      buf.writeln('      fail(message: ${messageArg ?? escapeDartString(
            'Fields $a and $b cannot both be present',
          )});');
      buf.writeln('    }');
    case 'MatchesField':
      final field = info.fields[0];
      final matches = info.fields[1];
      buf.writeln('    final hasField = $field != null;');
      buf.writeln('    final hasMatches = $matches != null;');
      buf.writeln('    if (hasField && hasMatches) {');
      buf.writeln('      final isEqual = $field == $matches;');
      buf.writeln('      if (!isEqual) {');
      buf.writeln('        fail(message: ${messageArg ?? escapeDartString(
            'Field $field must match $matches',
          )});');
      buf.writeln('      }');
      buf.writeln('    }');
  }
  return buf.toString();
}

String generateCrossFieldHelperClass(
  String className,
  List<DesugaredCrossFieldRule> desugared,
) {
  if (desugared.isEmpty) return '';
  final helperClassName = '_${className}CrossFieldRules';
  final buf = StringBuffer();
  buf.writeln();
  buf.writeln('abstract final class $helperClassName {');
  for (final d in desugared) {
    buf.writeln(d.helperMethodSource);
  }
  buf.writeln('}');
  return buf.toString();
}
