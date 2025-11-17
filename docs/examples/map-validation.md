# Map Validation Examples

Learn how to validate maps and objects with Validasi's map validation rules.

## Basic Map Validation

### Simple Object Validation

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
    ]),
    'age': Validasi.number<int>([
      NumberRules.moreThanEqual(0),
    ]),
  }),
]);

// Valid
final validUser = {'name': 'John', 'age': 30};
print(userSchema.validate(validUser).isValid); // true

// Invalid
final invalidUser = {'name': '', 'age': -1};
final result = userSchema.validate(invalidUser);
print(result.isValid); // false
for (var error in result.errors) {
  print('[${error.path?.join('.')}] ${error.message}');
}
```

### Required Keys Validation

```dart
final configSchema = Validasi.map<dynamic>([
  MapRules.hasFieldKeys({'api_key', 'endpoint', 'timeout'}),
]);

// Valid
print(configSchema.validate({
  'api_key': 'abc123',
  'endpoint': 'https://api.example.com',
  'timeout': 30,
  'extra': 'allowed', // Extra fields are OK
}).isValid); // true

// Invalid - missing keys
print(configSchema.validate({
  'api_key': 'abc123',
}).isValid); // false
```

## Nested Map Validation

### One Level Nesting

```dart
final profileSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'user': Validasi.map<dynamic>([
      MapRules.hasFields({
        'name': Validasi.string([StringRules.minLength(1)]),
        'email': Validasi.string([StringRules.minLength(5)]),
      }),
    ]),
    'settings': Validasi.map<dynamic>([
      MapRules.hasFields({
        'theme': Validasi.string([
          StringRules.oneOf(['light', 'dark', 'auto']),
        ]),
        'notifications': Validasi.any<bool>(),
      }),
    ]),
  }),
]);

final profile = {
  'user': {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  'settings': {
    'theme': 'dark',
    'notifications': true,
  },
};

print(profileSchema.validate(profile).isValid); // true
```

### Deep Nesting

```dart
final addressSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'street': Validasi.string([StringRules.minLength(1)]),
    'city': Validasi.string([StringRules.minLength(1)]),
    'country': Validasi.string([StringRules.minLength(1)]),
    'coordinates': Validasi.map<dynamic>([
      MapRules.hasFields({
        'lat': Validasi.number<double>([
          NumberRules.moreThanEqual(-90.0),
          NumberRules.lessThanEqual(90.0),
        ]),
        'lng': Validasi.number<double>([
          NumberRules.moreThanEqual(-180.0),
          NumberRules.lessThanEqual(180.0),
        ]),
      }),
    ]),
  }),
]);

final address = {
  'street': '123 Main St',
  'city': 'San Francisco',
  'country': 'USA',
  'coordinates': {
    'lat': 37.7749,
    'lng': -122.4194,
  },
};

print(addressSchema.validate(address).isValid); // true
```

## Conditional Field Validation

### Basic Conditional Validation

```dart
final orderSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'is_delivery': Validasi.any<bool>(),
    'address': Validasi.string([
      Nullable(),
      StringRules.minLength(10),
    ]),
  }),
  MapRules.conditionalField('address', (context, value) {
    if (context.get('is_delivery') == true && value == null) {
      return 'Address is required for delivery orders';
    }
    return null;
  }),
]);

// Valid - delivery with address
print(orderSchema.validate({
  'is_delivery': true,
  'address': '123 Main Street, City',
}).isValid); // true

// Valid - pickup without address
print(orderSchema.validate({
  'is_delivery': false,
  'address': null,
}).isValid); // true

// Invalid - delivery without address
print(orderSchema.validate({
  'is_delivery': true,
  'address': null,
}).isValid); // false
```

### Multiple Conditional Fields

```dart
final paymentSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'payment_method': Validasi.string([
      StringRules.oneOf(['card', 'bank', 'cash']),
    ]),
    'card_number': Validasi.string([Nullable()]),
    'bank_account': Validasi.string([Nullable()]),
  }),
  MapRules.conditionalField('card_number', (context, value) {
    if (context.get('payment_method') == 'card' && value == null) {
      return 'Card number is required for card payments';
    }
    return null;
  }),
  MapRules.conditionalField('bank_account', (context, value) {
    if (context.get('payment_method') == 'bank' && value == null) {
      return 'Bank account is required for bank transfers';
    }
    return null;
  }),
]);

// Valid - card payment with card number
print(paymentSchema.validate({
  'payment_method': 'card',
  'card_number': '4111111111111111',
  'bank_account': null,
}).isValid); // true

// Valid - cash payment
print(paymentSchema.validate({
  'payment_method': 'cash',
  'card_number': null,
  'bank_account': null,
}).isValid); // true

// Invalid - card payment without card number
print(paymentSchema.validate({
  'payment_method': 'card',
  'card_number': null,
  'bank_account': null,
}).isValid); // false
```

## Optional Fields

### Nullable Fields

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([StringRules.minLength(1)]),
    'nickname': Validasi.string([
      Nullable(),
      StringRules.minLength(2),
    ]),
    'age': Validasi.number<int>([
      Nullable(),
      NumberRules.moreThanEqual(0),
    ]),
  }),
]);

// Valid with nulls
print(userSchema.validate({
  'name': 'John Doe',
  'nickname': null,
  'age': null,
}).isValid); // true

// Valid with values
print(userSchema.validate({
  'name': 'John Doe',
  'nickname': 'JD',
  'age': 30,
}).isValid); // true
```

## Map Transformations

### Transform Field Values

```dart
final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'email': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(5),
    ]),
    'name': Validasi.string([
      Transform((value) => value?.trim()),
      Transform((value) {
        // Capitalize first letter of each word
        return value?.split(' ')
          .map((word) => word.isEmpty ? '' : 
            word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
      }),
    ]),
  }),
]);

final result = userSchema.validate({
  'email': '  USER@EXAMPLE.COM  ',
  'name': 'john doe',
});

print(result.data);
// {
//   email: 'user@example.com',
//   name: 'John Doe'
// }
```

## Real-World Examples

### Registration Form

```dart
final registrationSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'username': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(3),
      StringRules.maxLength(20),
      InlineRule<String>((value) {
        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
          return 'Username can only contain letters, numbers, and underscores';
        }
        return null;
      }),
    ]),
    'email': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      StringRules.minLength(5),
      InlineRule<String>((value) {
        if (!value.contains('@')) {
          return 'Invalid email format';
        }
        return null;
      }),
    ]),
    'password': Validasi.string([
      StringRules.minLength(8),
      InlineRule<String>((value) {
        if (!value.contains(RegExp(r'[A-Z]'))) {
          return 'Password must contain uppercase letter';
        }
        if (!value.contains(RegExp(r'[0-9]'))) {
          return 'Password must contain number';
        }
        return null;
      }),
    ]),
    'age': Validasi.number<int>([
      Nullable(),
      NumberRules.moreThanEqual(13),
    ]),
    'terms': Validasi.any<bool>([
      InlineRule<bool>((value) {
        return value == true ? null : 'You must accept the terms';
      }),
    ]),
  }),
]);

final formData = {
  'username': 'JohnDoe123',
  'email': 'JOHN@EXAMPLE.COM',
  'password': 'SecurePass123',
  'age': 25,
  'terms': true,
};

final result = registrationSchema.validate(formData);
print('Valid: ${result.isValid}');
print('Processed data: ${result.data}');
```

### API Request Validation

```dart
final apiRequestSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'endpoint': Validasi.string([
      StringRules.minLength(1),
    ]),
    'method': Validasi.string([
      StringRules.oneOf(['GET', 'POST', 'PUT', 'DELETE', 'PATCH']),
    ]),
    'headers': Validasi.map<dynamic>([
      Nullable(),
    ]),
    'body': Validasi.any<dynamic>([
      Nullable(),
    ]),
    'timeout': Validasi.number<int>([
      Nullable(),
      NumberRules.moreThan(0),
      NumberRules.lessThanEqual(300),
    ]),
  }),
]);

final request = {
  'endpoint': '/api/users',
  'method': 'POST',
  'headers': {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token123',
  },
  'body': {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  'timeout': 30,
};

print(apiRequestSchema.validate(request).isValid); // true
```

### Product Validation

```dart
final productSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': Validasi.string([
      StringRules.minLength(1),
      StringRules.maxLength(100),
    ]),
    'description': Validasi.string([
      StringRules.minLength(10),
      StringRules.maxLength(500),
    ]),
    'price': Validasi.number<double>([
      NumberRules.moreThan(0.0),
    ]),
    'stock': Validasi.number<int>([
      NumberRules.moreThanEqual(0),
    ]),
    'category': Validasi.string([
      StringRules.oneOf(['electronics', 'clothing', 'books', 'food']),
    ]),
    'tags': Validasi.list<String>([
      IterableRules.minLength(1),
      IterableRules.forEach(
        Validasi.string([StringRules.minLength(2)]),
      ),
    ]),
    'on_sale': Validasi.any<bool>(),
    'discount': Validasi.number<double>([
      Nullable(),
      NumberRules.moreThanEqual(0.0),
      NumberRules.lessThan(100.0),
    ]),
  }),
  MapRules.conditionalField('discount', (context, value) {
    if (context.get('on_sale') == true && value == null) {
      return 'Discount is required when product is on sale';
    }
    return null;
  }),
]);

final product = {
  'name': 'Wireless Headphones',
  'description': 'High-quality wireless headphones with noise cancellation',
  'price': 99.99,
  'stock': 50,
  'category': 'electronics',
  'tags': ['audio', 'wireless', 'bluetooth'],
  'on_sale': true,
  'discount': 15.0,
};

print(productSchema.validate(product).isValid); // true
```

### Blog Post Validation

```dart
final blogPostSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'title': Validasi.string([
      StringRules.minLength(5),
      StringRules.maxLength(200),
    ]),
    'slug': Validasi.string([
      Transform((value) => value?.trim().toLowerCase()),
      Transform((value) => value?.replaceAll(RegExp(r'\s+'), '-')),
      StringRules.minLength(5),
      InlineRule<String>((value) {
        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
          return 'Slug can only contain lowercase letters, numbers, and hyphens';
        }
        return null;
      }),
    ]),
    'content': Validasi.string([
      StringRules.minLength(100),
    ]),
    'author': Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([NumberRules.moreThan(0)]),
        'name': Validasi.string([StringRules.minLength(1)]),
      }),
    ]),
    'tags': Validasi.list<String>([
      IterableRules.minLength(1),
      IterableRules.forEach(
        Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
          StringRules.minLength(2),
        ]),
      ),
    ]),
    'published': Validasi.any<bool>(),
    'published_at': Validasi.string([
      Nullable(),
    ]),
  }),
  MapRules.conditionalField('published_at', (context, value) {
    if (context.get('published') == true && value == null) {
      return 'Published date is required when post is published';
    }
    return null;
  }),
]);

final blogPost = {
  'title': 'Getting Started with Flutter',
  'slug': 'Getting Started With Flutter',
  'content': 'Flutter is an amazing framework...' + ('.' * 100),
  'author': {
    'id': 123,
    'name': 'John Doe',
  },
  'tags': ['Flutter', 'Mobile', 'Development'],
  'published': true,
  'published_at': '2024-01-15T10:00:00Z',
};

final result = blogPostSchema.validate(blogPost);
print('Valid: ${result.isValid}');
print('Slug: ${result.data['slug']}'); // 'getting-started-with-flutter'
```

### Settings Validation

```dart
final settingsSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'appearance': Validasi.map<dynamic>([
      MapRules.hasFields({
        'theme': Validasi.string([
          StringRules.oneOf(['light', 'dark', 'auto']),
        ]),
        'font_size': Validasi.number<int>([
          NumberRules.moreThanEqual(8),
          NumberRules.lessThanEqual(32),
        ]),
      }),
    ]),
    'notifications': Validasi.map<dynamic>([
      MapRules.hasFields({
        'email': Validasi.any<bool>(),
        'push': Validasi.any<bool>(),
        'sms': Validasi.any<bool>(),
      }),
    ]),
    'privacy': Validasi.map<dynamic>([
      MapRules.hasFields({
        'profile_visible': Validasi.any<bool>(),
        'show_email': Validasi.any<bool>(),
      }),
    ]),
  }),
]);

final settings = {
  'appearance': {
    'theme': 'dark',
    'font_size': 14,
  },
  'notifications': {
    'email': true,
    'push': true,
    'sms': false,
  },
  'privacy': {
    'profile_visible': true,
    'show_email': false,
  },
};

print(settingsSchema.validate(settings).isValid); // true
```

## Custom Map Validation

### Cross-Field Validation

```dart
final passwordMatchSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'password': Validasi.string([StringRules.minLength(8)]),
    'confirm_password': Validasi.string([StringRules.minLength(8)]),
  }),
  Having((context, value) {
    if (value is Map && value['password'] != value['confirm_password']) {
      return 'Passwords do not match';
    }
    return null;
  }),
]);

// Valid
print(passwordMatchSchema.validate({
  'password': 'SecurePass123',
  'confirm_password': 'SecurePass123',
}).isValid); // true

// Invalid
print(passwordMatchSchema.validate({
  'password': 'SecurePass123',
  'confirm_password': 'DifferentPass',
}).isValid); // false
```

### Date Range Validation

```dart
final dateRangeSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'start_date': Validasi.string([StringRules.minLength(1)]),
    'end_date': Validasi.string([StringRules.minLength(1)]),
  }),
  Having((context, value) {
    if (value is Map) {
      final start = DateTime.tryParse(value['start_date'] ?? '');
      final end = DateTime.tryParse(value['end_date'] ?? '');
      
      if (start != null && end != null && end.isBefore(start)) {
        return 'End date must be after start date';
      }
    }
    return null;
  }),
]);
```

## Error Handling in Maps

```dart
final schema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'user': Validasi.map<dynamic>([
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

final result = schema.validate({
  'user': {
    'name': '',
    'age': -5,
  },
});

for (var error in result.errors) {
  print('[${error.path?.join('.')}] ${error.message}');
}
// Output:
// [user.name] Name is required
// [user.age] Age must be positive
```

## Next Steps

- [Complex Structures](/examples/complex-structures)
- [Map Rules Reference](/guide/map-rules)
- [Transformations Guide](/guide/transformations)
