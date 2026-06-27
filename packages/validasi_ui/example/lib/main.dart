import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
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
      home: const UserFormPage(),
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
              ValidasiTextFormField(
                field: UserFields.name,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 16),
              ValidasiTextFormField(
                field: UserFields.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),
              ValidasiParsedTextFormField(
                field: UserFields.age,
                parser: int.tryParse,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
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
