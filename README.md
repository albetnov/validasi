# Validasi

A flexible and easy to use Dart Validation Library.

> Still under development.

API example (subject to change):

```dart
var schema = Validasi.object({
    'name': Validasi.string().required().maxLength(255),
    'address': Validasi.string().required().maxLength(255),
    'email': Validasi.string().email(),
});

var result = schema.tryParse({
    'name': 'Hello World',
    'address': 'Example address',
    'email': 'example@mail.com'
});

print(result.isValid); // true
print(result.messages); // <String>[]
print(result.form); // for usage in Flutter's FormField.

final nameSchema = Validasi.string()
    .required()
    .minLength(3)
    .maxLength(255)

// flutter example
TextFormField(
    decoration: const InputDecoration(
        labelText: 'Name *'
    ),
    validator: (value) => nameSchema.tryParse(value, name: 'name').errors.firstOrNull?.message
);
```

## Quick Usage

> Coming Soon