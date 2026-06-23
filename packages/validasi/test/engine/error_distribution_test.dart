import 'package:test/test.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/error_distribution.dart';

void main() {
  group('groupErrorsByPath', () {
    test('groups errors by first path segment', () {
      final errors = [
        ValidationError(
          rule: 'MinLength',
          message: 'Too short',
          path: ['name'],
        ),
        ValidationError(
          rule: 'Required',
          message: 'Required',
          path: ['email'],
        ),
        ValidationError(
          rule: 'MaxLength',
          message: 'Too long',
          path: ['name'],
        ),
      ];

      final grouped = groupErrorsByPath(errors);

      expect(grouped.keys, containsAll(['name', 'email']));
      expect(grouped['name'], hasLength(2));
      expect(grouped['email'], hasLength(1));
    });

    test('groups pathless errors under empty string key', () {
      final errors = [
        ValidationError(rule: 'Refine', message: 'Cross-field error'),
        ValidationError(
          rule: 'MinLength',
          message: 'Too short',
          path: ['name'],
        ),
      ];

      final grouped = groupErrorsByPath(errors);

      expect(grouped.containsKey(''), isTrue);
      expect(grouped[''], hasLength(1));
      expect(grouped['']!.first.message, 'Cross-field error');
      expect(grouped['name'], hasLength(1));
    });

    test('groups errors with empty path under empty string key', () {
      final errors = [
        ValidationError(rule: 'Refine', message: 'Error', path: []),
      ];

      final grouped = groupErrorsByPath(errors);

      expect(grouped.containsKey(''), isTrue);
      expect(grouped[''], hasLength(1));
    });

    test('returns empty map for empty input', () {
      final grouped = groupErrorsByPath([]);
      expect(grouped, isEmpty);
    });

    test('uses nested path parent as key', () {
      final errors = [
        ValidationError(
          rule: 'MinLength',
          message: 'Too short',
          path: ['address', 'city'],
        ),
      ];

      final grouped = groupErrorsByPath(errors);

      expect(grouped.containsKey('address'), isTrue);
      expect(grouped['address'], hasLength(1));
    });

    test('preserves error order within each group', () {
      final errors = [
        ValidationError(rule: 'A', message: 'First', path: ['x']),
        ValidationError(rule: 'B', message: 'Second', path: ['x']),
        ValidationError(rule: 'C', message: 'Third', path: ['x']),
      ];

      final grouped = groupErrorsByPath(errors);

      expect(
        grouped['x']!.map((e) => e.rule).toList(),
        ['A', 'B', 'C'],
      );
    });
  });
}
