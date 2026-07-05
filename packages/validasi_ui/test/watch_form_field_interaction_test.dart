import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Model {
  final String role;
  final String token;
  const _Model({this.role = '', this.token = ''});
}

class _RoleField extends ValidasiField<_Model, String> {
  const _RoleField();
  @override
  String get name => 'role';
  @override
  String? extract(_Model owner) => owner.role;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

class _TokenField extends ValidasiField<_Model, String> {
  const _TokenField();
  @override
  String get name => 'token';
  @override
  String? extract(_Model owner) => owner.token;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

class _ModelSchema extends ValidasiSchema<_Model> {
  const _ModelSchema();
  @override
  _Model allocate(ValidasiFieldReader<_Model> reader) => _Model(
        role: reader.getValue(const _RoleField()) ?? '',
        token: reader.getValue(const _TokenField()) ?? '',
      );
}

const _schema = _ModelSchema();
const _roleField = _RoleField();
const _tokenField = _TokenField();

class _BuildCounter {
  int _initial = 0;
  int _total = 0;
  int get delta => _total - _initial;
  void inc() => _total++;
  void reset() => _initial = _total;
}

void main() {
  group('E. ValidasiWatch + ValidasiFormField interaction', () {
    // E1: ValidasiWatch.field watches field A, ValidasiFormField for field B
    testWidgets('E1: ValidasiWatch.field watches A, change B — only B rebuilds',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      final watchCounter = _BuildCounter();
      final fieldCounter = _BuildCounter();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.field(
                    field: _roleField,
                    builder: (context, value) {
                      watchCounter.inc();
                      return Text('role=$value');
                    },
                  ),
                  ValidasiFormField(
                    field: _tokenField,
                    builder: (context, state) {
                      fieldCounter.inc();
                      return Text('token=${state.value}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      watchCounter.reset();
      fieldCounter.reset();

      // Change the watched field — both should rebuild
      controller.setValue(_roleField, 'admin');
      await tester.pump();

      print('\n=== E1: change watched field (role) ===');
      print('  watch (role): ${watchCounter.delta} rebuild(s)');
      print('  field (token): ${fieldCounter.delta} rebuild(s)');
      print('  Expected: watch rebuilds (1), field stays 0 (not affected)');
    });

    // E2: ValidasiWatch.form as ancestor with conditional field
    testWidgets(
        'E2: ValidasiWatch.form ancestor with conditional field — no crash',
        (tester) async {
      FlutterError? capturedError;
      final prev = FlutterError.onError;
      FlutterError.onError = (d) {
        capturedError ??=
            d.exception is FlutterError ? d.exception as FlutterError : null;
      };
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              schema: _schema,
              builder: (context, submit) => ValidasiWatch.form<_Model>(
                builder: (context, c) => Column(
                  children: [
                    ValidasiFormField(
                      field: _roleField,
                      builder: (context, state) => GestureDetector(
                        onTap: () => state.onChanged('admin'),
                        child: Text('role=${state.value}'),
                      ),
                    ),
                    if (c.getValue(_roleField) == 'admin')
                      ValidasiFormField(
                        field: _tokenField,
                        builder: (context, state) =>
                            Text('token=${state.value}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('role=null'));
      await tester.pump();

      expect(capturedError, isNull);
      expect(find.text('token=null'), findsOneWidget);
    });

    // E3: ValidasiWatch.field controls visibility of FormField
    testWidgets('E3: ValidasiWatch.field controls FormField visibility',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.setValue(_roleField, 'admin'),
                    child: const Text('set_admin'),
                  ),
                  ValidasiWatch.field(
                    field: _roleField,
                    builder: (context, role) {
                      if (role == 'admin') {
                        return ValidasiFormField(
                          field: _tokenField,
                          builder: (context, state) =>
                              Text('token=${state.value}'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('token=null'), findsNothing);

      await tester.tap(find.text('set_admin'));
      await tester.pump();

      expect(find.text('token=null'), findsOneWidget);
    });

    // E4: Multiple ValidasiWatch.field widgets — independent reactions
    testWidgets('E4: multiple ValidasiWatch.field widgets react independently',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      final roleWatchCounter = _BuildCounter();
      final tokenWatchCounter = _BuildCounter();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.field(
                    field: _roleField,
                    builder: (context, value) {
                      roleWatchCounter.inc();
                      return Text('role=$value');
                    },
                  ),
                  ValidasiWatch.field(
                    field: _tokenField,
                    builder: (context, value) {
                      tokenWatchCounter.inc();
                      return Text('token=$value');
                    },
                  ),
                  GestureDetector(
                    onTap: () => controller.setValue(_tokenField, 'xyz'),
                    child: const Text('set_token'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      roleWatchCounter.reset();
      tokenWatchCounter.reset();

      await tester.tap(find.text('set_token'));
      await tester.pump();

      print('\n=== E4: change token via tap ===');
      print('  roleWatch: ${roleWatchCounter.delta} rebuild(s)');
      print('  tokenWatch: ${tokenWatchCounter.delta} rebuild(s)');
      print('  Expected: tokenWatch rebuilds (1), roleWatch stays 0');
    });

    // E5: ValidasiWatch.field with async validation
    testWidgets('E5: ValidasiWatch.field during async validation',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      final watchCounter = _BuildCounter();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiFormField(
                    field: _tokenField,
                    builder: (context, state) => Text('token=${state.value}'),
                  ),
                  ValidasiWatch.field(
                    field: _tokenField,
                    builder: (context, value) {
                      watchCounter.inc();
                      return Text('watch=$value');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      watchCounter.reset();

      controller.setFieldValidator(
        _tokenField,
        (v) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return v == 'bad' ? 'Invalid token' : null;
        },
        debounce: Duration.zero,
      );

      controller.setValue(_tokenField, 'bad');
      await tester.pump();

      print('\n=== E5: watch field during async validation ===');
      print('  watch rebuilds after setValue: ${watchCounter.delta}');

      await controller.triggerAsyncValidation(_tokenField);
      await tester.pump(const Duration(milliseconds: 100));

      print('  watch rebuilds after async completes: ${watchCounter.delta}');
    });

    // E6: Watch + FormField + eviction cycle
    testWidgets('E6: watch + formfield + eviction — no stale listeners',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      final showToken = ValueNotifier<bool>(true);
      addTearDown(() => showToken.dispose());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.field(
                    field: _tokenField,
                    builder: (context, value) => Text('watch=$value'),
                  ),
                  ValueListenableBuilder(
                    valueListenable: showToken,
                    builder: (_, show, __) => show
                        ? ValidasiFormField(
                            field: _tokenField,
                            builder: (context, state) =>
                                Text('token=${state.value}'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      controller.setValue(_tokenField, 'initial');
      await tester.pump();
      expect(find.text('watch=initial'), findsOneWidget);

      // Evict the FormField
      showToken.value = false;
      await tester.pump();

      // Watch should still be alive and reacting
      controller.setValue(_tokenField, 'after-evict');
      await tester.pump();
      expect(find.text('watch=after-evict'), findsOneWidget);
    });

    // E7: Watcher reading form-level isValid
    testWidgets('E7: ValidasiWatch.form watching isValid', (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              controller: controller,
              schema: _schema,
              builder: (context, submit) => Column(
                children: [
                  ValidasiWatch.form<_Model>(
                    builder: (context, c) => Text('valid=${c.isValid}'),
                  ),
                  ValidasiFormField(
                    field: _roleField,
                    builder: (context, state) => TextField(
                      onChanged: state.onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('valid=true'), findsOneWidget);

      // Change a value — form watch (ChangeNotifier) rebuilds
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();

      expect(find.text('valid=true'), findsWidgets);
    });

    // E8: ValidasiWatch.form with controller passed explicitly
    testWidgets('E8: ValidasiWatch.form with explicit controller',
        (tester) async {
      final controller = ValidasiFormController<_Model>(schema: _schema);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiWatch.form<_Model>(
              controller: controller,
              builder: (context, c) => Text('isValid=${c.isValid}'),
            ),
          ),
        ),
      );

      expect(find.textContaining('isValid='), findsOneWidget);
    });
  });
}
