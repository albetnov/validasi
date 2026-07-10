import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/alpha.dart';
import 'package:validasi_gen/src/handlers/alphanumeric.dart';
import 'package:validasi_gen/src/handlers/numeric.dart';
import 'package:validasi_gen/src/handlers/case_rules.dart';
import 'package:validasi_gen/src/handlers/starts_with.dart';
import 'package:validasi_gen/src/handlers/ends_with.dart';
import 'package:validasi_gen/src/handlers/regex.dart';
import 'package:validasi_gen/src/handlers/ulid.dart';
import 'package:validasi_gen/src/handlers/uuid.dart';
import 'package:validasi_gen/src/handlers/url.dart';
import 'package:validasi_gen/src/handlers/ip.dart';
import 'package:validasi_gen/src/handlers/email.dart';
import 'package:validasi_gen/src/handlers/contains.dart';

void main() {
  group('AlphaGen', () {
    final gen = AlphaGen();
    test('name and supportedContexts', () {
      expect(gen.name, 'Alpha');
      expect(gen.supportedContexts, {FieldContext.string});
    });
    test('check guards on null and matches pattern', () {
      final info = RuleInfo('Alpha', const {}, null);
      expect(gen.check(info, 'v'),
          r"v != null && !RegExp('^[a-zA-Z]+\$').hasMatch(v!)");
    });
    test('helperMethods provides alpha', () {
      expect(gen.helperMethods.keys, contains('alpha'));
    });
  });

  group('AlphanumericGen', () {
    final gen = AlphanumericGen();
    test('check', () {
      final info = RuleInfo('Alphanumeric', const {}, null);
      expect(gen.check(info, 'v'),
          r"v != null && !RegExp('^[a-zA-Z0-9]+\$').hasMatch(v!)");
    });
  });

  group('NumericGen', () {
    final gen = NumericGen();
    test('check', () {
      final info = RuleInfo('Numeric', const {}, null);
      expect(gen.check(info, 'v'),
          r"v != null && !RegExp('^[0-9]+\$').hasMatch(v!)");
    });
  });

  group('LowercaseGen / UppercaseGen', () {
    test('Lowercase check', () {
      final info = RuleInfo('Lowercase', const {}, null);
      expect(LowercaseGen().check(info, 'v'),
          'v != null && v! != v!.toLowerCase()');
    });
    test('Uppercase check', () {
      final info = RuleInfo('Uppercase', const {}, null);
      expect(UppercaseGen().check(info, 'v'),
          'v != null && v! != v!.toUpperCase()');
    });
  });

  group('StartsWithGen / EndsWithGen', () {
    test('StartsWith check and emitError', () {
      final gen = StartsWithGen();
      final info = RuleInfo('StartsWith', {'prefix': 'foo'}, null);
      expect(gen.check(info, 'v'), "v != null && !v!.startsWith('foo')");
      expect(
          gen.emitError(info, "['f']", ''), "_Errors.startsWith(['f'], 'foo')");
    });
    test('EndsWith check and emitError', () {
      final gen = EndsWithGen();
      final info = RuleInfo('EndsWith', {'suffix': 'bar'}, null);
      expect(gen.check(info, 'v'), "v != null && !v!.endsWith('bar')");
      expect(
          gen.emitError(info, "['f']", ''), "_Errors.endsWith(['f'], 'bar')");
    });
  });

  group('RegexGen', () {
    test('check embeds user pattern', () {
      final gen = RegexGen();
      final info = RuleInfo('Regex', {'pattern': r'^[a-z]+$'}, null);
      final result = gen.check(info, 'v');
      expect(result, contains('RegExp('));
      expect(result, contains('.hasMatch(v!)'));
    });
  });

  group('UlidGen', () {
    test('check uses caseSensitive: false', () {
      final gen = UlidGen();
      final info = RuleInfo('Ulid', const {}, null);
      expect(gen.check(info, 'v'), contains('caseSensitive: false'));
    });
  });

  group('UuidGen', () {
    test('check validates pattern and extracted version', () {
      final gen = UuidGen();
      final info = RuleInfo(
          'Uuid',
          {
            'versions': [4, 7]
          },
          null);
      final result = gen.check(info, 'v');
      expect(result, contains('firstMatch(v!)!.group(1)!'));
      expect(result, contains('[4, 7].contains('));
    });
  });

  group('UrlGen', () {
    test('check validates scheme and host by default', () {
      final gen = UrlGen();
      final info = RuleInfo(
          'Url',
          {'requireScheme': true, 'requireHost': true, 'httpsOnly': false},
          null);
      final result = gen.check(info, 'v');
      expect(result, contains('Uri.tryParse(v)'));
      expect(result, contains('uri.scheme.isEmpty'));
      expect(result, contains('uri.host.isEmpty'));
      expect(result, isNot(contains("!= 'https'")));
    });
    test('check enforces httpsOnly when set', () {
      final gen = UrlGen();
      final info = RuleInfo(
          'Url',
          {'requireScheme': true, 'requireHost': true, 'httpsOnly': true},
          null);
      expect(gen.check(info, 'v'), contains("!= 'https'"));
    });
  });

  group('Ipv4Gen / Ipv6Gen / IpGen', () {
    test('Ipv4 check', () {
      final info = RuleInfo('Ipv4', const {}, null);
      expect(Ipv4Gen().check(info, 'v'), contains('RegExp('));
    });
    test('Ipv6 check', () {
      final info = RuleInfo('Ipv6', const {}, null);
      expect(Ipv6Gen().check(info, 'v'), contains('RegExp('));
    });
    test('Ip check requires both to fail', () {
      final info = RuleInfo('Ip', const {}, null);
      final result = IpGen().check(info, 'v');
      expect(result, contains('&&'));
    });
  });

  group('EmailGen', () {
    test('check builds an IIFE validating local/domain parts', () {
      final gen = EmailGen();
      final info = RuleInfo(
          'Email',
          {
            'allowTopLevelDomain': false,
            'allowInternational': false,
            'domains': null,
          },
          null);
      final result = gen.check(info, 'v');
      expect(result, contains("lastIndexOf('@')"));
      expect(result, contains('local.length > 64'));
      expect(result, contains('domain.length > 255'));
    });
    test('check adds domain allow-list when provided', () {
      final gen = EmailGen();
      final info = RuleInfo(
          'Email',
          {
            'allowTopLevelDomain': false,
            'allowInternational': false,
            'domains': ['example.com'],
          },
          null);
      expect(gen.check(info, 'v'), contains("'example.com'"));
    });
  });

  group('ContainsGen', () {
    test('supports string and iterable contexts', () {
      expect(ContainsGen().supportedContexts,
          {FieldContext.string, FieldContext.iterable});
    });
    test('emitError dispatches by context', () {
      final gen = ContainsGen();
      final info = RuleInfo('Contains', {'value': "'needle'"}, null);
      expect(gen.emitError(info, "['f']", '', FieldContext.string),
          "_Errors.contains(['f'], 'needle')");
      expect(gen.emitError(info, "['f']", '', FieldContext.iterable),
          "_Errors.itContains(['f'], 'needle')");
    });
  });
}
