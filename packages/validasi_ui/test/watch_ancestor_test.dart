import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _RoleKey extends ValidasiField<Map<String, dynamic>, String> {
  const _RoleKey();

  @override
  String get name => 'role';

  @override
  String? extract(Map<String, dynamic> owner) => owner['role'] as String?;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value);

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async =>
      validate(value);
}

class _TokenKey extends ValidasiField<Map<String, dynamic>, String> {
  const _TokenKey();

  @override
  String get name => 'adminToken';

  @override
  String? extract(Map<String, dynamic> owner) => owner['adminToken'] as String?;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value);

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async =>
      validate(value);
}

const _role = _RoleKey();
const _token = _TokenKey();

const _formSchema = _FormSchema();

class _FormSchema extends ValidasiSchema<Map<String, dynamic>> {
  const _FormSchema();

  @override
  Map<String, dynamic> allocate(
    ValidasiFieldReader<Map<String, dynamic>> reader,
  ) =>
      {
        'role': reader.getValue(_role),
        'adminToken': reader.getValue(_token),
      };
}

void main() {
  group('ValidasiWatch.form as ancestor of ValidasiFormField', () {
    testWidgets('builds without setState during build error', (tester) async {
      FlutterError? capturedError;
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        capturedError ??= details.exception is FlutterError
            ? details.exception as FlutterError
            : null;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              schema: _formSchema,
              builder: (context, submit) =>
                  ValidasiWatch.form<Map<String, dynamic>>(
                builder: (context, c) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValidasiFormField(
                      field: _role,
                      builder: (context, state) => Text('role=${state.value}'),
                    ),
                    if (c.getValue(_role) == 'admin')
                      ValidasiFormField(
                        field: _token,
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

      FlutterError.onError = previousErrorHandler;

      expect(capturedError, isNull);
    });

    testWidgets('conditionally shows dependent field based on form state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              schema: _formSchema,
              builder: (context, submit) =>
                  ValidasiWatch.form<Map<String, dynamic>>(
                builder: (context, c) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValidasiFormField(
                      field: _role,
                      builder: (context, state) => GestureDetector(
                        onTap: () => state.onChanged('admin'),
                        child: Text('role=${state.value}'),
                      ),
                    ),
                    if (c.getValue(_role) == 'admin')
                      ValidasiFormField(
                        field: _token,
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

      expect(find.text('role=null'), findsOneWidget);
      expect(find.text('token=null'), findsNothing);

      await tester.tap(find.text('role=null'));
      await tester.pump();

      expect(find.text('role=admin'), findsOneWidget);
      expect(find.text('token=null'), findsOneWidget);
    });
  });

  group('ValidasiWatch.form as sibling of ValidasiFormField', () {
    testWidgets('builds without setState during build error', (tester) async {
      FlutterError? capturedError;
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        capturedError ??= details.exception is FlutterError
            ? details.exception as FlutterError
            : null;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              schema: _formSchema,
              builder: (context, submit) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValidasiWatch.form<Map<String, dynamic>>(
                    builder: (context, c) =>
                        Text('watched=${c.getValue(_role)}'),
                  ),
                  ValidasiFormField(
                    field: _role,
                    builder: (context, state) => Text('role=${state.value}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      FlutterError.onError = previousErrorHandler;

      expect(capturedError, isNull);
    });

    testWidgets('watcher reacts when sibling field changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm(
              schema: _formSchema,
              builder: (context, submit) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValidasiWatch.form<Map<String, dynamic>>(
                    builder: (context, c) =>
                        Text('watched=${c.getValue(_role)}'),
                  ),
                  ValidasiFormField(
                    field: _role,
                    builder: (context, state) => GestureDetector(
                      onTap: () => state.onChanged('admin'),
                      child: Text('role=${state.value}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('watched=null'), findsOneWidget);
      expect(find.text('role=null'), findsOneWidget);

      await tester.tap(find.text('role=null'));
      await tester.pump();

      expect(find.text('watched=admin'), findsOneWidget);
      expect(find.text('role=admin'), findsOneWidget);
    });
  });
}
