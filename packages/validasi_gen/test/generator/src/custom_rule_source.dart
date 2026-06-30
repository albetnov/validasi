import 'dart:async';

import 'package:validasi_annotation/validasi_annotation.dart';

class IsEmail extends CustomRule<String> {
  final String domain;

  const IsEmail(this.domain, {super.message, super.runOnNull})
      : super(name: 'isEmail');

  static bool check(String? value, {required String domain}) =>
      value != null && value.endsWith(domain);
}

class NonEmpty extends CustomRule<String> {
  const NonEmpty({super.message}) : super(name: 'nonEmpty');

  static bool check(String? value) => value != null && value.isNotEmpty;
}

class ValidatePassword extends AsyncCustomRule<String> {
  final int minLength;

  const ValidatePassword(this.minLength, {super.message})
      : super(name: 'validatePassword');

  static Future<bool> check(String? value, {required int minLength}) async =>
      value != null && value.length >= minLength;
}

bool _isEmail(String? value) => value?.contains('@') ?? false;

@ValidateClass()
class CustomRuleModel {
  @Validate<String>([NonEmpty(), IsEmail('example.com')])
  final String email;

  @Validate<List<String>>([MinLength(2)])
  final List<String> items;

  const CustomRuleModel({required this.email, required this.items});
}

@ValidateClass()
class InlineModel {
  @Validate<String>([Inline(_isEmail, name: 'positive')])
  final String label;

  final String note;

  const InlineModel({required this.label, required this.note});
}

@ValidateClass()
class AsyncCustomModel {
  @Validate<String>([ValidatePassword(8)])
  final String password;

  const AsyncCustomModel({required this.password});
}
