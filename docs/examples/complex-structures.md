# Complex Structures Examples

Learn how to validate complex, nested data structures by combining Validasi's schema types.

## E-Commerce Examples

### Shopping Cart

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final cartSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'user_id': Validasi.number<int>([
      NumberRules.moreThan(0),
    ]),
    'items': Validasi.list<Map<String, dynamic>>([
      IterableRules.minLength(1, message: 'Cart cannot be empty'),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'product_id': Validasi.number<int>([
              NumberRules.moreThan(0),
            ]),
            'name': Validasi.string([
              StringRules.minLength(1),
            ]),
            'price': Validasi.number<double>([
              NumberRules.moreThan(0.0),
            ]),
            'quantity': Validasi.number<int>([
              NumberRules.moreThan(0),
              NumberRules.lessThanEqual(99),
            ]),
          }),
        ]),
      ),
    ]),
    'shipping': Validasi.map<dynamic>([
      MapRules.hasFields({
        'address': Validasi.string([StringRules.minLength(10)]),
        'city': Validasi.string([StringRules.minLength(2)]),
        'postal_code': Validasi.string([StringRules.minLength(3)]),
        'country': Validasi.string([StringRules.minLength(2)]),
      }),
    ]),
    'payment_method': Validasi.string([
      StringRules.oneOf(['card', 'paypal', 'bank_transfer']),
    ]),
  }),
]);

final cart = {
  'user_id': 123,
  'items': [
    {
      'product_id': 1,
      'name': 'Wireless Mouse',
      'price': 29.99,
      'quantity': 2,
    },
    {
      'product_id': 2,
      'name': 'USB Cable',
      'price': 9.99,
      'quantity': 3,
    },
  ],
  'shipping': {
    'address': '123 Main Street, Apt 4B',
    'city': 'San Francisco',
    'postal_code': '94102',
    'country': 'USA',
  },
  'payment_method': 'card',
};

final result = cartSchema.validate(cart);
print('Valid: ${result.isValid}');
```

### Product Catalog

```dart
final catalogSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'categories': Validasi.list<Map<String, dynamic>>([
      IterableRules.minLength(1),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'id': Validasi.number<int>([NumberRules.moreThan(0)]),
            'name': Validasi.string([StringRules.minLength(1)]),
            'slug': Validasi.string([
              Transform((value) => value?.toLowerCase().replaceAll(' ', '-')),
            ]),
            'products': Validasi.list<Map<String, dynamic>>([
              IterableRules.forEach(
                Validasi.map<dynamic>([
                  MapRules.hasFields({
                    'id': Validasi.number<int>([NumberRules.moreThan(0)]),
                    'name': Validasi.string([StringRules.minLength(1)]),
                    'price': Validasi.number<double>([NumberRules.moreThan(0)]),
                    'in_stock': Validasi.any<bool>(),
                    'images': Validasi.list<String>([
                      IterableRules.minLength(1),
                    ]),
                    'variants': Validasi.list<Map<String, dynamic>>([
                      Nullable(),
                      IterableRules.forEach(
                        Validasi.map<dynamic>([
                          MapRules.hasFields({
                            'size': Validasi.string([Nullable()]),
                            'color': Validasi.string([Nullable()]),
                            'price_modifier': Validasi.number<double>([
                              Nullable(),
                            ]),
                          }),
                        ]),
                      ),
                    ]),
                  }),
                ]),
              ),
            ]),
          }),
        ]),
      ),
    ]),
  }),
]);

final catalog = {
  'categories': [
    {
      'id': 1,
      'name': 'Electronics',
      'slug': 'electronics',
      'products': [
        {
          'id': 101,
          'name': 'Wireless Headphones',
          'price': 99.99,
          'in_stock': true,
          'images': ['img1.jpg', 'img2.jpg'],
          'variants': [
            {'size': null, 'color': 'black', 'price_modifier': 0.0},
            {'size': null, 'color': 'white', 'price_modifier': 5.0},
          ],
        },
      ],
    },
  ],
};

print(catalogSchema.validate(catalog).isValid);
```

## Social Media Examples

### User Profile

```dart
final profileSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'user': Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([NumberRules.moreThan(0)]),
        'username': Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
          StringRules.minLength(3),
          StringRules.maxLength(20),
        ]),
        'email': Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
          InlineRule<String>((value) {
            return value.contains('@') ? null : 'Invalid email';
          }),
        ]),
        'bio': Validasi.string([
          Nullable(),
          StringRules.maxLength(500),
        ]),
        'avatar_url': Validasi.string([Nullable()]),
      }),
    ]),
    'stats': Validasi.map<dynamic>([
      MapRules.hasFields({
        'followers': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
        'following': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
        'posts': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
      }),
    ]),
    'recent_posts': Validasi.list<Map<String, dynamic>>([
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'id': Validasi.number<int>([NumberRules.moreThan(0)]),
            'content': Validasi.string([
              StringRules.minLength(1),
              StringRules.maxLength(280),
            ]),
            'likes': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
            'comments': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
            'created_at': Validasi.string([StringRules.minLength(1)]),
            'media': Validasi.list<Map<String, dynamic>>([
              Nullable(),
              IterableRules.forEach(
                Validasi.map<dynamic>([
                  MapRules.hasFields({
                    'type': Validasi.string([
                      StringRules.oneOf(['image', 'video', 'gif']),
                    ]),
                    'url': Validasi.string([StringRules.minLength(1)]),
                  }),
                ]),
              ),
            ]),
          }),
        ]),
      ),
    ]),
  }),
]);

final profile = {
  'user': {
    'id': 12345,
    'username': 'JohnDoe',
    'email': 'JOHN@EXAMPLE.COM',
    'bio': 'Software developer and coffee enthusiast',
    'avatar_url': 'https://example.com/avatar.jpg',
  },
  'stats': {
    'followers': 1234,
    'following': 567,
    'posts': 89,
  },
  'recent_posts': [
    {
      'id': 1,
      'content': 'Just shipped a new feature! 🚀',
      'likes': 42,
      'comments': 5,
      'created_at': '2024-01-15T10:00:00Z',
      'media': [
        {
          'type': 'image',
          'url': 'https://example.com/post1.jpg',
        },
      ],
    },
  ],
};

final result = profileSchema.validate(profile);
print('Valid: ${result.isValid}');
print('Username: ${result.data['user']['username']}'); // 'johndoe'
```

### Comment Thread

```dart
final commentSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'id': Validasi.number<int>([NumberRules.moreThan(0)]),
    'author': Validasi.string([StringRules.minLength(1)]),
    'content': Validasi.string([
      StringRules.minLength(1),
      StringRules.maxLength(1000),
    ]),
    'created_at': Validasi.string([StringRules.minLength(1)]),
    'likes': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
    'replies': Validasi.list<Map<String, dynamic>>([
      Nullable(),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'id': Validasi.number<int>([NumberRules.moreThan(0)]),
            'author': Validasi.string([StringRules.minLength(1)]),
            'content': Validasi.string([
              StringRules.minLength(1),
              StringRules.maxLength(500),
            ]),
            'created_at': Validasi.string([StringRules.minLength(1)]),
            'likes': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
          }),
        ]),
      ),
    ]),
  }),
]);

final thread = {
  'id': 1,
  'author': 'Alice',
  'content': 'Great article! Thanks for sharing.',
  'created_at': '2024-01-15T10:00:00Z',
  'likes': 15,
  'replies': [
    {
      'id': 2,
      'author': 'Bob',
      'content': 'I agree! Very helpful.',
      'created_at': '2024-01-15T10:30:00Z',
      'likes': 5,
    },
  ],
};

print(commentSchema.validate(thread).isValid);
```

## API Response Validation

### Paginated API Response

```dart
final paginatedResponseSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'data': Validasi.list<Map<String, dynamic>>([
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'id': Validasi.number<int>([NumberRules.moreThan(0)]),
            'title': Validasi.string([StringRules.minLength(1)]),
            'description': Validasi.string([Nullable()]),
            'created_at': Validasi.string([StringRules.minLength(1)]),
          }),
        ]),
      ),
    ]),
    'pagination': Validasi.map<dynamic>([
      MapRules.hasFields({
        'page': Validasi.number<int>([NumberRules.moreThan(0)]),
        'per_page': Validasi.number<int>([
          NumberRules.moreThan(0),
          NumberRules.lessThanEqual(100),
        ]),
        'total': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
        'total_pages': Validasi.number<int>([NumberRules.moreThanEqual(0)]),
      }),
    ]),
    'links': Validasi.map<dynamic>([
      MapRules.hasFields({
        'first': Validasi.string([Nullable()]),
        'last': Validasi.string([Nullable()]),
        'prev': Validasi.string([Nullable()]),
        'next': Validasi.string([Nullable()]),
      }),
    ]),
  }),
]);

final apiResponse = {
  'data': [
    {
      'id': 1,
      'title': 'First Item',
      'description': 'Description here',
      'created_at': '2024-01-15T10:00:00Z',
    },
  ],
  'pagination': {
    'page': 1,
    'per_page': 20,
    'total': 100,
    'total_pages': 5,
  },
  'links': {
    'first': 'https://api.example.com/items?page=1',
    'last': 'https://api.example.com/items?page=5',
    'prev': null,
    'next': 'https://api.example.com/items?page=2',
  },
};

print(paginatedResponseSchema.validate(apiResponse).isValid);
```

### Error Response

```dart
final errorResponseSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'error': Validasi.map<dynamic>([
      MapRules.hasFields({
        'code': Validasi.string([StringRules.minLength(1)]),
        'message': Validasi.string([StringRules.minLength(1)]),
        'details': Validasi.list<Map<String, dynamic>>([
          Nullable(),
          IterableRules.forEach(
            Validasi.map<dynamic>([
              MapRules.hasFields({
                'field': Validasi.string([StringRules.minLength(1)]),
                'error': Validasi.string([StringRules.minLength(1)]),
              }),
            ]),
          ),
        ]),
      }),
    ]),
    'status': Validasi.number<int>([
      NumberRules.moreThanEqual(400),
      NumberRules.lessThan(600),
    ]),
  }),
]);

final errorResponse = {
  'error': {
    'code': 'VALIDATION_ERROR',
    'message': 'The request contains invalid data',
    'details': [
      {'field': 'email', 'error': 'Invalid email format'},
      {'field': 'age', 'error': 'Must be at least 18'},
    ],
  },
  'status': 422,
};

print(errorResponseSchema.validate(errorResponse).isValid);
```

## Configuration Files

### Application Config

```dart
final appConfigSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'app': Validasi.map<dynamic>([
      MapRules.hasFields({
        'name': Validasi.string([StringRules.minLength(1)]),
        'version': Validasi.string([StringRules.minLength(1)]),
        'env': Validasi.string([
          StringRules.oneOf(['development', 'staging', 'production']),
        ]),
      }),
    ]),
    'server': Validasi.map<dynamic>([
      MapRules.hasFields({
        'host': Validasi.string([StringRules.minLength(1)]),
        'port': Validasi.number<int>([
          NumberRules.moreThan(0),
          NumberRules.lessThan(65536),
        ]),
        'ssl': Validasi.any<bool>(),
      }),
    ]),
    'database': Validasi.map<dynamic>([
      MapRules.hasFields({
        'host': Validasi.string([StringRules.minLength(1)]),
        'port': Validasi.number<int>([NumberRules.moreThan(0)]),
        'name': Validasi.string([StringRules.minLength(1)]),
        'user': Validasi.string([StringRules.minLength(1)]),
        'password': Validasi.string([StringRules.minLength(1)]),
        'pool_size': Validasi.number<int>([
          NumberRules.moreThan(0),
          NumberRules.lessThanEqual(100),
        ]),
      }),
    ]),
    'cache': Validasi.map<dynamic>([
      MapRules.hasFields({
        'driver': Validasi.string([
          StringRules.oneOf(['redis', 'memcached', 'memory']),
        ]),
        'ttl': Validasi.number<int>([NumberRules.moreThan(0)]),
      }),
    ]),
    'logging': Validasi.map<dynamic>([
      MapRules.hasFields({
        'level': Validasi.string([
          StringRules.oneOf(['debug', 'info', 'warning', 'error']),
        ]),
        'outputs': Validasi.list<String>([
          IterableRules.minLength(1),
          IterableRules.forEach(
            Validasi.string([
              StringRules.oneOf(['console', 'file', 'syslog']),
            ]),
          ),
        ]),
      }),
    ]),
  }),
]);

final config = {
  'app': {
    'name': 'MyApp',
    'version': '1.0.0',
    'env': 'production',
  },
  'server': {
    'host': '0.0.0.0',
    'port': 8080,
    'ssl': true,
  },
  'database': {
    'host': 'localhost',
    'port': 5432,
    'name': 'myapp_db',
    'user': 'dbuser',
    'password': 'secret',
    'pool_size': 20,
  },
  'cache': {
    'driver': 'redis',
    'ttl': 3600,
  },
  'logging': {
    'level': 'info',
    'outputs': ['console', 'file'],
  },
};

print(appConfigSchema.validate(config).isValid);
```

## Forms and Surveys

### Multi-Step Form

```dart
final multiStepFormSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'personal_info': Validasi.map<dynamic>([
      MapRules.hasFields({
        'first_name': Validasi.string([
          Transform((value) => value?.trim()),
          StringRules.minLength(1),
        ]),
        'last_name': Validasi.string([
          Transform((value) => value?.trim()),
          StringRules.minLength(1),
        ]),
        'email': Validasi.string([
          Transform((value) => value?.trim().toLowerCase()),
          InlineRule<String>((value) {
            return value.contains('@') ? null : 'Invalid email';
          }),
        ]),
        'phone': Validasi.string([
          Nullable(),
          StringRules.minLength(10),
        ]),
      }),
    ]),
    'address': Validasi.map<dynamic>([
      MapRules.hasFields({
        'street': Validasi.string([StringRules.minLength(1)]),
        'city': Validasi.string([StringRules.minLength(1)]),
        'state': Validasi.string([StringRules.minLength(2)]),
        'zip': Validasi.string([StringRules.minLength(5)]),
        'country': Validasi.string([StringRules.minLength(2)]),
      }),
    ]),
    'preferences': Validasi.map<dynamic>([
      MapRules.hasFields({
        'newsletter': Validasi.any<bool>(),
        'notifications': Validasi.map<dynamic>([
          MapRules.hasFields({
            'email': Validasi.any<bool>(),
            'sms': Validasi.any<bool>(),
            'push': Validasi.any<bool>(),
          }),
        ]),
        'interests': Validasi.list<String>([
          IterableRules.minLength(1, message: 'Select at least one interest'),
          IterableRules.forEach(
            Validasi.string([StringRules.minLength(1)]),
          ),
        ]),
      }),
    ]),
  }),
]);

final formData = {
  'personal_info': {
    'first_name': 'John',
    'last_name': 'Doe',
    'email': 'JOHN@EXAMPLE.COM',
    'phone': '555-0123',
  },
  'address': {
    'street': '123 Main St',
    'city': 'Springfield',
    'state': 'IL',
    'zip': '62701',
    'country': 'USA',
  },
  'preferences': {
    'newsletter': true,
    'notifications': {
      'email': true,
      'sms': false,
      'push': true,
    },
    'interests': ['technology', 'sports', 'music'],
  },
};

final result = multiStepFormSchema.validate(formData);
print('Valid: ${result.isValid}');
```

### Survey Response

```dart
final surveySchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'survey_id': Validasi.number<int>([NumberRules.moreThan(0)]),
    'respondent': Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([Nullable()]),
        'email': Validasi.string([Nullable()]),
      }),
    ]),
    'responses': Validasi.list<Map<String, dynamic>>([
      IterableRules.minLength(1, message: 'At least one response required'),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'question_id': Validasi.number<int>([NumberRules.moreThan(0)]),
            'question_type': Validasi.string([
              StringRules.oneOf(['text', 'choice', 'rating', 'boolean']),
            ]),
            'answer': Validasi.any<dynamic>([
              Required(message: 'Answer is required'),
            ]),
          }),
        ]),
      ),
    ]),
    'completed_at': Validasi.string([StringRules.minLength(1)]),
  }),
]);

final survey = {
  'survey_id': 123,
  'respondent': {
    'id': 456,
    'email': 'user@example.com',
  },
  'responses': [
    {
      'question_id': 1,
      'question_type': 'text',
      'answer': 'I really enjoyed the service',
    },
    {
      'question_id': 2,
      'question_type': 'rating',
      'answer': 5,
    },
    {
      'question_id': 3,
      'question_type': 'boolean',
      'answer': true,
    },
  ],
  'completed_at': '2024-01-15T10:00:00Z',
};

print(surveySchema.validate(survey).isValid);
```

## Data Import/Export

### CSV Import Schema

```dart
final csvImportSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'filename': Validasi.string([StringRules.minLength(1)]),
    'rows': Validasi.list<Map<String, dynamic>>([
      IterableRules.minLength(1, message: 'CSV must have at least one row'),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'row_number': Validasi.number<int>([NumberRules.moreThan(0)]),
            'data': Validasi.map<dynamic>([
              MapRules.hasFields({
                'name': Validasi.string([
                  Transform((value) => value?.trim()),
                  StringRules.minLength(1, message: 'Name cannot be empty'),
                ]),
                'email': Validasi.string([
                  Transform((value) => value?.trim().toLowerCase()),
                  InlineRule<String>((value) {
                    return value.contains('@') ? null : 'Invalid email';
                  }),
                ]),
                'age': Validasi.number<int>([
                  Nullable(),
                  NumberRules.moreThanEqual(0),
                  NumberRules.lessThanEqual(150),
                ]),
              }),
            ]),
          }),
        ]),
      ),
    ]),
    'imported_at': Validasi.string([StringRules.minLength(1)]),
  }),
]);
```

## Analytics Data

### Event Tracking

```dart
final analyticsSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'session_id': Validasi.string([StringRules.minLength(1)]),
    'user': Validasi.map<dynamic>([
      MapRules.hasFields({
        'id': Validasi.number<int>([Nullable()]),
        'anonymous_id': Validasi.string([Nullable()]),
      }),
    ]),
    'events': Validasi.list<Map<String, dynamic>>([
      IterableRules.minLength(1),
      IterableRules.forEach(
        Validasi.map<dynamic>([
          MapRules.hasFields({
            'name': Validasi.string([StringRules.minLength(1)]),
            'timestamp': Validasi.string([StringRules.minLength(1)]),
            'properties': Validasi.map<dynamic>([Nullable()]),
            'page': Validasi.map<dynamic>([
              Nullable(),
              MapRules.hasFields({
                'url': Validasi.string([StringRules.minLength(1)]),
                'title': Validasi.string([Nullable()]),
                'referrer': Validasi.string([Nullable()]),
              }),
            ]),
          }),
        ]),
      ),
    ]),
  }),
]);

final analyticsData = {
  'session_id': 'sess_abc123',
  'user': {
    'id': 12345,
    'anonymous_id': null,
  },
  'events': [
    {
      'name': 'page_view',
      'timestamp': '2024-01-15T10:00:00Z',
      'properties': {'source': 'organic'},
      'page': {
        'url': 'https://example.com/home',
        'title': 'Home Page',
        'referrer': 'https://google.com',
      },
    },
    {
      'name': 'button_click',
      'timestamp': '2024-01-15T10:01:00Z',
      'properties': {'button_id': 'signup'},
      'page': null,
    },
  ],
};

print(analyticsSchema.validate(analyticsData).isValid);
```

## Next Steps

- [String Validation](/examples/string-validation)
- [Number Validation](/examples/number-validation)
- [List Validation](/examples/list-validation)
- [Map Validation](/examples/map-validation)
- [Error Handling Guide](/guide/error-handling)
