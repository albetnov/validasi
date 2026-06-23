import 'dart:async';

import 'package:validasi_annotation/validasi_annotation.dart';

class IsEmail extends CustomRule<String> {
  final String domain;

  const IsEmail(this.domain, {String? message, super.runOnNull})
      : super(name: 'isEmail', message: message);

  static bool check(String? value, {required String domain}) =>
      value != null && value.endsWith(domain);
}

class NonEmpty extends CustomRule<String> {
  const NonEmpty({String? message}) : super(name: 'nonEmpty', message: message);

  static bool check(String? value) => value != null && value.isNotEmpty;
}

class ValidatePassword extends AsyncCustomRule<String> {
  final int minLength;

  const ValidatePassword(this.minLength, {String? message})
      : super(name: 'validatePassword', message: message);

  static Future<bool> check(String? value, {required int minLength}) async =>
      value != null && value.length >= minLength;
}

bool _isEmail(String? value) => value?.contains('@') ?? false;

@ValidateClass()
class CustomRuleModel {
  @Validate.string([NonEmpty(), IsEmail('example.com')])
  final String email;

  @Validate.iterable([MinLength(2)])
  final List<String> items;

  const CustomRuleModel({required this.email, required this.items});
}

@ValidateClass()
class InlineModel {
  @Validate.string([Inline(_isEmail, name: 'positive')])
  final String label;

  final String note;

  const InlineModel({required this.label, required this.note});
}

@ValidateClass()
class AsyncCustomModel {
  @Validate.string([ValidatePassword(8)])
  final String password;

  const AsyncCustomModel({required this.password});
}
