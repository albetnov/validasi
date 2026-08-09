import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'user.dart';

class UserSummary extends StatelessWidget {
  const UserSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return ValidasiWatch.form<User>(
      builder: (context, controller) {
        final preview = controller.watch<String, String>(
          [UserFields.name_, UserFields.email],
          (values) {
            final name = values[UserFields.name_] ?? '?';
            final email = values[UserFields.email] ?? '?';
            return '$name <$email>';
          },
        );

        final nameSignal = controller.watchValue(UserFields.name_);
        final emailSignal = controller.watchValue(UserFields.email);
        final ageSignal = controller.watchValue(UserFields.age);
        final isReady = nameSignal.value != null &&
            emailSignal.value != null &&
            ageSignal.value != null;

        return Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live preview',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(preview.value,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isReady
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isReady
                          ? Colors.green
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isReady
                          ? 'Ready to submit'
                          : 'Fill in all fields to continue',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
