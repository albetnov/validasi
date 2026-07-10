import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generator.dart';

const _source = r'''
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class SignUpForm {
  @Validate<String>([MinLength(6)])
  final String password;

  @Validate<String>([MinLength(1)])
  final String confirmPassword;

  const SignUpForm({required this.password, required this.confirmPassword});

  @RefineFn(dependsOn: ['password', 'confirmPassword'])
  static void passwordsMatch(
    FailFn fail, {
    String? password,
    String? confirmPassword,
  }) {
    if (password != null &&
        confirmPassword != null &&
        password != confirmPassword) {
      fail(message: 'Passwords do not match', path: ['confirmPassword']);
    }
  }
}
''';

Future<String> _generate() async {
  final library = await resolveSource(
    _source,
    (resolver) async {
      final asset = AssetId('_resolve_source', 'lib/_resolve_source.dart');
      return resolver.libraryFor(asset);
    },
    readAllSourcesFromFilesystem: true,
  );
  return ValidasiGenerator(generateValidateFormDefault: true)
      .generate(LibraryReader(library), _MockBuildStep());
}

class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('@RefineFn combined with generateValidateForm', () {
    late String output;

    setUpAll(() async {
      output = await _generate();
    });

    test('calls the refine method with a qualified static reference in '
        'validateForm_X', () {
      expect(
        output,
        contains(
          'SignUpForm.passwordsMatch(\$fail_SignUpForm_passwordsMatch, '
          'password: ctrl.getValue(SignUpFormFields.password) as String?, '
          'confirmPassword: ctrl.getValue(SignUpFormFields.confirmPassword) as String?);',
        ),
      );
    });

    test('calls the refine method with a qualified static reference in '
        'validate()/validateAsync()', () {
      expect(
        output,
        contains(
          'SignUpForm.passwordsMatch(\$fail_SignUpForm_passwordsMatch, '
          'password: password, confirmPassword: confirmPassword);',
        ),
      );
    });

    test('never emits a bare, unqualified call to the refine method', () {
      expect(output, isNot(contains(' passwordsMatch(\$fail')));
      expect(output, isNot(contains('  passwordsMatch(\$fail')));
    });
  });
}
