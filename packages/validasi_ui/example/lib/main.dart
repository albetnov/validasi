import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'conditional_form_page.dart';
import 'user.dart';
import 'user_summary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validasi UI Example',
      home: const ExampleMenuPage(),
    );
  }
}

class ExampleMenuPage extends StatelessWidget {
  const ExampleMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validasi UI Examples')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('User Form'),
            subtitle: const Text('Basic registration form'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserFormPage()),
            ),
          ),
          ListTile(
            title: const Text('Conditional Form'),
            subtitle: const Text(
              'ValidasiWatch.form as ancestor of ValidasiFormField',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConditionalFormPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class UserFormPage extends StatelessWidget {
  const UserFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Form')),
      body: ValidasiForm(
        schema: UserFields.schema,
        builder: (context, submit) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const UserSummary(),
              const SizedBox(height: 16),
              ValidasiTextField(
                field: UserFields.name,
                builder: (context, state, ctrl) => TextField(
                  controller: ctrl,
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValidasiTextField(
                field: UserFields.email,
                builder: (context, state, ctrl) => TextField(
                  controller: ctrl,
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValidasiTextField(
                field: UserFields.age,
                builder: (context, state, ctrl) => TextField(
                  controller: ctrl,
                  onChanged: (raw) => state.onChanged(int.tryParse(raw)),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit((user) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved: ${user.name}, ${user.email}, ${user.age}',
                      ),
                    ),
                  );
                }),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
