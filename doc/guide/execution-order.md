# Rules Execution Order

In Validasi the Rule Execution order is as follow:

![Validasi Execution Order](/validasi_execution_order.png)

Notice where some flow goes to **END** directly.

- The first one is when the value is `null`. If the `nullable` is set, the flow will jump and skip right to the
custom rule execution.
- When the value is not null, The validator will check the type of the value and if it's not the same as the schema,
the validator will check for the transformer, if it is set the transformer will be executed to transform the value to the desired type. If the transformation failed or no transformer is set, the validaton will end and return the error.
- The last on is the required rule, this flow can only occur when `nullable` is not set. The required rule simply check
if the value is not `null`. If the value is `null` the validation will end and return error.
- The built-in rules will be executed in the order they are defined. Each of the rules will be executed even if the previous
built-in rule failed. The custom rule will be executed after all the built-in rules are all executed.