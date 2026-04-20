import 'package:dart_mcp/server.dart';

import 'schema_registry.dart';

class ValidasiMcpToolHandlers {
  const ValidasiMcpToolHandlers({required this.registry});

  final SchemaRegistry registry;

  Map<String, Object?> callTool(String name, Map<String, Object?> arguments) {
    switch (name) {
      case 'list_schemas':
        return listSchemas();
      case 'describe_schema':
        return describeSchema(arguments);
      case 'validate_input':
        return validateInput(arguments);
      default:
        return _error(
          code: 'UNKNOWN_TOOL',
          message: 'Unsupported tool: $name',
        );
    }
  }

  Map<String, Object?> listSchemas() {
    final schemas = registry.list().map(
      (item) {
        final descriptor = item.create().introspect();
        return <String, Object?>{
          'id': item.id,
          'description': item.description,
          'type': descriptor.type,
        };
      },
    ).toList(growable: false);

    return <String, Object?>{
      'ok': true,
      'schemas': schemas,
    };
  }

  Map<String, Object?> describeSchema(Map<String, Object?> arguments) {
    final schemaId = arguments['schema_id'];
    if (schemaId is! String || schemaId.isEmpty) {
      return _error(
        code: 'INVALID_ARGUMENT',
        message: 'schema_id is required and must be a non-empty string',
      );
    }

    final registered = registry.get(schemaId);
    if (registered == null) {
      return _error(
        code: 'SCHEMA_NOT_FOUND',
        message: 'Schema not registered: $schemaId',
      );
    }

    final descriptor = registered.create().introspect().toJson();

    return <String, Object?>{
      'ok': true,
      'schema_id': schemaId,
      'schema': descriptor,
    };
  }

  Map<String, Object?> validateInput(Map<String, Object?> arguments) {
    final schemaId = arguments['schema_id'];
    if (schemaId is! String || schemaId.isEmpty) {
      return _error(
        code: 'INVALID_ARGUMENT',
        message: 'schema_id is required and must be a non-empty string',
      );
    }

    final registered = registry.get(schemaId);
    if (registered == null) {
      return _error(
        code: 'SCHEMA_NOT_FOUND',
        message: 'Schema not registered: $schemaId',
      );
    }

    final schema = registered.create();
    final result = schema.validate(arguments['input']);

    return <String, Object?>{
      'ok': true,
      'schema_id': schemaId,
      'validation': result.toToolResponse(),
    };
  }

  List<Map<String, Object?>> toolDefinitions() {
    return <Map<String, Object?>>[
      <String, Object?>{
        'name': 'list_schemas',
        'description': 'List all registered schema identifiers',
        'inputSchema': <String, Object?>{
          'type': 'object',
          'properties': <String, Object?>{},
          'additionalProperties': false,
        },
      },
      <String, Object?>{
        'name': 'describe_schema',
        'description': 'Return introspection metadata for one schema',
        'inputSchema': <String, Object?>{
          'type': 'object',
          'required': <String>['schema_id'],
          'properties': <String, Object?>{
            'schema_id': <String, Object?>{'type': 'string'},
          },
          'additionalProperties': false,
        },
      },
      <String, Object?>{
        'name': 'validate_input',
        'description': 'Validate input against a registered schema',
        'inputSchema': <String, Object?>{
          'type': 'object',
          'required': <String>['schema_id'],
          'properties': <String, Object?>{
            'schema_id': <String, Object?>{'type': 'string'},
            'input': <String, Object?>{},
          },
          'additionalProperties': false,
        },
      },
    ];
  }

  List<Tool> tools() {
    return toolDefinitions().map((definition) {
      final name = definition['name'] as String;
      final description = definition['description'] as String?;
      final inputSchemaMap =
          (definition['inputSchema'] as Map).cast<String, Object?>();

      return Tool(
        name: name,
        description: description,
        inputSchema: ObjectSchema.fromMap(inputSchemaMap),
      );
    }).toList(growable: false);
  }

  Map<String, Object?> _error({
    required String code,
    required String message,
  }) {
    return <String, Object?>{
      'ok': false,
      'error': <String, Object?>{
        'code': code,
        'message': message,
      },
    };
  }
}
