import 'package:test/test.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/inline_rule.dart';
import 'package:validasi/src/rules/iterable/foreach.dart';
import 'package:validasi/src/rules/map/all_values.dart';
import 'package:validasi/src/rules/map/field_rules.dart';
import 'package:validasi/src/rules/map/has_fields.dart';

final _fail = InlineRule<Object?>((_) => false, name: 'Fail');

void main() {
  group('Nested path prefixes', () {
    group('2 levels', () {
      test('HasFields > ForEach', () {
        final rule = HasFields({
          'items': FieldRules<Object?>([
            ForEach<Object?>([_fail])
          ]),
        });
        final state = ValidationState();

        rule.apply({
          'items': [1, 2]
        }, state);

        expect(state.errors[0].path, equals(['items', '[0]']));
        expect(state.errors[1].path, equals(['items', '[1]']));
      });

      test('ForEach > HasFields', () {
        final rule = ForEach<Object?>([
          HasFields({
            'x': FieldRules<Object?>([_fail]),
          }) as Rule<Object?>,
        ]);
        final state = ValidationState();

        rule.apply([
          {'x': 1},
          {'x': 2}
        ], state);

        expect(state.errors[0].path, equals(['[0]', 'x']));
        expect(state.errors[1].path, equals(['[1]', 'x']));
      });

      test('ForEach > ForEach', () {
        final rule = ForEach<Object?>([
          ForEach<Object?>([_fail]) as Rule<Object?>,
        ]);
        final state = ValidationState();

        rule.apply([
          [1, 2],
          [3]
        ], state);

        expect(state.errors[0].path, equals(['[0]', '[0]']));
        expect(state.errors[1].path, equals(['[0]', '[1]']));
        expect(state.errors[2].path, equals(['[1]', '[0]']));
      });

      test('HasFields > HasFields', () {
        final rule = HasFields({
          'outer': FieldRules<Object?>([
            HasFields({
              'inner': FieldRules<Object?>([_fail]),
            }) as Rule<Object?>,
          ]),
        });
        final state = ValidationState();

        rule.apply({
          'outer': {'inner': 1}
        }, state);

        expect(state.errors[0].path, equals(['outer', 'inner']));
      });

      test('AllValues > ForEach', () {
        final rule = AllValues([
          ForEach<Object?>([_fail]) as Rule<Object?>,
        ]);
        final state = ValidationState();

        rule.apply({
          'a': [1, 2],
          'b': [3]
        }, state);

        expect(state.errors[0].path, equals(['a', '[0]']));
        expect(state.errors[1].path, equals(['a', '[1]']));
        expect(state.errors[2].path, equals(['b', '[0]']));
      });
    });

    group('3 levels', () {
      test('HasFields > ForEach > HasFields', () {
        final rule = HasFields({
          'items': FieldRules<Object?>([
            ForEach<Object?>([
              HasFields({
                'x': FieldRules<Object?>([_fail]),
              }) as Rule<Object?>,
            ]),
          ]),
        });
        final state = ValidationState();

        rule.apply({
          'items': [
            {'x': 1},
            {'x': 2},
          ]
        }, state);

        expect(state.errors[0].path, equals(['items', '[0]', 'x']));
        expect(state.errors[1].path, equals(['items', '[1]', 'x']));
      });

      test('ForEach > HasFields > ForEach', () {
        final rule = ForEach<Object?>([
          HasFields({
            'nums': FieldRules<Object?>([
              ForEach<Object?>([_fail])
            ]),
          }) as Rule<Object?>,
        ]);
        final state = ValidationState();

        rule.apply([
          {
            'nums': [1, 2]
          },
          {
            'nums': [3]
          },
        ], state);

        expect(state.errors[0].path, equals(['[0]', 'nums', '[0]']));
        expect(state.errors[1].path, equals(['[0]', 'nums', '[1]']));
        expect(state.errors[2].path, equals(['[1]', 'nums', '[0]']));
      });

      test('ForEach > ForEach > ForEach', () {
        final rule = ForEach<Object?>([
          ForEach<Object?>([
            ForEach<Object?>([_fail]) as Rule<Object?>,
          ]) as Rule<Object?>,
        ]);
        final state = ValidationState();

        rule.apply([
          [
            [1, 2]
          ],
          [
            [3]
          ],
        ], state);

        expect(state.errors[0].path, equals(['[0]', '[0]', '[0]']));
        expect(state.errors[1].path, equals(['[0]', '[0]', '[1]']));
        expect(state.errors[2].path, equals(['[1]', '[0]', '[0]']));
      });
    });
  });
}
