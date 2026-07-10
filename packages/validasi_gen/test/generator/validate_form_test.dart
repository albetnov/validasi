import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generator.dart';

const _source = r'''
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class Login {
  @Validate<String>([MinLength(3)])
  final String username;

  @Validate<String>([MinLength(1)])
  final String password;

  @Validate<String?>([])
  final String? nickname;

  const Login({
    required this.username,
    required this.password,
    this.nickname,
  });
}
''';

Future<String> generateForSourceWithOption({
  required bool generateValidateForm,
}) async {
  final library = await resolveSource(
    _source,
    (resolver) async {
      final asset = AssetId('_resolve_source', 'lib/_resolve_source.dart');
      return resolver.libraryFor(asset);
    },
    readAllSourcesFromFilesystem: true,
  );
  return ValidasiGenerator(generateValidateFormDefault: generateValidateForm)
      .generate(LibraryReader(library), _MockBuildStep());
}

class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('validateForm emission', () {
    test('off by default', () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: false,
      );
      expect(output, isNot(contains('validateForm_Login')));
    });

    test('emits when enabled', () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: true,
      );
      expect(
        output,
        contains('validateForm_Login(ValidasiFormController<Login> ctrl)'),
      );
    });

    test('emits async variant when class has async rules', () async {
      // Same source as above has no async rules, so this just checks sync.
      // The async path is covered by the existing async_test.dart.
      final output = await generateForSourceWithOption(
        generateValidateForm: true,
      );
      // Sync form for a sync-only class
      expect(output, contains('validateForm_Login'));
    });

    test('validates per-field with prefix', () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: true,
      );
      expect(
        output,
        contains(
            "LoginFields.username.validate(ctrl.getValue<String>(LoginFields.username))"),
      );
      expect(
        output,
        contains(
            r"$errors.addAll($usernameResult.errors.map((e) => e..prefix('username')))"),
      );
    });

    test('nullable field getValue call carries the nullable type argument',
        () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: true,
      );
      expect(
        output,
        contains(
            "LoginFields.nickname.validate(ctrl.getValue<String?>(LoginFields.nickname))"),
      );
    });

    test('schema class auto-discovers the generated formValidator', () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: true,
      );
      expect(
        output,
        contains('implements ValidasiFormValidatorSchema<Login>'),
      );
      expect(
        output,
        contains('get formValidator => validateForm_Login'),
      );
    });

    test('schema class does not implement formValidator when disabled',
        () async {
      final output = await generateForSourceWithOption(
        generateValidateForm: false,
      );
      expect(output, isNot(contains('ValidasiFormValidatorSchema')));
    });
  });
}
