import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'package:validasi_ui/validasi.dart';

class _StringKey extends ValidasiField<String, String> {
  const _StringKey(this._name);
  final String _name;

  @override
  String get name => _name;

  @override
  String? extract(String owner) => owner;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value ?? '');
}

ValidasiFormController<String> _newController() =>
    ValidasiFormController<String>(
      assembler: (c) => c.getValue(const _StringKey('v')) ?? '',
    );

void main() {
  group('watchValue', () {
    test('returns a signal that updates when setValue is called', () {
      final controller = _newController();
      const field = _StringKey('name');

      final s = controller.watchValue<String>(field);
      expect(s.value, isNull);

      controller.setValue(field, 'hello');
      expect(s.value, 'hello');

      controller.setValue(field, 'world');
      expect(s.value, 'world');

      controller.dispose();
    });

    test('auto-registers the field on first watch', () {
      final controller = _newController();
      const field = _StringKey('auto');

      controller.watchValue<String>(field);
      expect(controller.getFieldController<String>(field).value, isNull);

      controller.setValue(field, 'x');
      expect(controller.getValue(field), 'x');

      controller.dispose();
    });

    test('subsequent watchers share the same underlying signal', () {
      final controller = _newController();
      const field = _StringKey('shared');

      final a = controller.watchValue<String>(field);
      final b = controller.watchValue<String>(field);
      expect(identical(a, b), isTrue);

      controller.dispose();
    });
  });

  group('watch', () {
    test('re-evaluates the selector when any field changes', () {
      final controller = _newController();
      const a = _StringKey('a');
      const b = _StringKey('b');

      final s = controller.watch<String, String>([a, b], (values) {
        return [a, b].map((f) => values[f] ?? '-').join('|');
      });

      expect(s.value, '-|-');

      controller.setValue(a, 'A');
      expect(s.value, 'A|-');

      controller.setValue(b, 'B');
      expect(s.value, 'A|B');

      controller.setValue(a, 'A2');
      expect(s.value, 'A2|B');

      controller.dispose();
    });

    test('drops null-valued fields from the map', () {
      final controller = _newController();
      const a = _StringKey('a');
      const b = _StringKey('b');

      controller.setValue(a, 'A');

      final s =
          controller.watch<String, int>([a, b], (values) => values.length);

      expect(s.value, 1);

      controller.setValue(b, 'B');
      expect(s.value, 2);

      controller.setValue(a, null);
      expect(s.value, 1);

      controller.dispose();
    });

    test('auto-registers all listed fields', () {
      final controller = _newController();
      const a = _StringKey('a');
      const b = _StringKey('b');

      controller.watch<String, String>([a, b], (values) => '');

      controller.setValue(a, 'A');
      expect(controller.getValue(a), 'A');

      controller.setValue(b, 'B');
      expect(controller.getValue(b), 'B');

      controller.dispose();
    });
  });

  group('ValidasiWatch.form', () {
    testWidgets('rebuilds when a watched field changes', (tester) async {
      final controller = _newController();
      const a = _StringKey('a');
      const b = _StringKey('b');

      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            assembler: (c) => c.getValue(a) ?? '',
            builder: (context, submit) => ValidasiWatch.form<String>(
              builder: (context, c) {
                final s = c.watch<String, String>([a, b], (values) {
                  return values[a] ?? 'empty';
                });
                return Scaffold(body: Text('value=${s.value}'));
              },
            ),
          ),
        ),
      );

      expect(find.text('value=empty'), findsOneWidget);

      controller.setValue(a, 'hello');
      await tester.pump();
      expect(find.text('value=hello'), findsOneWidget);

      controller.setValue(b, 'B');
      await tester.pump();
      expect(find.text('value=hello'), findsOneWidget);

      controller.setValue(a, 'world');
      await tester.pump();
      expect(find.text('value=world'), findsOneWidget);

      controller.dispose();
    });
  });

  group('ValidasiWatch.field', () {
    testWidgets('rebuilds when the field value changes', (tester) async {
      final controller = _newController();
      const field = _StringKey('name');

      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            assembler: (c) => c.getValue(field) ?? '',
            builder: (context, submit) => Scaffold(
              body: ValidasiWatch.field<String, String>(
                field: field,
                builder: (context, value) => Text('value=$value'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('value=null'), findsOneWidget);

      controller.setValue(field, 'hello');
      await tester.pump();
      expect(find.text('value=hello'), findsOneWidget);

      controller.setValue(field, 'world');
      await tester.pump();
      expect(find.text('value=world'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('does not rebuild when an unrelated field changes',
        (tester) async {
      final controller = _newController();
      const watched = _StringKey('watched');
      const other = _StringKey('other');

      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            assembler: (c) => c.getValue(watched) ?? '',
            builder: (context, submit) => Scaffold(
              body: ValidasiWatch.field<String, String>(
                field: watched,
                builder: (context, value) {
                  builds++;
                  return Text('value=$value builds=$builds');
                },
              ),
            ),
          ),
        ),
      );

      final initialBuilds = builds;
      expect(builds, initialBuilds);

      controller.setValue(other, 'noise');
      await tester.pump();
      expect(builds, initialBuilds);

      controller.setValue(watched, 'x');
      await tester.pump();
      expect(builds, initialBuilds + 1);

      controller.dispose();
    });

    testWidgets('asserts when used outside a ValidasiForm', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiWatch.field<String, String>(
              field: _StringKey('x'),
              builder: (context, value) => const Text('nope'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}
