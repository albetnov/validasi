import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Model {
  final String a;
  final String b;
  final String c;
  final String d;
  const _Model({this.a = '', this.b = '', this.c = '', this.d = ''});
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
      case 'd':
        return owner.d;
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
        d: reader.getValue(const _Field('d')) ?? '',
      );
}

const _schema = _ModelSchema();

class _BuildCounter {
  int _initial = 0;
  int _total = 0;
  int get total => _total;
  int get delta => _total - _initial;
  void inc() => _total++;
  void reset() => _initial = _total;
}

/// Build a form widget with [fields] and return the controller + counters.
Future<
    ({
      ValidasiFormController<_Model> controller,
      Map<_Field, _BuildCounter> counters,
    })> _setupForm(
  WidgetTester tester, {
  required List<_Field> fields,
  FutureOr<ValidasiResult<_Model>> Function(
    ValidasiFormController<_Model>,
  )? formValidator,
}) async {
  final controller = ValidasiFormController<_Model>(
    schema: _schema,
    formValidator: formValidator,
  );

  final counters = <_Field, _BuildCounter>{};
  for (final f in fields) {
    counters[f] = _BuildCounter();
  }

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ValidasiForm(
          controller: controller,
          schema: _schema,
          builder: (context, submit) => Column(
            children: [
              for (final f in fields)
                ValidasiFormField(
                  key: ValueKey(f.name),
                  field: f,
                  builder: (context, state) {
                    counters[f]!.inc();
                    return Text('${f.name}=${state.value ?? "null"}');
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );

  return (controller: controller, counters: counters);
}

void main() {
  group('A. Cross-field refinement rebuild cost', () {
    testWidgets('A1: refinement with ALL valid — measure unnecessary rebuilds',
        (tester) async {
      final fields = [
        const _Field('a'),
        const _Field('b'),
        const _Field('c'),
        const _Field('d'),
      ];

      final result = await _setupForm(
        tester,
        fields: fields,
        formValidator: (ctrl) {
          final errors = <ValidationError>[];
          final a = ctrl.getValue(const _Field('a'));
          final b = ctrl.getValue(const _Field('b'));
          if (a == 'bad') {
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'Refine A',
              path: ['a'],
            ));
          }
          if (b == 'bad') {
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'Refine B',
              path: ['b'],
            ));
          }
          return ValidasiResult(errors: errors, isValid: errors.isEmpty);
        },
      );

      final controller = result.controller;
      final counters = result.counters;

      controller.setValue(const _Field('a'), 'good');
      controller.setValue(const _Field('b'), 'good');
      controller.setValue(const _Field('c'), 'good');
      controller.setValue(const _Field('d'), 'good');
      await tester.pump();

      for (final c in counters.values) {
        c.reset();
      }

      controller.validate();
      await tester.pump();

      debugPrint('\n=== A1: ALL valid, refine returns 0 errors ===');
      for (final f in fields) {
        debugPrint('  ${f.name}: ${counters[f]!.delta} rebuild(s)');
      }

      // Ideal: 0 rebuilds for all fields (nothing changed)
      // Bug: all 4 rebuild because updateErrors([]) fires on each field
    });

    testWidgets('A2: refinement errors on 2 of 4 fields', (tester) async {
      final fields = [
        const _Field('a'),
        const _Field('b'),
        const _Field('c'),
        const _Field('d'),
      ];

      final result = await _setupForm(
        tester,
        fields: fields,
        formValidator: (ctrl) {
          final errors = <ValidationError>[];
          final a = ctrl.getValue(const _Field('a'));
          final b = ctrl.getValue(const _Field('b'));
          if (a == 'bad') {
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'Refine A',
              path: ['a'],
            ));
          }
          if (b == 'bad') {
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'Refine B',
              path: ['b'],
            ));
          }
          return ValidasiResult(errors: errors, isValid: errors.isEmpty);
        },
      );

      final controller = result.controller;
      final counters = result.counters;

      controller.setValue(const _Field('a'), 'bad');
      controller.setValue(const _Field('b'), 'bad');
      controller.setValue(const _Field('c'), 'good');
      controller.setValue(const _Field('d'), 'good');
      await tester.pump();

      for (final c in counters.values) {
        c.reset();
      }

      controller.validate();
      await tester.pump();

      final da = counters[fields[0]]!.delta;
      final db = counters[fields[1]]!.delta;
      final dc = counters[fields[2]]!.delta;
      final dd = counters[fields[3]]!.delta;

      debugPrint('\n=== A2: refine errors on a,b — valid c,d ===');
      debugPrint('  a (error added): $da rebuild(s)');
      debugPrint('  b (error added): $db rebuild(s)');
      debugPrint('  c (no error):    $dc rebuild(s)');
      debugPrint('  d (no error):    $dd rebuild(s)');
      debugPrint('  ---');
      debugPrint('  Ideal (batch):   a=1, b=1, c=0, d=0');
      debugPrint('  Actual (no batch): all 4 get updateErrors([]) first');
    });

    testWidgets('A3: per-field validate() WITH batch — baseline comparison',
        (tester) async {
      final fields = [
        const _Field('a'),
        const _Field('b'),
        const _Field('c'),
        const _Field('d'),
      ];

      final counters = <_Field, _BuildCounter>{};
      for (final f in fields) {
        counters[f] = _BuildCounter();
      }

      final controller = ValidasiFormController<_Model>(schema: _schema);

      // Use a builder function that closes over counters AFTER it's declared
      Widget buildForm() => MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                controller: controller,
                schema: _schema,
                builder: (context, submit) => Column(
                  children: [
                    for (final f in fields)
                      ValidasiFormField(
                        key: ValueKey(f.name),
                        field: f,
                        builder: (context, state) {
                          counters[f]!.inc();
                          return Text('${f.name}=${state.value ?? "null"}');
                        },
                      ),
                  ],
                ),
              ),
            ),
          );

      await tester.pumpWidget(buildForm());

      controller.setValue(const _Field('a'), 'valid');
      controller.setValue(const _Field('c'), '');
      await tester.pump();

      for (final c in counters.values) {
        c.reset();
      }

      // per-field path uses batch() internally
      controller.validate();
      await tester.pump();

      final da = counters[fields[0]]!.delta;
      final db = counters[fields[1]]!.delta;
      final dc = counters[fields[2]]!.delta;
      final dd = counters[fields[3]]!.delta;

      debugPrint('\n=== A3: per-field validate() WITH batch ===');
      debugPrint('  a (valid):        $da rebuild(s)');
      debugPrint('  b (empty invalid): $db rebuild(s)');
      debugPrint('  c (empty invalid): $dc rebuild(s)');
      debugPrint('  d (valid):        $dd rebuild(s)');
      debugPrint('  ---');
      debugPrint('  Expected (batch): only b, c rebuild (1 each)');
    });

    testWidgets('A4: first validate sets errors, second validate clears some',
        (tester) async {
      final fields = [
        const _Field('a'),
        const _Field('b'),
        const _Field('c'),
      ];

      final result = await _setupForm(
        tester,
        fields: fields,
        formValidator: (ctrl) {
          final a = ctrl.getValue(const _Field('a'));
          final errors = <ValidationError>[];
          if (a == 'trigger') {
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'A err',
              path: ['a'],
            ));
            errors.add(ValidationError(
              rule: 'Refine',
              message: 'B err',
              path: ['b'],
            ));
          }
          return ValidasiResult(errors: errors, isValid: errors.isEmpty);
        },
      );

      final controller = result.controller;
      final counters = result.counters;

      controller.setValue(const _Field('a'), 'trigger');
      controller.setValue(const _Field('b'), '');
      controller.setValue(const _Field('c'), '');
      await tester.pump();
      for (final c in counters.values) {
        c.reset();
      }

      // First validate: errors on a and b
      controller.validate();
      await tester.pump();

      final afterFirst = {
        for (final f in fields) f.name: counters[f]!.delta,
      };

      for (final c in counters.values) {
        c.reset();
      }

      // Second validate: fix a, but a and b still get errors? No, a='trigger' still
      // Actually let's change a to non-trigger
      controller.setValue(const _Field('a'), 'ok');
      await tester.pump();
      for (final c in counters.values) {
        c.reset();
      }

      controller.validate();
      await tester.pump();

      final afterSecond = {
        for (final f in fields) f.name: counters[f]!.delta,
      };

      debugPrint('\n=== A4: first validate (errors on a,b) ===');
      for (final entry in afterFirst.entries) {
        debugPrint('  ${entry.key}: ${entry.value} rebuild(s)');
      }
      debugPrint('\n=== A4: second validate (a fixed, no errors) ===');
      for (final entry in afterSecond.entries) {
        debugPrint('  ${entry.key}: ${entry.value} rebuild(s)');
      }
    });
  });
}
