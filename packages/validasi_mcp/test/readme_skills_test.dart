import 'dart:io';

import 'package:test/test.dart';

/// Guards the "AI Agents" section each package README carries.
///
/// The READMEs are the distribution surface for the Agent Skills (pub.dev visitors never
/// see `skills/`), so a renamed or deleted skill — or a docs restructure that moves the
/// links out from under them — has to fail here instead of leaving a silently broken
/// install command in four published READMEs.
void main() {
  late Directory repoRoot;

  setUpAll(() {
    var dir = Directory.current.absolute;
    while (!File('${dir.path}/skills/validasi/SKILL.md').existsSync()) {
      final parent = dir.parent;
      if (parent.path == dir.path) {
        throw StateError(
          'Could not locate the repository root from ${Directory.current.path}',
        );
      }
      dir = parent;
    }
    repoRoot = dir;
  });

  String read(String relativePath) =>
      File('${repoRoot.path}/$relativePath').readAsStringSync();

  /// Matches a `npx skills add ... --skill <skill>` line, anchored at the line end.
  ///
  /// The anchor is load-bearing: a plain `contains` would let a renamed skill satisfy
  /// the assertion as a prefix, so `--skill validasi-ui` would still pass against a
  /// README asking for `--skill validasi-ui-v2`.
  Matcher installsSkill(String skill) => matches(
        RegExp('npx skills add albetnov/validasi --skill $skill\$',
            multiLine: true),
      );

  Matcher installsAllSkills() => matches(
        RegExp('npx skills add albetnov/validasi --all\$', multiLine: true),
      );

  group('package READMEs advertise the Agent Skills', () {
    const readmes = <String, String>{
      'packages/validasi/README.md': 'validasi',
      'packages/validasi_gen/README.md': 'validasi-gen',
      'packages/validasi_ui/README.md': 'validasi-ui',
    };

    readmes.forEach((readme, skill) {
      test('$readme installs the $skill skill', () {
        expect(read(readme), installsSkill(skill));
        expect(
          File('${repoRoot.path}/skills/$skill/SKILL.md').existsSync(),
          isTrue,
          reason:
              'skills/$skill/SKILL.md is missing — update the README reference',
        );
      });

      test('$readme links the skills and MCP docs', () {
        final body = read(readme);
        expect(
          body,
          contains('https://albetnov.github.io/validasi/companion/skills'),
        );
        expect(
          body,
          contains('https://albetnov.github.io/validasi/companion/mcp-server'),
        );
      });
    });

    test('validasi_mcp points agents at the skills', () {
      final body = read('packages/validasi_mcp/README.md');
      expect(body, installsAllSkills());
      expect(
        body,
        contains('https://albetnov.github.io/validasi/companion/skills'),
      );
    });
  });

  group('the skill matcher', () {
    test('accepts a real install line', () {
      expect(
        '# comment\nnpx skills add albetnov/validasi --skill validasi-ui\n',
        installsSkill('validasi-ui'),
      );
    });

    test('rejects a renamed skill sharing the old prefix', () {
      expect(
        'npx skills add albetnov/validasi --skill validasi-ui-v2\n',
        isNot(installsSkill('validasi-ui')),
      );
    });

    test('rejects the wrong skill and a missing command', () {
      expect(
        'npx skills add albetnov/validasi --skill validasi\n',
        isNot(installsSkill('validasi-ui')),
      );
      expect('see the docs for details', isNot(installsSkill('validasi-ui')));
    });

    test('rejects a suffixed --all', () {
      expect(
        'npx skills add albetnov/validasi --all-extra\n',
        isNot(installsAllSkills()),
      );
    });
  });
}
