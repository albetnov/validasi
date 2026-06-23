import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/handlers/max_length.dart';
import 'package:validasi_gen/src/handlers/min_length.dart';
import 'package:validasi_gen/src/handlers/one_of.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class StringModel {
  @Validate.string([MinLength(3)])
  final String name;
  const StringModel({required this.name});
}

@ValidateClass()
class IntModel {
  @Validate([MinLength(5)])
  final int count;
  const IntModel({required this.count});
}

@ValidateClass()
class IterableModel {
  @Validate.iterable([MinLength(1)])
  final List<String> items;
  const IterableModel({required this.items});
}

@ValidateClass()
class DoubleModel {
  @Validate([MaxLength(100)])
  final double price;
  const DoubleModel({required this.price});
}

@ValidateClass()
class OneOfIntModel {
  @Validate([OneOf(['a', 'b'])])
  final int code;
  const OneOfIntModel({required this.code});
}
''';

FieldElement _fieldOf(ClassElement cls, String name) {
  return cls.fields.firstWhere((f) => f.name == name);
}

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

  group('MinLengthGen.validateType', () {
    test('accepts String', () {
      final field = _fieldOf(library.getClass('StringModel')!, 'name');
      expect(() => MinLengthGen().validateType(field.type, field),
          returnsNormally);
    });

    test('throws for int', () {
      final field = _fieldOf(library.getClass('IntModel')!, 'count');
      expect(
        () => MinLengthGen().validateType(field.type, field),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('accepts List (Iterable)', () {
      final field = _fieldOf(library.getClass('IterableModel')!, 'items');
      expect(() => MinLengthGen().validateType(field.type, field),
          returnsNormally);
    });
  });

  group('MaxLengthGen.validateType', () {
    test('accepts String', () {
      final field = _fieldOf(library.getClass('StringModel')!, 'name');
      expect(() => MaxLengthGen().validateType(field.type, field),
          returnsNormally);
    });

    test('throws for double', () {
      final field = _fieldOf(library.getClass('DoubleModel')!, 'price');
      expect(
        () => MaxLengthGen().validateType(field.type, field),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });

  group('OneOfGen.validateType', () {
    test('accepts String', () {
      final field = _fieldOf(library.getClass('StringModel')!, 'name');
      expect(() => OneOfGen().validateType(field.type, field), returnsNormally);
    });

    test('throws for int', () {
      final field = _fieldOf(library.getClass('OneOfIntModel')!, 'code');
      expect(
        () => OneOfGen().validateType(field.type, field),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });
}
