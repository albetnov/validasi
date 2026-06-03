class ValidateClass {
  const ValidateClass();
}

class Validate {
  final List<Object>? rules;

  const Validate(this.rules);

  const Validate.string(List<Object> this.rules);

  const Validate.iterable(List<Object> this.rules);
}
