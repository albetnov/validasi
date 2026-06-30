class RequiredHelper {
  const RequiredHelper();

  String emitError(String pathExpr, String messageArg) {
    return '_Errors.required($pathExpr$messageArg)';
  }

  static final Map<String, String> helperMethods = {
    'required':
        "static ValidationError required(List<String> path, {String? message}) =>\n"
            '      ValidationError(\n'
            "        rule: 'Required',\n"
            "        message: message ?? 'Field is required',\n"
            '        path: path,\n'
            '      );',
  };
}
