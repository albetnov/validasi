import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/handlers/async_custom_rule.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

const _source = r'''
import 'dart:async';

import 'package:validasi_annotation/validasi_annotation.dart';

class UniqueEmail extends AsyncCustomRule<String> {
  const UniqueEmail({String? message, super.runOnNull})
      : super(name: 'uniqueEmail', message: message);

  static Future<bool> check(String? value) async => value != 'taken';
}

class ValidatePassword extends AsyncCustomRule<String> {
  final int minLength;
  final bool requireSpecial;

  const ValidatePassword(this.minLength, this.requireSpecial, {String? message})
      : super(name: 'validatePassword', message: message);

  static Future<bool> check(
    String? value, {
    required int minLength,
    required bool requireSpecial,
  }) async => value != null && value.length >= minLength;
}

@ValidateClass()
class Model {
  @Validate.string([UniqueEmail()])
  final String email;

  const Model({required this.email});
}

@ValidateClass()
class ParamModel {
  @Validate.string([ValidatePassword(8, true)])
  final String password;

  const ParamModel({required this.password});
}
''';

void main() {
  group('AsyncCustomRuleGen', () {
    final gen = AsyncCustomRuleGen();

    test('name returns AsyncCustomRule', () {
      expect(gen.name, equals('AsyncCustomRule'));
    });

    test('isAsync is true', () {
      expect(gen.isAsync, isTrue);
    });

    group('check', () {
      test('returns false placeholder', () {
        final info = RuleInfo(
          'AsyncCustomRule',
          {'ruleName': 'uniqueEmail', 'className': 'UniqueEmail'},
          null,
          isAsync: true,
        );
        expect(gen.check(info, 'email'), equals('false'));
      });
    });

    group('asyncCall', () {
      test('generates call expression without config params', () {
        final info = RuleInfo(
          'AsyncCustomRule',
          {
            'ruleName': 'uniqueEmail',
            'className': 'UniqueEmail',
            'runOnNull': false,
            'config': {},
            'paramNames': [],
          },
          null,
          isAsync: true,
        );
        expect(
          gen.asyncCall(info, 'email'),
          equals('UniqueEmail.check(email)'),
        );
      });

      test('generates call expression with config params', () {
        final info = RuleInfo(
          'AsyncCustomRule',
          {
            'ruleName': 'validatePassword',
            'className': 'ValidatePassword',
            'runOnNull': false,
            'config': {'minLength': '8', 'requireSpecial': 'true'},
            'paramNames': ['minLength', 'requireSpecial'],
          },
          null,
          isAsync: true,
        );
        expect(
          gen.asyncCall(info, 'pw'),
          equals(
            'ValidatePassword.check(pw, minLength: 8, requireSpecial: true)',
          ),
        );
      });
    });

    group('defaultMessage', () {
      test('formats with rule name', () {
        final info = RuleInfo(
          'AsyncCustomRule',
          {
            'ruleName': 'uniqueEmail',
            'className': 'UniqueEmail',
          },
          null,
          isAsync: true,
        );
        expect(
          gen.defaultMessage(info),
          equals('uniqueEmail: validation failed.'),
        );
      });
    });

    group('details', () {
      test('returns null', () {
        final info = RuleInfo(
          'AsyncCustomRule',
          {'ruleName': 'test'},
          null,
          isAsync: true,
        );
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

      test('parses rule without config params', () {
        final cls = library.getClass('Model')!;
        final field = cls.fields.firstWhere((f) => f.name == 'email');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.name, equals('AsyncCustomRule'));
        expect(info.isAsync, isTrue);
        expect(info.params['ruleName'], equals('uniqueEmail'));
        expect(info.params['className'], equals('UniqueEmail'));
        expect(info.params['runOnNull'], isFalse);
        expect(info.params['config'], isEmpty);
        expect(info.params['paramNames'], isEmpty);
        expect(info.message, isNull);
      });

      test('parses rule with config params', () {
        final cls = library.getClass('ParamModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'password');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.params['ruleName'], equals('validatePassword'));
        expect(info.params['className'], equals('ValidatePassword'));
        expect(info.params['config'], {
          'minLength': '8',
          'requireSpecial': 'true',
        });
        expect(info.params['paramNames'],
            ['minLength', 'requireSpecial']);
      });
    });
  });
}
