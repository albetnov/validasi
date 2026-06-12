import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class BasicModel {
  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate.iterable([MinLength(1)])
  final List<String> tags;

  final String nickname;

  const BasicModel({
    required this.email,
    required this.tags,
    required this.nickname,
  });
}

@ValidateClass(generateFields: false)
class NoFieldsModel {
  @Validate.string([MinLength(1)])
  final String code;

  const NoFieldsModel({required this.code});
}

@ValidateClass(generateFields: true)
class ExplicitFieldsModel {
  @Validate.string([MinLength(2)])
  final String name;

  const ExplicitFieldsModel({required this.name});
}
''';

void main() {
  late LibraryElement library;

  setUpAll(() async {
    library = await resolveSource(
      _source,
      (resolver) async {
        final asset = AssetId('_resolve_source', 'lib/_resolve_source.dart');
        return resolver.libraryFor(asset);
      },
      readAllSourcesFromFilesystem: true,
    );
  });

  ClassElement cls(String name) => library.getClass(name)!;

  group('extractValidateFields', () {
    test('extracts only fields with @Validate or nested @ValidateClass', () {
      final fields =
          extractValidateFields(cls('BasicModel'), LibraryReader(library));

      expect(fields, hasLength(2));
      expect(fields.map((f) => f.field.name), containsAll(['email', 'tags']));
    });

    test('parses rules for annotated fields', () {
      final fields =
          extractValidateFields(cls('BasicModel'), LibraryReader(library));
      final emailField = fields.firstWhere((f) => f.field.name == 'email');

      expect(emailField.rules, hasLength(2));
      expect(emailField.rules.map((r) => r.name),
          containsAll(['MinLength', 'MaxLength']));
      expect(emailField.context, equals('string'));
    });

    test('parses iterable context', () {
      final fields =
          extractValidateFields(cls('BasicModel'), LibraryReader(library));
      final tagsField = fields.firstWhere((f) => f.field.name == 'tags');

      expect(tagsField.rules, hasLength(1));
      expect(tagsField.rules.first.name, equals('MinLength'));
      expect(tagsField.context, equals('iterable'));
    });

    test('non-annotated fields are excluded from result', () {
      final fields =
          extractValidateFields(cls('BasicModel'), LibraryReader(library));
      final names = fields.map((f) => f.field.name).toList();
      expect(names, isNot(contains('nickname')));
    });
  });

  group('readGenerateFieldsOverride', () {
    test('returns null when generateFields is not set', () {
      expect(readGenerateFieldsOverride(cls('BasicModel')), isNull);
    });

    test('returns false when generateFields is false', () {
      expect(readGenerateFieldsOverride(cls('NoFieldsModel')), isFalse);
    });

    test('returns true when generateFields is true', () {
      expect(readGenerateFieldsOverride(cls('ExplicitFieldsModel')), isTrue);
    });
  });
}
