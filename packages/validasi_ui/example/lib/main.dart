import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'user.dart';

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
      body: ValidasiForm<User>(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValidasiFormField<User, String>(
                field: UserFields.name,
                builder: (context, state) => TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValidasiFormField<User, String>(
                field: UserFields.email,
                builder: (context, state) => TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValidasiFormField<User, int>(
                field: UserFields.age,
                builder: (context, state) => TextField(
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
                onPressed: () {
                  final controller = ValidasiForm.of<User>(context);
                  if (!controller.validate()) return;

                  final user = User(
                    name: controller.getValue(UserFields.name)!,
                    email: controller.getValue(UserFields.email)!,
                    age: controller.getValue(UserFields.age)!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved: ${user.name}, ${user.email}, ${user.age}',
                      ),
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
