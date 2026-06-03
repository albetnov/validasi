class Required {
  final String? message;
  const Required({this.message});
}

class Nullable {
  const Nullable();
}

class MinLength {
  final int length;
  final String? message;
  const MinLength(this.length, {this.message});
}

class MaxLength {
  final int length;
  final String? message;
  const MaxLength(this.length, {this.message});
}

class OneOf {
  final List<String> options;
  final String? message;
  const OneOf(this.options, {this.message});
}
