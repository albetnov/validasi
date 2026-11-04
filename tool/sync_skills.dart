import 'dart:io';

import 'package:path/path.dart' as p;

/// Mirrors each package's `skills/` directory into the legacy top-level
/// `skills/` tree used by `npx skills`.
///
/// The package directories are the source of truth. Legacy copies keep the
/// original skill names (`validasi`, `validasi-gen`, `validasi-ui`) so existing
/// `npx skills` installs keep working.
///
/// Run `dart run tool/sync_skills.dart` after editing a package skill, or
/// `dart run tool/sync_skills.dart --check` to verify the mirrors are current.
class _SkillMirror {
  const _SkillMirror({
    required this.source,
    required this.target,
    required this.legacyName,
  });

  final String source;
  final String target;
  final String legacyName;
}

const _mirrors = [
  _SkillMirror(
    source: 'packages/validasi/skills/validasi-guide',
    target: 'skills/validasi',
    legacyName: 'validasi',
  ),
  _SkillMirror(
    source: 'packages/validasi_gen/skills/validasi-gen-guide',
    target: 'skills/validasi-gen',
    legacyName: 'validasi-gen',
  ),
  _SkillMirror(
    source: 'packages/validasi_ui/skills/validasi-ui-guide',
    target: 'skills/validasi-ui',
    legacyName: 'validasi-ui',
  ),
];

void main(List<String> args) {
  final check = args.contains('--check');
  final root = Directory.current.path;
  var failed = false;

  for (final mirror in _mirrors) {
    final expected = _readMirror(root, mirror);
    if (check) {
      final actual = _readTree(p.join(root, mirror.target));
      final differences = _diff(expected, actual);
      if (differences.isNotEmpty) {
        failed = true;
        stderr.writeln('Skill mirror out of date: ${mirror.target}');
        for (final difference in differences) {
          stderr.writeln('  $difference');
        }
      }
    } else {
      final target = Directory(p.join(root, mirror.target));
      if (target.existsSync()) target.deleteSync(recursive: true);
      for (final entry in expected.entries) {
        final file = File(p.join(root, mirror.target, entry.key));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value);
      }
      stdout.writeln('Synced ${mirror.target}');
    }
  }

  if (failed) {
    stderr.writeln(
      '\nRun `dart run tool/sync_skills.dart` to regenerate the legacy mirror.',
    );
    exitCode = 1;
  }
}

Map<String, String> _readMirror(String root, _SkillMirror mirror) {
  final source = Directory(p.join(root, mirror.source));
  if (!source.existsSync()) {
    stderr.writeln('Missing package skill directory: ${mirror.source}');
    exitCode = 1;
    return const {};
  }

  final files = <String, String>{};
  for (final entity in source.listSync(recursive: true)) {
    if (entity is! File) continue;
    final relative = p.relative(entity.path, from: source.path);
    var content = entity.readAsStringSync();
    if (relative == 'SKILL.md') {
      content = content.replaceFirst(
        RegExp(r'^name: .*$', multiLine: true),
        'name: ${mirror.legacyName}',
      );
    }
    files[p.joinAll(p.split(relative))] = content;
  }
  return files;
}

Map<String, String> _readTree(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) return const {};

  final files = <String, String>{};
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File) continue;
    final relative = p.relative(entity.path, from: path);
    files[p.joinAll(p.split(relative))] = entity.readAsStringSync();
  }
  return files;
}

List<String> _diff(Map<String, String> expected, Map<String, String> actual) {
  final differences = <String>[];
  for (final entry in expected.entries) {
    if (!actual.containsKey(entry.key)) {
      differences.add('missing ${entry.key}');
    } else if (actual[entry.key] != entry.value) {
      differences.add('different ${entry.key}');
    }
  }
  for (final key in actual.keys) {
    if (!expected.containsKey(key)) differences.add('unexpected $key');
  }
  return differences;
}
