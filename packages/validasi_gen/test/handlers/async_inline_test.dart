import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/handlers/async_inline.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class AsyncModel {
  @Validate.string([AsyncInline(_check)])
  final String name;

  const AsyncModel({required this.name});
}

@ValidateClass()
class CustomNameModel {
  @Validate.string([AsyncInline(_ok, name: 'custom_rule')])
  final String name2;
  const CustomNameModel({required this.name2});
}

FutureOr<bool> _check(String? value) async => value != null && value.length > 2;
FutureOr<bool> _ok(String? v) async => true;
''';

void main() {
  group('AsyncInlineGen', () {
    final gen = AsyncInlineGen();

    test('name returns AsyncInline', () {
      expect(gen.name, equals('AsyncInline'));
    });

    test('isAsync is true', () {
      expect(gen.isAsync, isTrue);
    });

    test('check returns false placeholder', () {
      final info = RuleInfo('AsyncInline', const {}, null,
          isAsync: true, functionName: '_fn');
      expect(gen.check(info, 'value'), equals('false'));
    });

    test('defaultMessage is "Validation failed"', () {
      final info = RuleInfo('AsyncInline', const {}, null,
          isAsync: true, functionName: '_fn');
      expect(gen.defaultMessage(info), equals('Validation failed'));
    });

    test('details is null', () {
      final info = RuleInfo('AsyncInline', const {}, null,
          isAsync: true, functionName: '_fn');
      expect(gen.details(info), isNull);
    });

    test('asyncCall generates correct call expression', () {
      final info = RuleInfo('AsyncInline', const {}, null,
          isAsync: true, functionName: '_check');
      expect(gen.asyncCall(info, 'value'), equals('_check(value)'));
    });

    test('asyncCall falls back to _unknown', () {
      final info = RuleInfo('AsyncInline', const {}, null, isAsync: true);
      expect(gen.asyncCall(info, 'value'), equals('_unknown(value)'));
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

      test('extracts function name and default custom name', () {
        final cls = library.getClass('AsyncModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'name');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);
        expect(info.name, equals('AsyncInline'));
        expect(info.isAsync, isTrue);
        expect(info.functionName, equals('_check'));
        expect(info.params['customName'], equals('async_inline'));
        expect(info.params['runOnNull'], isTrue);
      });

      test('respects custom rule name', () {
        final cls = library.getClass('CustomNameModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'name2');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);
        expect(info.params['customName'], equals('custom_rule'));
      });
    });
  });
}
