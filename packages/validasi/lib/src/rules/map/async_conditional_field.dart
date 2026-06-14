import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/map/conditional_field.dart';

typedef AsyncConditionalFieldCallback<T> = Future<String?> Function(
    ConditionalFieldContext<T> context, T? value);

class AsyncConditionalField<T> extends AsyncRule<Map<String, T>> {
  AsyncConditionalField(
    this.fieldName,
    this.callback,
  );

  final String fieldName;
  final AsyncConditionalFieldCallback<T> callback;

  @override
  Future<Map<String, T>?> applyAsync(
      Map<String, T>? value, ValidationState state) async {
    if (value == null) return null;

    final fieldValue = value[fieldName];

    final error = await callback(ConditionalFieldContext(value), fieldValue);

    if (error != null) {
      state.addError(
        ValidationError(
          rule: 'conditionalField',
          message: error,
        ),
      );
    }
    return value;
  }
}
