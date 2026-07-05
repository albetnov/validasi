import 'package:flutter/material.dart';
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

class ConditionalFormPage extends StatelessWidget {
  const ConditionalFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditional Form')),
      body: ValidasiForm(
        schema: _formSchema,
        builder: (context, submit) => ValidasiWatch.form<Map<String, dynamic>>(
          builder: (context, controller) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Role:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        final next = controller.getValue(_role) == 'admin'
                            ? 'user'
                            : 'admin';
                        controller.setValue(_role, next);
                      },
                      child: Text(controller.getValue(_role) ?? 'user'),
                    ),
                  ],
                ),
                if (controller.getValue(_role) == 'admin')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ValidasiFormField(
                      field: _token,
                      builder: (context, state) => TextFormField(
                        onChanged: state.onChanged,
                        decoration: const InputDecoration(
                          labelText: 'Admin Token',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: submit((result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved: $result')),
                    );
                  }),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
