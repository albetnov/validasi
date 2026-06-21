import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Nested object validation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'nested_source.dart',
      );
    });

    test('generates field for non-nullable nested object', () {
      expect(
          output,
          contains(
              'static const UserWithNestedFields<Car> car = UserWithNestedCarField();'));
    });

    test('generates field for nullable nested object', () {
      expect(
          output,
          contains(
              'static const UserWithNestedFields<Car?> spareCar = UserWithNestedSpareCarField();'));
    });

    test('generates field for List<Nested>', () {
      expect(
          output,
          contains(
              'static const UserWithNestedFields<List<Car>> previousCars = UserWithNestedPreviousCarsField();'));
    });

    test('non-nullable nested validate calls value.validate()', () {
      expect(output, contains('final \$carResult = value.validate();'));
      expect(
          output,
          contains(
              'errors: \$carResult.errors.map((e) => e..prefix(name)).toList()'));
    });

    test('nullable nested validate checks for null', () {
      expect(output, contains('ValidasiResult<Car?> validate(Car? value)'));
      expect(output, contains('if (value == null)'));
      expect(output,
          contains('return const ValidasiResult(errors: [], isValid: true);'));
    });

    test('List<Nested> validate iterates with index', () {
      expect(output, contains('for (var \$previousCarsIndex = 0;'));
      expect(output,
          contains('final \$previousCarsItem = value[\$previousCarsIndex];'));
      expect(
          output,
          contains(
              r'$errors.addAll($previousCarsResult.errors.map((e) => e..prefix("$name[${$previousCarsIndex}]")));'));
    });

    test('extension generates nested validation in validate()', () {
      expect(output, contains('final \$carResult = car.validate();'));
      expect(
          output,
          contains(
              "\$errors.addAll(\$carResult.errors.map((e) => e..prefix('car')))"));
    });

    test('extension generates nullable nested validation', () {
      expect(output, contains('final \$spareCarValue = spareCar;'));
      expect(output, contains('if (\$spareCarValue != null)'));
      expect(
          output,
          contains(
              "\$spareCarResult.errors.map((e) => e..prefix('spareCar'))"));
    });

    test('extension generates List<Nested> validation', () {
      expect(output, contains('for (var \$previousCarsIndex = 0;'));
      expect(output, contains('\$previousCarsIndex < previousCars.length;'));
    });

    test('Car generates its own fields class and extension', () {
      expect(output, contains('sealed class CarFields<V>'));
      expect(output, contains('extension \$CarValidasi on Car'));
    });
  });
}
