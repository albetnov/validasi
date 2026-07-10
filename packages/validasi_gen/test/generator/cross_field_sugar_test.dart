import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Cross-field sugar annotations', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'cross_field_sugar_source.dart',
      );
    });

    test('generates the per-class cross-field helper class', () {
      expect(
          output, contains('abstract final class _SignupFormCrossFieldRules'));
      expect(
          output, contains('abstract final class _IdMigrationCrossFieldRules'));
      expect(
          output, contains('abstract final class _DateRangeCrossFieldRules'));
    });

    test('DependsOn generates the presence-implies-presence check', () {
      expect(
        output,
        contains(
          'static void dependsOn_0(FailFn fail, {Object? password, Object? passwordConfirmation}) {',
        ),
      );
      expect(output, contains('final hasField = password != null;'));
      expect(output,
          contains('final hasDependency = passwordConfirmation != null;'));
      expect(output, contains('if (hasField && !hasDependency) {'));
    });

    test('MatchesField generates the equality check', () {
      expect(
        output,
        contains(
          'static void matchesField_0(FailFn fail, {Object? password, Object? passwordConfirmation}) {',
        ),
      );
      expect(output,
          contains('final isEqual = password == passwordConfirmation;'));
    });

    test('RequiredAny generates the at-least-one check', () {
      expect(
        output,
        contains(
          'static void requiredAny_0(FailFn fail, {Object? email, Object? phone}) {',
        ),
      );
      expect(
          output, contains('final hasAny = email != null || phone != null;'));
    });

    test('RequiredOneOf generates the exactly-one check', () {
      expect(
        output,
        contains(
          'static void requiredOneOf_0(FailFn fail, {Object? legacyId, Object? newId}) {',
        ),
      );
      expect(output, contains('presentCount != 1'));
    });

    test('RequiredAll generates the all-or-nothing check', () {
      expect(
        output,
        contains(
          'static void requiredAll_0(FailFn fail, {Object? start, Object? end}) {',
        ),
      );
      expect(
          output, contains('final anyPresent = start != null || end != null;'));
    });

    test('MutuallyExclusive generates the not-both check', () {
      expect(
        output,
        contains(
          'static void mutuallyExclusive_0(FailFn fail, {Object? legacyId, Object? newId}) {',
        ),
      );
      expect(output, contains('if (hasA && hasB) {'));
    });

    test('calls desugared helpers with rule-specific names in validate()', () {
      expect(
        output,
        contains(
          "rule: 'DependsOn',",
        ),
      );
      expect(
        output,
        contains(
          "rule: 'RequiredAny',",
        ),
      );
      expect(
        output,
        contains(
          'password: password, passwordConfirmation: passwordConfirmation);',
        ),
      );
      expect(
          output, contains('_SignupFormCrossFieldRules.dependsOn_0(\$fail_'));
    });

    test(
        'multiple cross-field rules on one class use distinct \$fail variables',
        () {
      // Regression test: emitRefineInvocation used to always declare a
      // literal `$fail`, so a class with 2+ cross-field rules (like
      // SignupForm, which has RequiredAny/DependsOn/MatchesField) would fail
      // to compile with a duplicate-declaration error.
      final failDeclarations =
          RegExp(r'final \$fail_\w+ =').allMatches(output).length;
      expect(failDeclarations, greaterThanOrEqualTo(3));
    });

    test(
        'generates for a class with only cross-field sugar and no @Validate fields',
        () {
      expect(
          output, contains('abstract final class _ContactOnlyCrossFieldRules'));
      expect(
        output,
        contains(
          'static void requiredAny_0(FailFn fail, {Object? email, Object? phone}) {',
        ),
      );
      expect(
          output, contains('extension \$ContactOnlyValidasi on ContactOnly'));
    });
  });
}
