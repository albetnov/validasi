import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class ConditionalFieldContext<T> {
  ConditionalFieldContext(this._value);

  final Map<String, T> _value;

  R? get<R extends T>(String key) => _value[key] as R?;

  bool has(String key) => _value.containsKey(key);

  bool check<R extends T>(String key) =>
      _value.containsKey(key) && _value[key] is R;

  bool isEmpty() => _value.isEmpty;
}

class ConditionalField<T> extends Rule<Map<String, T>> {
  ConditionalField(
    this.fieldName,
    this.condition,
  );

  final String fieldName;
  final String? Function(ConditionalFieldContext<T> context, T? value)
      condition;

  @override
  void apply(ValidationContext<Map<String, T>> context) {
    final value = context.requireValue[fieldName];

    final error =
        condition(ConditionalFieldContext(context.requireValue), value);

    if (error != null) {
      context.addError(
        ValidationError(
          rule: 'conditionalField',
          message: error,
        ),
      );
    }
  }
}
