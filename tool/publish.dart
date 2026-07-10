// Cross-platform publish helper for the validasi melos workspace.
//
// Usage:
//   dart run tool/publish.dart [<package>...] [--publish] [--all]
//
// With no package names, shows an interactive checklist of packages whose
// local version is ahead of what's published on pub.dev.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

final String repoRoot = p.dirname(p.dirname(p.fromUri(Platform.script)));

class WorkspacePackage {
  final String name;
  final String dir;
  final Version version;
  final Set<String> localDeps;
  final Set<String> localDevDeps;

  WorkspacePackage({
    required this.name,
    required this.dir,
    required this.version,
    required this.localDeps,
    required this.localDevDeps,
  });
}

Future<Map<String, WorkspacePackage>> loadWorkspace() async {
  final rootPubspecFile = File(p.join(repoRoot, 'pubspec.yaml'));
  final rootDoc = loadYaml(await rootPubspecFile.readAsString()) as YamlMap;
  final members = (rootDoc['workspace'] as YamlList).map((e) => e.toString());

  final allPackages = <String, Map<String, dynamic>>{};
  for (final member in members) {
    final dir = p.join(repoRoot, member);
    final pubspecFile = File(p.join(dir, 'pubspec.yaml'));
    final doc = loadYaml(await pubspecFile.readAsString()) as YamlMap;
    if (doc['publish_to']?.toString() == 'none') continue;

    final deps = (doc['dependencies'] as YamlMap?)?.keys.map((e) => e.toString()).toSet() ?? {};
    final devDeps = (doc['dev_dependencies'] as YamlMap?)?.keys.map((e) => e.toString()).toSet() ?? {};

    allPackages[doc['name'].toString()] = {
      'dir': dir,
      'version': Version.parse(doc['version'].toString()),
      'deps': deps,
      'devDeps': devDeps,
    };
  }

  final names = allPackages.keys.toSet();
  final result = <String, WorkspacePackage>{};
  for (final entry in allPackages.entries) {
    result[entry.key] = WorkspacePackage(
      name: entry.key,
      dir: entry.value['dir'] as String,
      version: entry.value['version'] as Version,
      localDeps: (entry.value['deps'] as Set<String>).intersection(names),
      localDevDeps: (entry.value['devDeps'] as Set<String>).intersection(names),
    );
  }
  return result;
}

/// pub.dev's "latest" field only tracks the latest *stable* release, so a
/// pre-release version (e.g. `1.0.0-rc.4`) that has actually been published
/// would incorrectly look unpublished if we relied on it. Instead, check
/// whether this exact version exists on pub.dev.
Future<bool> versionPublished(String name, Version version) async {
  final response = await http.get(Uri.parse('https://pub.dev/api/packages/$name/versions/$version'));
  if (response.statusCode == 404) return false;
  if (response.statusCode != 200) {
    throw Exception('Failed to query pub.dev for $name $version: HTTP ${response.statusCode}');
  }
  return true;
}

/// Informational only (e.g. for status messages) — the latest stable/pre-release
/// version pub.dev currently reports for this package, or null if never published.
Future<Version?> fetchLatestVersion(String name) async {
  final response = await http.get(Uri.parse('https://pub.dev/api/packages/$name'));
  if (response.statusCode == 404) return null;
  if (response.statusCode != 200) {
    throw Exception('Failed to query pub.dev for $name: HTTP ${response.statusCode}');
  }
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return Version.parse((json['latest'] as Map<String, dynamic>)['version'].toString());
}

/// Returns the version constraint declared for [depName] in [pkg]'s
/// dependencies (non-dev only), or null if not a non-dev dependency.
Future<VersionConstraint?> nonDevConstraintOn(WorkspacePackage pkg, String depName) async {
  final doc = loadYaml(await File(p.join(pkg.dir, 'pubspec.yaml')).readAsString()) as YamlMap;
  final deps = doc['dependencies'] as YamlMap?;
  if (deps == null || !deps.containsKey(depName)) return null;
  final raw = deps[depName];
  if (raw is String) return VersionConstraint.parse(raw);
  return null; // path/sdk/git dependency — nothing to check
}

class ChangelogEntry {
  final String version;
  final String body;
  ChangelogEntry(this.version, this.body);
}

ChangelogEntry? topChangelogEntry(String changelog) {
  final lines = changelog.split('\n');
  final headingIdx = lines.indexWhere((l) => l.startsWith('## '));
  if (headingIdx == -1) return null;
  final version = lines[headingIdx].substring(3).trim();
  final bodyLines = <String>[];
  for (var i = headingIdx + 1; i < lines.length; i++) {
    if (lines[i].startsWith('## ')) break;
    bodyLines.add(lines[i]);
  }
  return ChangelogEntry(version, bodyLines.join('\n').trim());
}

bool isPlaceholderBody(String body) {
  if (body.isEmpty) return true;
  final meaningful = body
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && l != '###')
      .toList();
  if (meaningful.isEmpty) return true;
  final joined = meaningful.join(' ').toLowerCase();
  if (RegExp(r'^\W*(todo|wip)\W*$').hasMatch(joined)) return true;
  return false;
}

class CheckError implements Exception {
  final String message;
  CheckError(this.message);
  @override
  String toString() => message;
}

List<String> topoSort(Set<String> targets, Map<String, WorkspacePackage> all) {
  final visited = <String>{};
  final order = <String>[];

  void visit(String name) {
    if (visited.contains(name)) return;
    visited.add(name);
    final pkg = all[name];
    if (pkg != null) {
      for (final dep in {...pkg.localDeps, ...pkg.localDevDeps}) {
        if (targets.contains(dep)) visit(dep);
      }
    }
    order.add(name);
  }

  for (final t in targets) {
    visit(t);
  }
  return order;
}

Future<int> runProcess(String exe, List<String> args, {required String workingDirectory}) async {
  stdout.writeln('  \$ $exe ${args.join(' ')}');
  final process = await Process.start(exe, args, workingDirectory: workingDirectory, runInShell: true);
  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);
  return process.exitCode;
}

Future<String> currentGitBranch() async {
  final result = await Process.run('git', ['rev-parse', '--abbrev-ref', 'HEAD'], workingDirectory: repoRoot);
  return (result.stdout as String).trim();
}

String tagFor(String name, Version version) {
  if (name == 'validasi') return 'v$version';
  return '$name-v$version';
}

/// Whether a git tag for [pkg]'s current local version already exists.
/// If it doesn't, the local version is ahead of the last tagged release —
/// i.e. a release is pending even if pub.dev is otherwise up to date.
Future<bool> tagExistsFor(WorkspacePackage pkg) async {
  final result = await Process.run('git', ['tag', '-l', tagFor(pkg.name, pkg.version)], workingDirectory: repoRoot);
  return (result.stdout as String).trim().isNotEmpty;
}

/// True if there are commits touching [pkg]'s directory since its last release
/// tag — i.e. source changed but the version/changelog weren't bumped yet.
/// Only meaningful when a tag for the current version actually exists.
Future<bool> hasChangesSinceTag(WorkspacePackage pkg, String tag) async {
  final result = await Process.run(
    'git',
    ['diff', '--quiet', tag, 'HEAD', '--', p.relative(pkg.dir, from: repoRoot)],
    workingDirectory: repoRoot,
  );
  return result.exitCode != 0;
}

/// One-line commit subjects touching [pkg]'s directory since [tag], newest first.
Future<List<String>> commitsSinceTag(WorkspacePackage pkg, String tag) async {
  final result = await Process.run(
    'git',
    ['log', '--oneline', '$tag..HEAD', '--', p.relative(pkg.dir, from: repoRoot)],
    workingDirectory: repoRoot,
  );
  return (result.stdout as String).trim().split('\n').where((l) => l.isNotEmpty).toList();
}

/// Files touching [pkg]'s directory changed since [tag].
Future<List<String>> filesChangedSinceTag(WorkspacePackage pkg, String tag) async {
  final result = await Process.run(
    'git',
    ['diff', '--name-only', tag, 'HEAD', '--', p.relative(pkg.dir, from: repoRoot)],
    workingDirectory: repoRoot,
  );
  return (result.stdout as String).trim().split('\n').where((l) => l.isNotEmpty).toList();
}

Future<void> copyToClipboard(String text) async {
  try {
    if (Platform.isWindows) {
      final process = await Process.start('clip', [], runInShell: true);
      process.stdin.write(text);
      await process.stdin.close();
      await process.exitCode;
    } else if (Platform.isMacOS) {
      final process = await Process.start('pbcopy', []);
      process.stdin.write(text);
      await process.stdin.close();
      await process.exitCode;
    } else {
      for (final cmd in [
        ['wl-copy'],
        ['xclip', '-selection', 'clipboard'],
        ['xsel', '--clipboard', '--input'],
      ]) {
        try {
          final process = await Process.start(cmd.first, cmd.sublist(1));
          process.stdin.write(text);
          await process.stdin.close();
          if (await process.exitCode == 0) return;
        } catch (_) {
          continue;
        }
      }
    }
  } catch (_) {
    // Best-effort only — printing the changelog below is the real fallback.
  }
}

enum Outcome { published, dryRunOk, skippedUpToDate, blocked, failed }

class Result {
  final String package;
  final Outcome outcome;
  final String? reason;
  Result(this.package, this.outcome, [this.reason]);
}

const _ansiReset = '\x1B[0m';
const _ansiGreen = '\x1B[32m';
const _ansiYellow = '\x1B[33m';
const _ansiDim = '\x1B[2m';

void printStatusTable(
  Map<String, WorkspacePackage> workspace,
  Map<String, bool> publishedExact,
  Map<String, bool> tagPending,
  Map<String, bool> changedSinceTag,
  Map<String, ({List<String> commits, List<String> files})> changeDetails,
) {
  final rows = <List<String>>[
    ['Package', 'Local version', 'pub.dev', 'Git tag', 'Notes'],
  ];
  for (final name in workspace.keys.toList()..sort()) {
    final pkg = workspace[name]!;
    final published = publishedExact[name] == true;
    final pending = tagPending[name] == true;
    final dirty = changedSinceTag[name] == true;

    final pubCol = published ? '$_ansiGreen' 'published' '$_ansiReset' : '$_ansiYellow' 'unpublished' '$_ansiReset';
    final pendingTag = tagFor(name, pkg.version);
    final tagCol = pending ? '$_ansiYellow' 'pending' '$_ansiReset' : '$_ansiGreen$pendingTag$_ansiReset';

    final notes = <String>[];
    if (pending) notes.add('release pending (no tag for ${pkg.version} yet)');
    if (dirty) notes.add('changed since last tag — version/changelog bump needed');
    final notesCol = notes.isEmpty ? '$_ansiDim-$_ansiReset' : '$_ansiYellow${notes.join('; ')}$_ansiReset';

    rows.add([name, pkg.version.toString(), pubCol, tagCol, notesCol]);
  }

  // Column widths computed from visible text (ANSI codes stripped) so padding lines up.
  String strip(String s) => s.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
  final widths = List.generate(rows[0].length, (col) => rows.map((r) => strip(r[col]).length).reduce((a, b) => a > b ? a : b));

  String padCell(String cell, int width) => cell + ' ' * (width - strip(cell).length);

  stdout.writeln('\nPackage status:');
  for (var i = 0; i < rows.length; i++) {
    final line = List.generate(rows[i].length, (col) => padCell(rows[i][col], widths[col])).join('  ');
    stdout.writeln(line);
    if (i == 0) stdout.writeln(widths.map((w) => '-' * w).join('  '));
  }

  for (final name in workspace.keys.toList()..sort()) {
    final details = changeDetails[name];
    if (details == null) continue;
    stdout.writeln('\n  ▸ $name — changes since ${tagFor(name, workspace[name]!.version)}:');
    for (final commit in details.commits) {
      stdout.writeln('      $commit');
    }
    stdout.writeln('    $_ansiDim${details.files.length} file(s) changed:$_ansiReset');
    for (final file in details.files) {
      stdout.writeln('      $_ansiDim-$_ansiReset $file');
    }
  }
}

Future<void> main(List<String> args) async {
  final doPublish = args.contains('--publish');
  final all = args.contains('--all');
  final requested = args.where((a) => !a.startsWith('--')).toList();

  final workspace = await loadWorkspace();

  if (doPublish) {
    final branch = await currentGitBranch();
    if (branch != 'v1') {
      stderr.writeln('Error: real publish must be run from the "v1" branch (currently on "$branch").');
      exitCode = 1;
      return;
    }
  }

  stdout.writeln('Checking pub.dev for published versions...');
  final publishedExact = <String, bool>{};
  final latestVersion = <String, Version?>{};
  for (final entry in workspace.entries) {
    publishedExact[entry.key] = await versionPublished(entry.key, entry.value.version);
    latestVersion[entry.key] = await fetchLatestVersion(entry.key);
  }

  bool needsPublishing(String name) => !publishedExact[name]!;

  final tagPending = <String, bool>{};
  final changedSinceTag = <String, bool>{};
  final changeDetails = <String, ({List<String> commits, List<String> files})>{};
  for (final entry in workspace.entries) {
    final tag = tagFor(entry.key, entry.value.version);
    final tagExists = await tagExistsFor(entry.value);
    tagPending[entry.key] = !tagExists;
    final dirty = tagExists && await hasChangesSinceTag(entry.value, tag);
    changedSinceTag[entry.key] = dirty;
    if (dirty) {
      changeDetails[entry.key] = (
        commits: await commitsSinceTag(entry.value, tag),
        files: await filesChangedSinceTag(entry.value, tag),
      );
    }
  }

  printStatusTable(workspace, publishedExact, tagPending, changedSinceTag, changeDetails);

  Set<String> targets;
  if (requested.isNotEmpty) {
    for (final name in requested) {
      if (!workspace.containsKey(name)) {
        stderr.writeln('Error: unknown or non-publishable package "$name".');
        exitCode = 1;
        return;
      }
    }
    targets = requested.toSet();
  } else {
    final readyToPublish = workspace.keys.where(needsPublishing).toList();
    if (readyToPublish.isEmpty) {
      stdout.writeln('All packages are already up to date with pub.dev. Nothing to do.');
      return;
    }
    if (all) {
      targets = readyToPublish.toSet();
    } else {
      targets = await interactivePick(readyToPublish, workspace, latestVersion, tagPending);
      if (targets.isEmpty) {
        stdout.writeln('Nothing selected. Exiting.');
        return;
      }
    }
  }

  final order = topoSort(targets, workspace);
  final results = <Result>[];
  final blockedPackages = <String>{};

  for (final name in order) {
    if (!targets.contains(name) && !workspace.containsKey(name)) continue;
    final pkg = workspace[name]!;
    stdout.writeln('\n=== $name (${pkg.version}) ===');

    if (blockedPackages.contains(name)) {
      results.add(Result(name, Outcome.blocked, 'A local dependency was blocked/failed earlier in this run.'));
      continue;
    }

    if (!targets.contains(name)) {
      // Pulled in only as a dependency ordering step, not requested directly.
      continue;
    }

    if (!needsPublishing(name)) {
      stdout.writeln('Already published on pub.dev at this version. Skipping.');
      results.add(Result(name, Outcome.skippedUpToDate));
      continue;
    }

    try {
      // 1. Non-dev dependency constraint satisfaction.
      for (final dep in pkg.localDeps) {
        final depPkg = workspace[dep];
        if (depPkg == null) continue;
        final constraint = await nonDevConstraintOn(pkg, dep);
        if (constraint != null && !constraint.allows(depPkg.version)) {
          throw CheckError(
            '$name depends on $dep $constraint but local $dep version is ${depPkg.version} — '
            'update the constraint in ${p.join(pkg.dir, 'pubspec.yaml')} before publishing.',
          );
        }
      }

      // 2. Publish-order requirement (dev + non-dev deps).
      for (final dep in {...pkg.localDeps, ...pkg.localDevDeps}) {
        if (!workspace.containsKey(dep)) continue;
        if (needsPublishing(dep) && !(targets.contains(dep) && order.indexOf(dep) < order.indexOf(name))) {
          throw CheckError(
            '$name cannot be published: local dependency $dep (${workspace[dep]!.version}) has not been '
            'published on pub.dev yet. Publish $dep first.',
          );
        }
      }

      // 3. Changelog check.
      final changelogFile = File(p.join(pkg.dir, 'CHANGELOG.md'));
      final entry = topChangelogEntry(await changelogFile.readAsString());
      if (entry == null || entry.version != pkg.version.toString()) {
        throw CheckError(
          'CHANGELOG.md top entry (${entry?.version ?? '<none>'}) does not match pubspec version '
          '(${pkg.version}) in ${p.join(pkg.dir, 'CHANGELOG.md')}.',
        );
      }
      if (isPlaceholderBody(entry.body)) {
        throw CheckError('CHANGELOG.md entry for ${pkg.version} is empty or a placeholder — add real release notes.');
      }

      // 4. Analyze + test.
      stdout.writeln('Running dart pub get...');
      if (await runProcess('dart', ['pub', 'get'], workingDirectory: pkg.dir) != 0) {
        throw CheckError('$name: dart pub get failed.');
      }
      stdout.writeln('Running dart analyze...');
      if (await runProcess('dart', ['analyze', '--fatal-infos'], workingDirectory: pkg.dir) != 0) {
        throw CheckError('$name: dart analyze failed.');
      }
      stdout.writeln('Running tests...');
      final testExe = name == 'validasi_ui' ? 'flutter' : 'dart';
      if (await runProcess(testExe, ['test'], workingDirectory: pkg.dir) != 0) {
        throw CheckError('$name: tests failed.');
      }

      // 5. Publish.
      if (doPublish) {
        stdout.writeln('Publishing $name...');
        final exitCode = await Process.start('dart', ['pub', 'publish'], workingDirectory: pkg.dir, mode: ProcessStartMode.inheritStdio)
            .then((process) => process.exitCode);
        if (exitCode != 0) {
          throw CheckError('$name: dart pub publish failed or was aborted.');
        }

        final tag = tagFor(name, pkg.version);
        await Process.run('git', ['tag', '-a', tag, '-m', '$name ${pkg.version}'], workingDirectory: repoRoot);
        stdout.writeln('Created local git tag: $tag');
        stdout.writeln('Push it with: git push origin $tag');

        await copyToClipboard(entry.body);
        stdout.writeln('\n--- Changelog for $name ${pkg.version} (copied to clipboard if available) ---');
        stdout.writeln(entry.body);
        final releaseUrl = Uri.https('github.com', '/albetnov/validasi/releases/new', {
          'tag': tag,
          'title': '$name ${pkg.version}',
          'body': entry.body,
        });
        stdout.writeln('\nCreate the GitHub release here:\n$releaseUrl');

        results.add(Result(name, Outcome.published));
      } else {
        stdout.writeln('Running dart pub publish --dry-run...');
        if (await runProcess('dart', ['pub', 'publish', '--dry-run'], workingDirectory: pkg.dir) != 0) {
          throw CheckError('$name: dart pub publish --dry-run reported problems.');
        }
        results.add(Result(name, Outcome.dryRunOk));
      }
    } on CheckError catch (e) {
      stderr.writeln('BLOCKED: $e');
      results.add(Result(name, Outcome.blocked, e.message));
      blockedPackages.add(name);
      for (final other in workspace.keys) {
        final o = workspace[other]!;
        if (o.localDeps.contains(name) || o.localDevDeps.contains(name)) {
          blockedPackages.add(other);
        }
      }
    }
  }

  stdout.writeln('\n=== Summary ===');
  for (final r in results) {
    final tagNote = r.outcome != Outcome.published && tagPending[r.package] == true ? ' (release pending: no git tag yet)' : '';
    stdout.writeln('${r.package}: ${r.outcome.name}${r.reason != null ? ' — ${r.reason}' : ''}$tagNote');
  }

  if (results.any((r) => r.outcome == Outcome.blocked || r.outcome == Outcome.failed)) {
    exitCode = 1;
  }
}

Future<Set<String>> interactivePick(
  List<String> readyToPublish,
  Map<String, WorkspacePackage> workspace,
  Map<String, Version?> published,
  Map<String, bool> tagPending,
) async {
  stdout.writeln('\nPackages ready to publish:');
  for (var i = 0; i < readyToPublish.length; i++) {
    final name = readyToPublish[i];
    final pkg = workspace[name]!;
    final tagNote = tagPending[name] == true ? ', no git tag yet' : '';
    stdout.writeln('  ${i + 1}) $name  (local ${pkg.version}, pub.dev ${published[name] ?? 'unpublished'}$tagNote)');
  }
  stdout.writeln('\nEnter numbers to publish (comma-separated), "a" for all, or blank to cancel:');
  stdout.write('> ');
  final input = stdin.readLineSync()?.trim() ?? '';
  if (input.isEmpty || input.toLowerCase() == 'q') return {};
  if (input.toLowerCase() == 'a') return readyToPublish.toSet();

  final selected = <String>{};
  for (final part in input.split(',')) {
    final idx = int.tryParse(part.trim());
    if (idx != null && idx >= 1 && idx <= readyToPublish.length) {
      selected.add(readyToPublish[idx - 1]);
    }
  }
  return selected;
}
