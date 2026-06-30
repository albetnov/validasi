import 'dart:async';

import 'package:validasi_annotation/validasi_annotation.dart';

enum Status { pending, active, rejected }

class IsPositive extends CustomRule<int> {
  const IsPositive({super.message}) : super(name: 'isPositive');

  static bool check(int? value) => value != null && value > 0;
}

class IsEven extends AsyncCustomRule<int> {
  const IsEven({super.message, super.runOnNull}) : super(name: 'isEven');

  static Future<bool> check(int? value) async =>
      value != null && value % 2 == 0;
}

bool _isValidStatus(Status? value) => value != null && value != Status.rejected;

@ValidateClass()
class AnyFieldModel {
  @Validate<Status>([Inline<Status>(_isValidStatus, name: 'validStatus')])
  final Status status;

  @Validate<Status>([
    OneOf([Status.pending, Status.active])
  ])
  final Status role;

  const AnyFieldModel({required this.status, required this.role});
}

@ValidateClass()
class IntAnyModel {
  @Validate<int>([
    OneOf([42, 100])
  ])
  final int code;

  @Validate<int>([IsPositive()])
  final int amount;

  const IntAnyModel({required this.code, required this.amount});
}

@ValidateClass()
class AsyncAnyModel {
  @Validate<int>([IsEven()])
  final int count;

  const AsyncAnyModel({required this.count});
}
