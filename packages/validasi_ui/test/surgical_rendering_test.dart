import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Model {
  final String a;
  final String b;
  final String c;
  const _Model({this.a = '', this.b = '', this.c = ''});
}

class _Field extends ValidasiField<_Model, String> {
  final String _name;
  const _Field(this._name);
  @override
  String get name => _name;
  @override
  String? extract(_Model owner) {
    switch (_name) {
      case 'a':
        return owner.a;
      case 'b':
        return owner.b;
      case 'c':
        return owner.c;
      default:
        return null;
    }
  }

  @override
  ValidasiResult<String> validate(String? v) {
    if (v == null || v.isEmpty) {
      return ValidasiResult.error(
        ValidationError(rule: 'Required', message: '$name required'),
      );
    }
    return ValidasiResult.success(v);
  }
}

class _ModelSchema extends ValidasiSchema<_Model> {
  const _ModelSchema();
  @override
  _Model allocate(ValidasiFieldReader<_Model> reader) => _Model(
        a: reader.getValue(const _Field('a')) ?? '',
        b: reader.getValue(const _Field('b')) ?? '',
        c: reader.getValue(const _Field('c')) ?? '',
      );
}

const _schema = _ModelSchema();

class _BuildCounter {
  int _initial = 0;
  int _total = 0;
  int get delta => _total - _initial;
  void inc() => _total++;
  void reset() => _initial = _total;
}

void main() {
  group('B. Surgical rendering — rebuild isolation', () {
    // B1: single field setValue rebuilds only that field
    testWidgets('B1: setValue on field A rebuilds ONLY field A',
        (tester) async {
      final counters = {
        'a': _BuildCounter(),
        'b': _BuildCounter(),
        'c': _BuildCounter(),
      };
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: const _Field('a'),
                    builder: (c, s) {
                      counters['a']!.inc();
                      return Text('a=${s.value}');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('b'),
                    builder: (c, s) {
                      counters['b']!.inc();
                      return Text('b=${s.value}');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('c'),
                    builder: (c, s) {
                      counters['c']!.inc();
                      return Text('c=${s.value}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      for (final c in counters.values) {
        c.reset();
      }

      controller.setValue(const _Field('a'), 'updated');
      await tester.pump();

      debugPrint('\n=== B1: setValue on field A ===');
      debugPrint('  a: ${counters['a']!.delta} rebuild(s)');
      debugPrint('  b: ${counters['b']!.delta} rebuild(s)');
      debugPrint('  c: ${counters['c']!.delta} rebuild(s)');

      // a's value signal changed -> a's SignalBuilder rebuilds
      // b and c untouched -> should be 0
    });

    // B2: ValidasiWatch.field does not rebuild on unrelated changes
    testWidgets('B2: ValidasiWatch.field rebuilds only on its field change',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      var watchBuilds = 0;
      var fieldBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.field(
                    field: const _Field('a'),
                    builder: (context, value) {
                      watchBuilds++;
                      return Text('watch_a=$value');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('b'),
                    builder: (c, s) {
                      fieldBuilds++;
                      return Text('b=${s.value}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final initialWatch = watchBuilds;
      final initialField = fieldBuilds;
      watchBuilds = 0;
      fieldBuilds = 0;

      // Change field B — watch on A should NOT rebuild
      controller.setValue(const _Field('b'), 'changed');
      await tester.pump();

      debugPrint('\n=== B2: ValidasiWatch.field on A, change B ===');
      debugPrint('  watch a: ${watchBuilds - initialWatch} rebuild(s)');
      debugPrint('  field b: ${fieldBuilds - initialField} rebuild(s)');
    });

    // B3: ValidasiWatch.form rebuilds on ANY change (by design)
    testWidgets('B3: ValidasiWatch.form rebuilds on any field change',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      var formWatchBuilds = 0;
      var fieldBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.form<_Model>(
                    builder: (context, c) {
                      formWatchBuilds++;
                      return Text('formWatch');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('a'),
                    builder: (c, s) {
                      fieldBuilds++;
                      return Text('a=${s.value}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final initialForm = formWatchBuilds;
      formWatchBuilds = 0;
      fieldBuilds = 0;

      // Change unrelated — form watch (ChangeNotifier listener) rebuilds
      controller.setValue(const _Field('a'), 'x');
      await tester.pump();

      debugPrint('\n=== B3: ValidasiWatch.form + field A, change A ===');
      debugPrint('  formWatch: ${formWatchBuilds - initialForm} rebuild(s)');
      debugPrint('  field a:   $fieldBuilds rebuild(s)');
    });

    // B4: multiple independent setValues — each triggers only its own builder
    testWidgets('B4: sequential setValue on 3 fields — O(1) per change',
        (tester) async {
      final counters = {
        'a': _BuildCounter(),
        'b': _BuildCounter(),
        'c': _BuildCounter(),
      };
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  for (final name in ['a', 'b', 'c'])
                    ValidasiFormField(
                      key: ValueKey(name),
                      field: _Field(name),
                      builder: (c, s) {
                        counters[name]!.inc();
                        return Text('$name=${s.value}');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      for (final c in counters.values) {
        c.reset();
      }

      // Change A only
      controller.setValue(const _Field('a'), '1');
      await tester.pump();
      final afterA = {for (final k in counters.keys) k: counters[k]!.delta};

      for (final c in counters.values) {
        c.reset();
      }

      // Change B only
      controller.setValue(const _Field('b'), '2');
      await tester.pump();
      final afterB = {for (final k in counters.keys) k: counters[k]!.delta};

      debugPrint('\n=== B4: sequential setValues ===');
      debugPrint(
          '  After change A: a=${afterA['a']}, b=${afterA['b']}, c=${afterA['c']}');
      debugPrint(
          '  After change B: a=${afterB['a']}, b=${afterB['b']}, c=${afterB['c']}');
      debugPrint('  Ideal: only changed field rebuilds (1), others 0');
    });

    // B5: disabled field onChanged does not trigger rebuilds
    testWidgets('B5: disabled field setValue does not rebuild', (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      var disabledFieldBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: const _Field('a'),
                    disabled: true,
                    builder: (c, s) {
                      disabledFieldBuilds++;
                      return Text('a=${s.value}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      disabledFieldBuilds = 0;

      // setValue on disabled field is a no-op (value not written)
      controller.setValue(const _Field('a'), 'x');
      await tester.pump();

      debugPrint('\n=== B5: disabled field setValue ===');
      debugPrint('  disabled field: $disabledFieldBuilds rebuild(s)');
    });

    // B6: validateField on one field rebuilds only that field
    testWidgets('B6: validateField on field A rebuilds only A', (tester) async {
      final counters = {
        'a': _BuildCounter(),
        'b': _BuildCounter(),
      };
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: const _Field('a'),
                    builder: (c, s) {
                      counters['a']!.inc();
                      return Text('a=${s.value} err=${s.errorText}');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('b'),
                    builder: (c, s) {
                      counters['b']!.inc();
                      return Text('b=${s.value} err=${s.errorText}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Set A to empty so it fails validation
      controller.setValue(const _Field('a'), '');
      await tester.pump();

      for (final c in counters.values) {
        c.reset();
      }

      controller.validateField(const _Field('a'));
      await tester.pump();

      debugPrint('\n=== B6: validateField on A ===');
      debugPrint('  a: ${counters['a']!.delta} rebuild(s)');
      debugPrint('  b: ${counters['b']!.delta} rebuild(s)');
      debugPrint('  Ideal: only a rebuilds (1), b stays at 0');
    });

    // B7: onChanged + onChange mode - only changed field validates
    testWidgets('B7: onChange mode — only the changed field validates',
        (tester) async {
      final counters = {
        'a': _BuildCounter(),
        'b': _BuildCounter(),
      };
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              mode: ValidationMode.onChange,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: const _Field('a'),
                    builder: (c, s) {
                      counters['a']!.inc();
                      return TextField(
                        onChanged: s.onChanged,
                        decoration: InputDecoration(errorText: s.errorText),
                      );
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('b'),
                    builder: (c, s) {
                      counters['b']!.inc();
                      return TextField(
                        onChanged: s.onChanged,
                        decoration: InputDecoration(errorText: s.errorText),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Get the first TextField and enter text
      for (final c in counters.values) {
        c.reset();
      }

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'hello');
      await tester.pump();

      debugPrint('\n=== B7: onChange mode, type in field A ===');
      debugPrint('  a: ${counters['a']!.delta} rebuild(s)');
      debugPrint('  b: ${counters['b']!.delta} rebuild(s)');
      debugPrint('  Ideal: only a rebuilds (value + validation), b stays at 0');
    });

    // B8: submit triggers validate() — measure all fields
    testWidgets('B8: submit triggers all field rebuilds', (tester) async {
      final counters = {
        'a': _BuildCounter(),
        'b': _BuildCounter(),
      };
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: const _Field('a'),
                    builder: (c, s) {
                      counters['a']!.inc();
                      return Text('a=${s.value}');
                    },
                  ),
                  ValidasiFormField(
                    field: const _Field('b'),
                    builder: (c, s) {
                      counters['b']!.inc();
                      return Text('b=${s.value}');
                    },
                  ),
                  ElevatedButton(
                    onPressed: submit((_) {}),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      controller.setValue(const _Field('a'), 'x');
      controller.setValue(const _Field('b'), 'y');
      await tester.pump();

      for (final c in counters.values) {
        c.reset();
      }

      // Press submit -> validate() called
      await tester.tap(find.text('Submit'));
      await tester.pump();

      debugPrint('\n=== B8: submit triggers validate() ===');
      debugPrint('  a: ${counters['a']!.delta} rebuild(s)');
      debugPrint('  b: ${counters['b']!.delta} rebuild(s)');
      debugPrint(
          '  Ideal: field a and b both get _applyErrors (even if valid)');
    });
  });
}
