import 'package:validasi/engine.dart';

typedef SchemaBuilder = ValidasiEngine<dynamic> Function();

class RegisteredSchema {
  const RegisteredSchema({
    required this.id,
    required this.builder,
    this.description,
  });

  final String id;
  final SchemaBuilder builder;
  final String? description;

  ValidasiEngine<dynamic> create() => builder();
}

class SchemaRegistry {
  final Map<String, RegisteredSchema> _schemas = <String, RegisteredSchema>{};

  void register({
    required String id,
    required SchemaBuilder builder,
    String? description,
  }) {
    _schemas[id] = RegisteredSchema(
      id: id,
      builder: builder,
      description: description,
    );
  }

  bool has(String id) => _schemas.containsKey(id);

  RegisteredSchema? get(String id) => _schemas[id];

  List<RegisteredSchema> list() {
    final entries = _schemas.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((entry) => entry.value).toList(growable: false);
  }
}
