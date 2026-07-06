/// Class-level annotations that desugar into a synthetic `@RefineFn`-style
/// cross-field check, generated for you instead of hand-written.
class RequiredAny {
  final List<String> fields;
  final String? message;
  const RequiredAny(this.fields, {this.message});
}

class RequiredOneOf {
  final List<String> fields;
  final String? message;
  const RequiredOneOf(this.fields, {this.message});
}

class RequiredAll {
  final List<String> fields;
  final String? message;
  const RequiredAll(this.fields, {this.message});
}

class DependsOn {
  final String field;
  final String dependsOn;
  final String? message;
  const DependsOn({
    required this.field,
    required this.dependsOn,
    this.message,
  });
}

class MutuallyExclusive {
  final String fieldA;
  final String fieldB;
  final String? message;
  const MutuallyExclusive(this.fieldA, this.fieldB, {this.message});
}

class MatchesField {
  final String field;
  final String matchesField;
  final String? message;
  const MatchesField({
    required this.field,
    required this.matchesField,
    this.message,
  });
}
