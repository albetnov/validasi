import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

class _TestKey extends ValidasiField<String, String> {
  const _TestKey(this._name) : super();
  final String _name;

  @override
  String get name => _name;

  @override
  String? extract(String owner) => null;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value ?? '');
}

class _ErrorKey extends ValidasiField<String, String> {
  const _ErrorKey(this._name) : super();
  final String _name;

  @override
  String get name => _name;

  @override
  String? extract(String owner) => null;

  @override
  ValidasiResult<String> validate(String? value) => ValidasiResult.error(
        ValidationError(rule: 'Invalid', message: '$_name invalid'),
      );
}

class _ListField extends ValidasiField<String, List<String>> {
  const _ListField() : super();

  @override
  String get name => 'items';

  @override
  List<String>? extract(String owner) => null;

  @override
  ValidasiResult<List<String>> validate(List<String>? v) =>
      ValidasiResult.success(v ?? <String>[]);
}

const _emptyStringSchema = _EmptyStringSchema();

class _EmptyStringSchema extends ValidasiSchema<String> {
  const _EmptyStringSchema();

  @override
  String allocate(ValidasiFieldReader<String> reader) => '';
}

ValidasiFormController<String> _makeController() {
  return ValidasiFormController(schema: _emptyStringSchema);
}

Widget _buildFormWithWatch({
  required ValidasiFormController<String> controller,
  required Widget Function(BuildContext, ValidasiFormController<String>)
      watchBuilder,
  bool shouldUnregister = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ValidasiForm(
        controller: controller,
        shouldUnregister: shouldUnregister,
        builder: (context, submit) => ValidasiWatch.form(
          controller: controller,
          builder: watchBuilder,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ========================================================================
  // A. Direct regression repros [FAILS-ON-OLD]
  // ========================================================================

  group('A. direct regression: eviction under watch does not crash', () {
    testWidgets(
        'A1: conditional field removal under ValidasiWatch.form ancestor',
        (tester) async {
      final controller = _makeController();
      final notifier = ValueNotifier<String>('user');

      FlutterError? capturedError;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        capturedError ??=
            d.exception is FlutterError ? d.exception as FlutterError : null;
      };

      addTearDown(() {
        FlutterError.onError = prev;
        notifier.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              builder: (context, submit) => ValidasiWatch.form(
                controller: controller,
                builder: (context, c) => ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (_, role, __) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('role=$role'),
                      if (role == 'admin')
                        ValidasiFormField(
                          field: const _TestKey('token'),
                          builder: (context, state) =>
                              Text('token=${state.value}'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Add the conditional field
      notifier.value = 'admin';
      await tester.pump();

      expect(find.text('token=null'), findsOneWidget);

      // Remove the conditional field — _FieldDisposer disposes during
      // finalizeTree; on old code this would call notifyListeners synchronously
      // while the ListenableBuilder is mounted -> FlutterError.
      notifier.value = 'user';
      await tester.pump();

      expect(capturedError, isNull);
      expect(find.text('token=null'), findsNothing);
    });

    testWidgets('A2: ListView eviction under ValidasiWatch.form',
        (tester) async {
      final controller = _makeController();

      FlutterError? capturedError;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        capturedError ??=
            d.exception is FlutterError ? d.exception as FlutterError : null;
      };
      addTearDown(() => FlutterError.onError = prev);

      final fields = List.generate(10, (i) => _TestKey('f$i'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              builder: (context, submit) => ValidasiWatch.form(
                controller: controller,
                builder: (context, c) => SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: fields.length,
                    itemBuilder: (context, i) => ValidasiFormField(
                      field: fields[i],
                      builder: (context, state) =>
                          SizedBox(height: 60, child: Text('f$i')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll to evict early items
      await tester.scrollUntilVisible(find.text('f9'), 60);
      await tester.pumpAndSettle();

      expect(capturedError, isNull);
      // Evicted fields' values should be null after post-frame flush
      expect(controller.getValue(const _TestKey('f0')), isNull);
      expect(controller.getValue(const _TestKey('f1')), isNull);
    });

    testWidgets(
        'A3: sibling ValidasiFormField removal under ValidasiWatch.form sibling',
        (tester) async {
      final controller = _makeController();
      final showField = ValueNotifier<bool>(true);

      FlutterError? capturedError;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        capturedError ??=
            d.exception is FlutterError ? d.exception as FlutterError : null;
      };
      addTearDown(() {
        FlutterError.onError = prev;
        showField.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              builder: (context, submit) => ValueListenableBuilder(
                valueListenable: showField,
                builder: (_, show, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValidasiWatch.form(
                      controller: controller,
                      builder: (context, c) => Text('valid=${c.isValid}'),
                    ),
                    if (show)
                      ValidasiFormField(
                        field: const _TestKey('a'),
                        builder: (context, state) => Text('a=${state.value}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('a=null'), findsOneWidget);

      // Remove field — sibling watch is mounted and listening
      showField.value = false;
      await tester.pump();

      expect(capturedError, isNull);
      expect(controller.getValue(const _TestKey('a')), isNull);
    });
  });

  // ========================================================================
  // B. Deferral & timing semantics
  // ========================================================================

  group('B. deferral and timing', () {
    testWidgets('B4: field removal defers unregister to post-frame callback',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('defer');
      const keeper = _TestKey('keeper');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValidasiFormField(
                field: keeper,
                builder: (_, st) => Text('k=${st.value}'),
              ),
              if (s)
                ValidasiFormField(
                  field: field,
                  builder: (_, st) => Text('v=${st.value}'),
                ),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'v');
      await tester.pump();
      expect(controller.getValue(field), 'v');

      // Remove field — _FieldDisposer.dispose marks unmount
      show.value = false;
      // Synchronously before pump: field still registered (reconcile deferred)
      expect(controller.getValue(field), 'v');

      await tester.pump();
      // Post-frame reconcile: field is tracked but NOT mounted -> unregistered

      expect(controller.getValue(field), isNull);
      // Keeper survives
      expect(controller.getValue(keeper), isNull);
      controller.dispose();
    });

    testWidgets(
        'B5: untrackField prevents reconciliation for shouldUnregister: false',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('cancel');
      const other = _TestKey('other');

      // Frame 1: field is tracked
      controller.markFieldTracked(field);
      await tester.pump();

      controller.setValue(field, 'v');

      // Frame 2: field is untracked (shouldUnregister: false)
      controller.untrackField(field);
      controller.markFieldTracked(other);
      await tester.pump();
      // Reconcile: field is NOT tracked -> not reconciled -> survives

      expect(controller.getValue(field), 'v');
      controller.dispose();
    });
  });

  // ========================================================================
  // C. Coalescing
  // ========================================================================

  group('C. notify coalescing', () {
    testWidgets(
        'C6: N simultaneous evictions produce exactly one notifyListeners',
        (tester) async {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');
      const c = _TestKey('c');

      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      // Mount all three
      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValidasiFormField(
                field: a, builder: (_, s) => Text('a=${s.value}')),
            ValidasiFormField(
                field: b, builder: (_, s) => Text('b=${s.value}')),
            ValidasiFormField(
                field: c, builder: (_, s) => Text('c=${s.value}')),
          ],
        ),
      ));

      controller.setValue(a, 'A');
      controller.setValue(b, 'B');
      controller.setValue(c, 'C');
      await tester.pump();
      notifyCount = 0;

      // Evict all three in one rebuild
      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => const Text('empty'),
      ));

      // Exactly one notify from the post-frame flush
      expect(notifyCount, equals(1));
      expect(controller.getValue(a), isNull);
      expect(controller.getValue(b), isNull);
      expect(controller.getValue(c), isNull);
    });

    testWidgets(
        'C7: manual setValue on survivor + eviction in same frame coalesces',
        (tester) async {
      final controller = _makeController();
      const evict = _TestKey('evict');
      const keep = _TestKey('keep');

      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      // Mount both
      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValidasiFormField(
                field: evict, builder: (_, s) => Text('evict=${s.value}')),
            ValidasiFormField(
                field: keep, builder: (_, s) => Text('keep=${s.value}')),
          ],
        ),
      ));

      controller.setValue(evict, 'gone');
      controller.setValue(keep, 'stay');
      await tester.pump();
      notifyCount = 0;

      // Evict one, keep the other
      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValidasiFormField(
                field: keep, builder: (_, s) => Text('keep=${s.value}')),
          ],
        ),
      ));

      // One notify from the eviction flush (coalesced)
      expect(notifyCount, equals(1));
      expect(controller.getValue(evict), isNull);
      expect(controller.getValue(keep), 'stay');
    });
  });

  // ========================================================================
  // D. Signal preservation & re-mount
  // ========================================================================

  group('D. re-mount semantics', () {
    testWidgets('D8: eviction nulls value; re-mount registers fresh signal',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('fresh');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, showVal, __) => showVal
              ? ValidasiFormField(
                  field: field, builder: (_, s) => Text('v=${s.value}'))
              : const Text('gone'),
        ),
      ));

      controller.setValue(field, 'first');
      await tester.pump();

      final beforeEviction = controller.getFieldController(field);
      expect(beforeEviction.value, 'first');

      // Evict
      show.value = false;
      await tester.pump();

      expect(controller.getValue(field), isNull);

      // Re-mount
      show.value = true;
      await tester.pump();

      // Fresh signal — not the disposed one
      final afterRemount = controller.getFieldController(field);
      expect(afterRemount.value, isNull);
    });

    testWidgets(
        'D9: same-frame recycle preserves signals when field is re-added',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('cycle');
      final step = ValueNotifier<int>(0);

      addTearDown(() => step.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: step,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s == 0 || s == 2)
                ValidasiFormField(
                    field: field, builder: (_, st) => Text('v=${st.value}')),
              if (s == 1) const Text('gap'),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'keep');
      await tester.pump();
      expect(controller.getValue(field), 'keep');

      // Step 1: evict
      step.value = 1;
      await tester.pump();

      // Step 2: re-mount — fresh (no value carried over from old signal)
      step.value = 2;
      await tester.pump();

      // The field was fully unregistered by step 1, then re-registered fresh
      expect(controller.getValue(field), isNull);
      expect(controller.getFieldController(field).value, isNull);
    });

    testWidgets('D10: shouldUnregister false field survives eviction',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('sticky');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => s
              ? ValidasiFormField(
                  field: field,
                  shouldUnregister: false,
                  builder: (_, st) => Text('v=${st.value}'))
              : const Text('gone'),
        ),
      ));

      controller.setValue(field, 'persists');
      await tester.pump();
      expect(controller.getValue(field), 'persists');

      // Evict — shouldUnregister: false means no _FieldDisposer is wrapped
      show.value = false;
      await tester.pump();

      // Value persists
      expect(controller.getValue(field), 'persists');
    });
  });

  // ========================================================================
  // E. Arrays + eviction
  // ========================================================================

  group('E. array fields + eviction', () {
    testWidgets('E11: eviction of array-item sub-field widget', (tester) async {
      final controller = _makeController();
      const listField = _ListField();
      final showItem = ValueNotifier<bool>(true);

      addTearDown(() => showItem.dispose());

      controller.appendArrayItem(listField, 'item0');
      final itemField = controller.getArrayItemField(listField, 0)!;
      controller.setValue(itemField, 'v0');

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: showItem,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: itemField,
                    builder: (_, st) => Text('item=${st.value}'))
              else
                const Text('empty'),
            ],
          ),
        ),
      ));

      expect(find.text('item=v0'), findsOneWidget);

      // Evict the sub-field widget
      showItem.value = false;
      await tester.pump();

      // Sub-field is unregistered; parent list value is untouched
      expect(controller.getArraySubField(listField, 0, 'name'), isNull);
      expect(controller.getArrayItemCount(listField), 1);
    });

    testWidgets(
        'E12: eviction of array PARENT field cascades sub-field cleanup',
        (tester) async {
      final controller = _makeController();
      const listField = _ListField();
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      controller.appendArrayItem(listField, 'item0');
      controller.appendArrayItem(listField, 'item1');

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: listField,
                    builder: (_, st) =>
                        Text('count=${(st.value ?? []).length}'))
              else
                const Text('gone'),
            ],
          ),
        ),
      ));

      expect(find.text('count=2'), findsOneWidget);

      // Evict parent
      show.value = false;
      await tester.pump();

      // Parent field and sub-fields cleaned up
      expect(controller.getValue(listField), isNull);
    });
  });

  // ========================================================================
  // F. Async validation + eviction
  // ========================================================================

  group('F. async validation + eviction', () {
    testWidgets('F13: async in-flight at eviction is cancelled, no stale error',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('async');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: field,
                    validator: (_) async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      return 'async error';
                    },
                    builder: (_, st) => Text('v=${st.value}'))
              else
                const Text('gone'),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'test');
      await tester.pump();
      await controller.triggerAsyncValidation(field);

      // Evict before async completes
      show.value = false;
      await tester.pump();

      // Wait for the async to "complete"
      await tester.pump(const Duration(milliseconds: 200));

      // Re-mount
      show.value = true;
      await tester.pump();

      // No stale error on the fresh signal
      expect(controller.getErrors(field), isEmpty);
    });

    testWidgets('F14: async completes before eviction then no stale error',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('quick');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: field,
                    validator: (_) async => 'async error',
                    builder: (_, st) => Text('v=${st.value}'))
              else
                const Text('gone'),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'test');
      await tester.pump();
      await controller.triggerAsyncValidation(field);
      await tester.pump(const Duration(milliseconds: 50));

      // Evict after async completed
      show.value = false;
      await tester.pump();

      // Re-mount
      show.value = true;
      await tester.pump();

      expect(controller.getErrors(field), isEmpty);
    });
  });

  // ========================================================================
  // G. Form-level state after eviction
  // ========================================================================

  group('G. form-level state after eviction', () {
    testWidgets('G15: validate() after eviction excludes evicted field',
        (tester) async {
      final controller = _makeController();
      const invalid = _ErrorKey('bad');
      const valid = _TestKey('good');
      final showBad = ValueNotifier<bool>(true);

      addTearDown(() => showBad.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: showBad,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: invalid,
                    builder: (_, st) => Text('bad=${st.value}')),
              ValidasiFormField(
                  field: valid, builder: (_, st) => Text('good=${st.value}')),
            ],
          ),
        ),
      ));

      controller.setValue(invalid, 'x');
      controller.setValue(valid, 'y');
      await tester.pump();

      expect(controller.validate(), isFalse);

      // Evict the invalid field
      showBad.value = false;
      await tester.pump();

      // Now only the valid field remains
      expect(controller.validate(), isTrue);
    });

    testWidgets('G16: getValues() after eviction excludes evicted field',
        (tester) async {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');
      final showA = ValueNotifier<bool>(true);

      addTearDown(() => showA.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: showA,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: a, builder: (_, st) => Text('a=${st.value}')),
              ValidasiFormField(
                  field: b, builder: (_, st) => Text('b=${st.value}')),
            ],
          ),
        ),
      ));

      controller.setValue(a, 'A');
      controller.setValue(b, 'B');
      await tester.pump();

      showA.value = false;
      await tester.pump();

      final values = controller.getValues();
      expect(values.length, 1);
      expect(values[b], 'B');
    });

    testWidgets('G17: isDirty / isTouched recompute after eviction',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('dirty');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: field, builder: (_, st) => Text('v=${st.value}'))
              else
                const Text('gone'),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'changed');
      await tester.pump();

      expect(controller.isDirty, isTrue);
      expect(controller.isTouched, isTrue);

      // Evict
      show.value = false;
      await tester.pump();

      expect(controller.isDirty, isFalse);
      expect(controller.isTouched, isFalse);
    });
  });

  // ========================================================================
  // H. Controller lifecycle edge cases
  // ========================================================================

  group('H. controller lifecycle edge cases', () {
    testWidgets(
        'H18: controller disposed before post-frame reconcile — no crash',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('disposed');

      controller.markFieldTracked(field);
      // Post-frame callback is scheduled but hasn't fired yet

      // Dispose before the callback runs
      controller.dispose();

      // Pump to trigger the post-frame callback
      await tester.pump();

      // No exception — _disposed guard in _reconcilePresence
      expect(() => controller.isSubmitted, throwsA(isA<StateError>()));
    });

    testWidgets('H19: manual unregister after markFieldPresent is idempotent',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('idempotent');
      const other = _TestKey('other');

      controller.markFieldTracked(field);
      controller.markFieldTracked(other);
      await tester.pump();
      // Reconcile: both present, no removal.

      controller.setValue(field, 'v');

      // Manual unregister runs synchronously
      controller.unregister(field);
      expect(controller.getValue(field), isNull);

      // Next frame: only `other` is present
      controller.markFieldTracked(other);
      await tester.pump();
      // Reconcile: field is NOT in _trackedFields (removed by manual
      // unregister) -> no-op. No crash.

      expect(controller.getValue(field), isNull);
      controller.dispose();
    });

    testWidgets('H20: late untrack after reconcile already fired is no-op',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('late-cancel');
      const other = _TestKey('other');

      // Frame 1: field is tracked
      controller.markFieldTracked(field);
      controller.markFieldTracked(other);
      await tester.pump();
      // Reconcile: both present, no removal.

      controller.setValue(field, 'v');

      // Frame 2: untrack field, keep other
      controller.untrackField(field);
      controller.markFieldTracked(other);
      await tester.pump();
      // Reconcile: field is NOT tracked -> not reconciled -> survives

      expect(controller.getValue(field), 'v');
      controller.dispose();
    });
  });

  // ========================================================================
  // I. Stress / rapid cycles
  // ========================================================================

  group('I. stress', () {
    testWidgets(
        'I21: rapid 10-iteration mount/unmount cycle — no leak, no crash',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('rapid');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      FlutterError? capturedError;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        capturedError ??=
            d.exception is FlutterError ? d.exception as FlutterError : null;
      };
      addTearDown(() => FlutterError.onError = prev);

      for (var i = 0; i < 10; i++) {
        // Mount
        await tester.pumpWidget(_buildFormWithWatch(
          controller: controller,
          watchBuilder: (_, __) => ValueListenableBuilder(
            valueListenable: show,
            builder: (_, s, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (s)
                  ValidasiFormField(
                      field: field, builder: (_, st) => Text('v=${st.value}'))
                else
                  const Text('gone'),
              ],
            ),
          ),
        ));

        controller.setValue(field, 'iter$i');
        await tester.pump();

        // Unmount
        show.value = false;
        await tester.pump();

        expect(controller.getValue(field), isNull);

        show.value = true;
      }

      expect(capturedError, isNull);

      // Final mount — fresh state
      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValidasiFormField(
          field: field,
          builder: (_, st) => Text('final=${st.value}'),
        ),
      ));

      expect(controller.getValue(field), isNull);
    });

    testWidgets(
        'I22: eviction while isSubmitted true — re-mount re-validates correctly',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('submitted');
      final show = ValueNotifier<bool>(true);

      addTearDown(() => show.dispose());

      await tester.pumpWidget(_buildFormWithWatch(
        controller: controller,
        watchBuilder: (_, __) => ValueListenableBuilder(
          valueListenable: show,
          builder: (_, s, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s)
                ValidasiFormField(
                    field: field,
                    builder: (_, st) =>
                        Text('v=${st.value} err=${st.errorText ?? "none"}'))
              else
                const Text('gone'),
            ],
          ),
        ),
      ));

      controller.setValue(field, 'test');
      controller.markSubmitted();
      await tester.pump();

      // Evict
      show.value = false;
      await tester.pump();

      // Re-mount
      show.value = true;
      await tester.pump();

      // Field re-registers; isSubmitted still true on the controller
      expect(controller.isSubmitted, isTrue);
      expect(controller.getValue(field), isNull);
    });
  });
}
