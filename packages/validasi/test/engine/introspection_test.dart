import 'package:test/test.dart';
import 'package:validasi/engine.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/validasi.dart';

void main() {
  group('ValidasiEngine introspect', () {
    test('should describe primitive schema and rule metadata', () {
      final engine = Validasi.string([
        StringRules.minLength(3),
      ]);

      final descriptor = engine.introspect();

      expect(descriptor.isReference, isFalse);
      expect(descriptor.type, equals('String'));
      expect(descriptor.hasPreprocess, isFalse);
      expect(descriptor.rules, hasLength(1));
      expect(descriptor.rules.first.name, equals('MinLength'));
      expect(descriptor.rules.first.parameters['length'], equals(3));
    });

    test('should include field names in HasFields metadata', () {
      final engine = Validasi.map<dynamic>([
        MapRules.hasFields({
          'name': FieldRules<String>([StringRules.minLength(2)]),
        }),
      ]);

      final descriptor = engine.introspect();
      final metadata = descriptor.rules.single;
      final fieldKeys = metadata.parameters['fields'] as List<String>;

      expect(fieldKeys, equals(['name']));
    });

    test('should mark callback-driven rules as dynamic', () {
      final engine = Validasi.string([
        InlineRule<String>((value) => value != null),
      ]);

      final descriptor = engine.introspect();
      final metadata = descriptor.rules.single;

      expect(metadata.isDynamic, isTrue);
      expect(metadata.dynamicReason, isNotNull);
    });

    test('should return reference for recursive nested schemas', () {
      final recursiveRule = _RecursiveRule();
      final engine = Validasi.string([recursiveRule]);
      recursiveRule.child = engine;

      final descriptor = engine.introspect();
      final nested = descriptor.rules.single.nestedSchemas['self'];

      expect(nested, isNotNull);
      expect(nested!['isReference'], isTrue);
      expect(nested['referenceTo'], equals(descriptor.id));
    });
  });
}

class _RecursiveRule extends Rule<String> {
  late ValidasiEngine<String, String> child;

  @override
  RuleMetadata get metadata => const RuleMetadata(name: 'RecursiveRule');

  @override
  Map<String, Object?> get metadataChildren => <String, Object?>{
        'self': child,
      };

  @override
  String? apply(String? value, ValidationState state) => value;
}
