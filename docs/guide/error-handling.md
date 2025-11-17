# Error Handling

Proper error handling is crucial for providing good user feedback and debugging validation issues. This guide covers how to work with validation errors in Validasi.

## Understanding ValidasiResult

Every validation returns a `ValidasiResult<T>` object:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final schema = Validasi.string([
  StringRules.minLength(3),
]);

final result = schema.validate('Hi');
```

The `ValidasiResult` contains:
- **`isValid: bool`** - Whether validation succeeded
- **`data: T`** - The validated (possibly transformed) data
- **`errors: List<ValidasiError>`** - List of validation errors

## Checking Validation Status

### Basic Check

```dart
final result = schema.validate(data);

if (result.isValid) {
  print('✓ Valid data: ${result.data}');
} else {
  print('✗ Validation failed');
  for (var error in result.errors) {
    print('  - ${error.message}');
  }
}
```

### Using Pattern Matching

```dart
final result = schema.validate(data);

switch (result.isValid) {
  case true:
    // Handle success
    processData(result.data);
    break;
  case false:
    // Handle errors
    showErrors(result.errors);
    break;
}
```

## Working with ValidasiError

Each `ValidasiError` contains:

- **`message: String`** - The error message
- **`path: List<String>?`** - Path to the failed field (for nested structures)

### Simple Error Messages

```dart
final nameSchema = Validasi.string([
  StringRules.minLength(3, message: 'Name is too short'),
  StringRules.maxLength(50, message: 'Name is too long'),
]);

final result = nameSchema.validate('Hi');

if (!result.isValid) {
  for (var error in result.errors) {
    print(error.message); // "Name is too short"
  }
}
```

### Error Paths for Nested Data

Error paths help identify exactly where validation failed in nested structures:

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'profile': Validasi.map<dynamic>([
      MapRules.hasFields({
        'name': Validasi.string([
          StringRules.minLength(1, message: 'Name is required'),
        ]),
        'age': Validasi.number<int>([
          NumberRules.moreThanEqual(0, message: 'Age must be positive'),
        ]),
      }),
    ]),
  }),
]);

final result = userSchema.validate({
  'profile': {
    'name': '',
    'age': -5,
  },
});

for (var error in result.errors) {
  final path = error.path?.join('.') ?? 'root';
  print('[$path] ${error.message}');
}

// Output:
// [profile.name] Name is required
// [profile.age] Age must be positive
```

## Custom Error Messages

### Built-in Rules

Most rules accept a custom message:

```dart
final passwordSchema = Validasi.string([
  StringRules.minLength(8, 
    message: 'Password must be at least 8 characters'),
  StringRules.maxLength(128,
    message: 'Password is too long (max 128 characters)'),
]);
```

### InlineRule

Create custom errors with `InlineRule`:

```dart
final schema = Validasi.string([
  InlineRule<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    return null; // null means valid
  }),
]);
```

### Multiple Error Messages

InlineRule returns the first error encountered:

```dart
final emailSchema = Validasi.string([
  InlineRule<String>((value) {
    if (!value.contains('@')) {
      return 'Email must contain @';
    }
    if (!value.contains('.')) {
      return 'Email must contain a domain';
    }
    if (value.length < 5) {
      return 'Email is too short';
    }
    return null;
  }),
]);
```

## Collecting All Errors

By default, validation returns all errors:

```dart
final schema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
    ]),
    'email': Validasi.string([
      StringRules.minLength(5),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(0),
    ]),
  }),
]);

final result = schema.validate({
  'name': '',      // Error
  'email': 'ab',   // Error
  'age': -5,       // Error
});

print('Total errors: ${result.errors.length}'); // 3
```

## Formatting Error Messages

### Simple List

```dart
void displayErrors(ValidasiResult result) {
  if (!result.isValid) {
    print('Validation failed:');
    for (var error in result.errors) {
      print('• ${error.message}');
    }
  }
}
```

### With Paths

```dart
void displayErrorsWithPath(ValidasiResult result) {
  if (!result.isValid) {
    print('Validation errors:');
    for (var error in result.errors) {
      final location = error.path?.join('.') ?? 'root';
      print('[$location]: ${error.message}');
    }
  }
}
```

### For UI Display

```dart
Map<String, List<String>> groupErrorsByField(ValidasiResult result) {
  final grouped = <String, List<String>>{};
  
  for (var error in result.errors) {
    final field = error.path?.last ?? 'root';
    grouped.putIfAbsent(field, () => []).add(error.message);
  }
  
  return grouped;
}

// Usage
final errors = groupErrorsByField(result);
errors.forEach((field, messages) {
  print('$field:');
  for (var message in messages) {
    print('  - $message');
  }
});
```

### JSON Format

```dart
List<Map<String, dynamic>> errorsToJson(ValidasiResult result) {
  return result.errors.map((error) => {
    'field': error.path?.join('.'),
    'message': error.message,
  }).toList();
}

// Usage
final jsonErrors = errorsToJson(result);
print(jsonEncode(jsonErrors));
// [{"field":"profile.name","message":"Name is required"}]
```

## Error Handling Patterns

### Early Return Pattern

```dart
Future<void> saveUser(Map<String, dynamic> userData) async {
  final result = userSchema.validate(userData);
  
  if (!result.isValid) {
    throw ValidationException(result.errors);
  }
  
  await database.save(result.data);
}
```

### Result Pattern

```dart
class SaveResult {
  final bool success;
  final String? error;
  final User? user;
  
  SaveResult.success(this.user) : success = true, error = null;
  SaveResult.failure(this.error) : success = false, user = null;
}

Future<SaveResult> saveUser(Map<String, dynamic> userData) async {
  final result = userSchema.validate(userData);
  
  if (!result.isValid) {
    final errorMsg = result.errors
      .map((e) => e.message)
      .join(', ');
    return SaveResult.failure(errorMsg);
  }
  
  final user = await database.save(result.data);
  return SaveResult.success(user);
}
```

### Exception Wrapper

```dart
class ValidationException implements Exception {
  final List<ValidasiError> errors;
  
  ValidationException(this.errors);
  
  @override
  String toString() {
    return 'ValidationException: ${errors.map((e) => e.message).join(', ')}';
  }
}

void processData(dynamic data) {
  final result = schema.validate(data);
  
  if (!result.isValid) {
    throw ValidationException(result.errors);
  }
  
  // Continue with valid data
  print('Processing: ${result.data}');
}
```

## Flutter Integration

### Form Validation

```dart
class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _emailSchema = Validasi.string([
    Transform((value) => value?.trim().toLowerCase()),
    StringRules.minLength(5),
  ]);
  
  final _passwordSchema = Validasi.string([
    StringRules.minLength(8),
  ]);
  
  String? _validateEmail(String? value) {
    final result = _emailSchema.validate(value);
    return result.isValid ? null : result.errors.first.message;
  }
  
  String? _validatePassword(String? value) {
    final result = _passwordSchema.validate(value);
    return result.isValid ? null : result.errors.first.message;
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: _validateEmail,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: _validatePassword,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form is valid
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Showing Multiple Errors

```dart
Widget buildErrorList(List<ValidasiError> errors) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: errors.map((error) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
```

## Best Practices

### 1. Provide Clear Messages

```dart
// Good ✓
StringRules.minLength(8, 
  message: 'Password must be at least 8 characters')

// Less helpful ✗
StringRules.minLength(8, message: 'Invalid')
```

### 2. Be Specific

```dart
// Good ✓
InlineRule<String>((value) {
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Must contain at least one uppercase letter';
  }
  return null;
})

// Vague ✗
InlineRule<String>((value) {
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Invalid password';
  }
  return null;
})
```

### 3. Handle All Error Cases

```dart
final result = schema.validate(data);

if (result.isValid) {
  // Success path
  processData(result.data);
} else {
  // Error path - don't ignore!
  logErrors(result.errors);
  notifyUser(result.errors);
}
```

### 4. Group Related Errors

```dart
Map<String, List<String>> groupBySection(List<ValidasiError> errors) {
  final groups = <String, List<String>>{};
  
  for (var error in errors) {
    final section = error.path?.first ?? 'general';
    groups.putIfAbsent(section, () => []).add(error.message);
  }
  
  return groups;
}
```

## Next Steps

- [Examples](/examples/string-validation) - See practical examples
- [Advanced](/advanced/custom-rule) - Create custom validation rules
- [API Reference](https://pub.dev/documentation/validasi/latest) - Full API documentation

<div style="margin-top: 3rem;">
  <a href="/examples/string-validation" class="vp-button vp-button-brand">See Examples →</a>
</div>
