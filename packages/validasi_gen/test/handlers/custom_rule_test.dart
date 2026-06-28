import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/handlers/custom_rule.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

class IsEmail extends CustomRule<String> {
  final String domain;

  const IsEmail(this.domain, {String? message, super.runOnNull})
      : super(name: 'isEmail', message: message);

  static bool check(String? value, {required String domain}) =>
      value != null && value.endsWith(domain);
}

class IsEmpty extends CustomRule<String> {
  const IsEmpty({String? message}) : super(name: 'isEmpty', message: message);

  static bool check(String? value) => value != null && value.isNotEmpty;
}

class RunOnNullRule extends CustomRule<String> {
  const RunOnNullRule()
      : super(name: 'runOnNullRule', runOnNull: true);

  static bool check(String? value) => value != null && value.length > 5;
}

@ValidateClass()
class Model {
  @Validate.string([IsEmail('example.com')])
  final String email;

  const Model({required this.email});
}

@ValidateClass()
class EmptyModel {
  @Validate.string([IsEmpty()])
  final String name2;

  const EmptyModel({required this.name2});
}

@ValidateClass()
class NullModel {
  @Validate.string([RunOnNullRule()])
  final String name3;

  const NullModel({required this.name3});
}
''';

void main() {
  group('CustomRuleGen', () {
    final gen = CustomRuleGen();

    test('name returns CustomRule', () {
      expect(gen.name, equals('CustomRule'));
    });

    test('isAsync is false', () {
      expect(gen.isAsync, isFalse);
    });

    group('check', () {
      test('generates condition with config params (runOnNull false)', () {
        final info = RuleInfo(
          'CustomRule',
          {
            'ruleName': 'isEmail',
            'className': 'IsEmail',
            'runOnNull': false,
            'config': {'domain': "'example.com'"},
            'paramNames': ['domain'],
          },
          null,
        );
        final condition = gen.check(info, 'email');
        expect(
          condition,
          equals(
            "email != null && !IsEmail.check(email, domain: 'example.com')",
          ),
        );
      });

      test('generates condition without config params', () {
        final info = RuleInfo(
          'CustomRule',
          {
            'ruleName': 'isEmpty',
            'className': 'IsEmpty',
            'runOnNull': false,
            'config': {},
            'paramNames': [],
          },
          null,
        );
        final condition = gen.check(info, 'name');
        expect(
          condition,
          equals('name != null && !IsEmpty.check(name)'),
        );
      });

      test('generates condition with runOnNull true', () {
        final info = RuleInfo(
          'CustomRule',
          {
            'ruleName': 'runOnNullRule',
            'className': 'RunOnNullRule',
            'runOnNull': true,
            'config': {},
            'paramNames': [],
          },
          null,
        );
        final condition = gen.check(info, 'name');
        expect(
          condition,
          equals('!RunOnNullRule.check(name)'),
        );
      });

      test('handles multiple config params', () {
        final info = RuleInfo(
          'CustomRule',
          {
            'ruleName': 'range',
            'className': 'RangeRule',
            'runOnNull': false,
            'config': {'min': '18', 'max': '65'},
            'paramNames': ['min', 'max'],
          },
          null,
        );
        final condition = gen.check(info, 'age');
        expect(
          condition,
          equals('age != null && !RangeRule.check(age, min: 18, max: 65)'),
        );
      });
    });

    group('defaultMessage', () {
      test('formats with rule name', () {
        final info = RuleInfo(
          'CustomRule',
          {
            'ruleName': 'isEmail',
            'className': 'IsEmail',
            'runOnNull': false,
            'config': {},
            'paramNames': [],
          },
          null,
        );
        expect(
          gen.defaultMessage(info),
          equals('isEmail: validation failed.'),
        );
      });
    });

    group('emitError', () {
      test('generates inline error call', () {
        final info = RuleInfo(
          'CustomRule',
          {'ruleName': 'test'},
          null,
        );
        final call = gen.emitError(info, "['field']", '');
        expect(
            call,
            equals(
                "_Errors.inline(['field'], 'test', 'test: validation failed.')"));
      });

      test('includes custom message', () {
        final info = RuleInfo(
          'CustomRule',
          {'ruleName': 'test'},
          'Custom msg',
        );
        final call =
            gen.emitError(info, "['field']", ", message: 'Custom msg'");
        expect(call, equals("_Errors.inline(['field'], 'test', 'Custom msg')"));
      });
    });

    group('helperMethods', () {
      test('provides inline helper', () {
        expect(gen.helperMethods.keys, contains('inline'));
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

      test('parses rule with config param', () {
        final cls = library.getClass('Model')!;
        final field = cls.fields.firstWhere((f) => f.name == 'email');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.name, equals('CustomRule'));
        expect(info.params['ruleName'], equals('isEmail'));
        expect(info.params['className'], equals('IsEmail'));
        expect(info.params['runOnNull'], isFalse);
        expect(info.params['config'], containsPair('domain', "'example.com'"));
        expect(info.params['paramNames'], ['domain']);
        expect(info.message, isNull);
        expect(info.isAsync, isFalse);
      });

      test('parses rule without config params', () {
        final cls = library.getClass('EmptyModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'name2');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.params['ruleName'], equals('isEmpty'));
        expect(info.params['className'], equals('IsEmpty'));
        expect(info.params['config'], isEmpty);
        expect(info.params['paramNames'], isEmpty);
      });

      test('parses rule with runOnNull true', () {
        final cls = library.getClass('NullModel')!;
        final field = cls.fields.firstWhere((f) => f.name == 'name3');
        final outerReader = ConstantReader(
            field.metadata.annotations.first.computeConstantValue()!);
        final rulesList = outerReader.read('rules').listValue;
        final ruleReader = ConstantReader(rulesList.first);
        final info = gen.parse(ruleReader);

        expect(info.params['ruleName'], equals('runOnNullRule'));
        expect(info.params['runOnNull'], isTrue);
      });
    });
  });
}
