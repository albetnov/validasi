import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/inline.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

bool _isEmail(String? value) => value?.contains('@') ?? false;

bool _isNotEmpty(String? value) => value != null && value.isNotEmpty;

@ValidateClass()
class InlineModel {
  @Validate.string([Inline(_isEmail, name: 'isEmail')])
  final String email;

  const InlineModel({required this.email});
}

@ValidateClass()
class DefaultNameModel {
  @Validate.string([Inline(_isNotEmpty)])
  final String text;

  const DefaultNameModel({required this.text});
}

@ValidateClass()
class RunOnNullModel {
  @Validate.string([Inline(_isEmail, name: 'checkNull', runOnNull: true)])
  final String value;

  const RunOnNullModel({required this.value});
}
''';

void main() {
  group('InlineGen', () {
    final gen = InlineGen();

    test('name returns Inline', () {
      expect(gen.name, equals('Inline'));
    });

    test('isAsync is false', () {
      expect(gen.isAsync, isFalse);
    });

    group('check', () {
      test('generates condition with function name (runOnNull false)', () {
        final info = RuleInfo(
          'Inline',
          {
            'customName': 'isEmail',
            'runOnNull': false,
          },
          null,
          functionName: '_isEmail',
        );
        expect(
          gen.check(info, 'email'),
          equals('email != null && !_isEmail(email)'),
        );
      });

      test('generates condition with runOnNull true', () {
        final info = RuleInfo(
          'Inline',
          {
            'customName': 'isEmail',
            'runOnNull': true,
          },
          null,
          functionName: '_isEmail',
        );
        expect(
          gen.check(info, 'email'),
          equals('!_isEmail(email)'),
        );
      });

      test('uses _unknown fallback when functionName is null', () {
        final info = RuleInfo(
          'Inline',
          {
            'customName': 'custom',
            'runOnNull': false,
          },
          null,
        );
        expect(
          gen.check(info, 'value'),
          equals('value != null && !_unknown(value)'),
        );
      });
    });

    group('defaultMessage', () {
      test('uses customName in message', () {
        final info = RuleInfo(
          'Inline',
          {
            'customName': 'isEmail',
          },
          null,
        );
        expect(
          gen.defaultMessage(info),
          equals('isEmail: validation failed.'),
        );
      });

      test('falls back to inline when customName is missing', () {
        final info = RuleInfo(
          'Inline',
          {},
          null,
        );
        expect(
          gen.defaultMessage(info),
          equals('inline: validation failed.'),
        );
      });
    });

    group('details', () {
      test('returns null', () {
        final info = RuleInfo('Inline', {}, null);
        expect(gen.details(info), isNull);
      });
    });

    group('parse', () {
      late LibraryElement library;

      setUpAll(() async {
        library = await resolveSource(
          _source,
          (resolver) async {
            final asset =
                AssetId('_resolve_source', 'lib/_resolve_source.dart');
            return resolver.libraryFor(asset);
          },
          readAllSourcesFromFilesystem: true,
        );
      });

      test('parses Inline with custom name', () {
        final cls = library.getClass('InlineModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'email');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.name, equals('Inline'));
        expect(info.functionName, equals('_isEmail'));
        expect(info.params['customName'], equals('isEmail'));
        expect(info.params['runOnNull'], isFalse);
        expect(info.message, isNull);
      });

      test('parses Inline with default name', () {
        final cls = library.getClass('DefaultNameModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'text');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.params['customName'], equals('inline'));
        expect(info.functionName, equals('_isNotEmpty'));
      });

      test('parses Inline with runOnNull true', () {
        final cls = library.getClass('RunOnNullModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'value');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.params['runOnNull'], isTrue);
        expect(info.params['customName'], equals('checkNull'));
      });
    });
  });
}
