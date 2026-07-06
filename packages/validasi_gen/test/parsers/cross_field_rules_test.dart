import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generators/cross_field_sugar.dart';
import 'package:validasi_gen/src/parsers/cross_field_rules.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
@RequiredAny(['email', 'phone'])
@DependsOn(field: 'password', dependsOn: 'passwordConfirmation')
class Good {
  final String? email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;
  const Good({this.email, this.phone, this.password, this.passwordConfirmation});
}

@ValidateClass()
@DependsOn(field: 'password', dependsOn: 'missingField')
class BadFieldRef {
  final String? password;
  const BadFieldRef({this.password});
}

@ValidateClass()
@MutuallyExclusive('same', 'same')
class SameFieldTwice {
  final String? same;
  const SameFieldTwice({this.same});
}

@ValidateClass()
@RequiredAny(['onlyOne'])
class TooFewFields {
  final String? onlyOne;
  const TooFewFields({this.onlyOne});
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

  test('extractCrossFieldRules reads fields and message from each kind', () {
    final cls = library.getClass('Good')!;
    final infos = extractCrossFieldRules(cls);
    expect(infos, hasLength(2));
    expect(infos[0].kind, 'RequiredAny');
    expect(infos[0].fields, ['email', 'phone']);
    expect(infos[1].kind, 'DependsOn');
    expect(infos[1].fields, ['password', 'passwordConfirmation']);
  });

  test('desugarCrossFieldRules produces a synthetic RefineMethodInfo per annotation',
      () {
    final cls = library.getClass('Good')!;
    final infos = extractCrossFieldRules(cls);
    final desugared = desugarCrossFieldRules('Good', cls, infos);
    expect(desugared, hasLength(2));
    expect(desugared[0].refine.methodName, '_GoodCrossFieldRules.requiredAny_0');
    expect(desugared[0].refine.ruleName, 'RequiredAny');
    expect(desugared[0].refine.dependsOn, ['email', 'phone']);
    expect(desugared[1].refine.methodName, '_GoodCrossFieldRules.dependsOn_0');
  });

  test('desugarCrossFieldRules throws for an unknown field reference', () {
    final cls = library.getClass('BadFieldRef')!;
    final infos = extractCrossFieldRules(cls);
    expect(
      () => desugarCrossFieldRules('BadFieldRef', cls, infos),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test('desugarCrossFieldRules throws when two-field kinds repeat the same field',
      () {
    final cls = library.getClass('SameFieldTwice')!;
    final infos = extractCrossFieldRules(cls);
    expect(
      () => desugarCrossFieldRules('SameFieldTwice', cls, infos),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test('desugarCrossFieldRules throws when a multi-field kind has fewer than 2 fields',
      () {
    final cls = library.getClass('TooFewFields')!;
    final infos = extractCrossFieldRules(cls);
    expect(
      () => desugarCrossFieldRules('TooFewFields', cls, infos),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });
}
