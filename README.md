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
print(result.errors); // <FieldError>[]

// flutter example
TextFormField(
    decoration: const InputDecoration(
        labelText: 'Name *'
    ),
    validator: (value) => Form.field(Validasi.string().required().minLength(3).maxLength(255))
        .validate(value, path: 'name')
);
```

## Quick Usage

> Coming Soon