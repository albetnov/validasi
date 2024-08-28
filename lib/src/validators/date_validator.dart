import 'dart:async';

import 'package:intl/intl.dart';
import 'package:validasi/src/mixins/strict_check.dart';
import 'package:validasi/src/result.dart';
import 'package:validasi/src/validators/validator.dart';

enum DateUnit {
  day,
  month,
  year;
}

enum DateCompare {
  before,
  after,
  same,
  invalid;
}

class DateValidator extends Validator<DateTime> with StrictCheck<DateTime> {
  @override
  final String? message;
  @override
  final bool strict;
  final String pattern;

  DateValidator({this.pattern = 'y-MM-dd', this.message, this.strict = true});

  DateValidator required() {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: ':name is required',
    );

    return this;
  }

  int _getDifference(DateTime from, DateTime to, DateUnit unit) {
    switch (unit) {
      case DateUnit.year:
        return from.year - to.year;
      case DateUnit.month:
        return (from.month - to.month).abs();
      default:
        Duration diff = from.difference(to);
        return diff.inDays;
    }
  }

  DateCompare _compare(DateTime? from, DateTime to) {
    if (from == null) return DateCompare.invalid;

    int result = from.compareTo(to);

    switch (result) {
      case 0:
        return DateCompare.same;
      case > 0:
        return DateCompare.after;
      default:
        return DateCompare.before;
    }
  }

  DateValidator before(DateTime target,
      {DateUnit unit = DateUnit.day, int difference = 1, String? message}) {
    addRule(
      name: 'before',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.invalid || result != DateCompare.before) {
          return false;
        }

        return _getDifference(value!, target, unit) >= difference;
      },
      message: message ??
          ":name must be before ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  DateValidator after(DateTime target,
      {DateUnit unit = DateUnit.day, int difference = 1, String? message}) {
    addRule(
      name: 'after',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.invalid || result != DateCompare.after) {
          return false;
        }

        return _getDifference(value!, target, unit) <= difference;
      },
      message: message ??
          ":name must be after ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  DateValidator beforeSame(DateTime target,
      {DateUnit unit = DateUnit.day, String? message}) {
    addRule(
      name: 'beforeSame',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.invalid || result == DateCompare.after) {
          return false;
        }

        return _getDifference(value!, target, unit) <= 0;
      },
      message: message ??
          ":name must be before or equal ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  DateValidator afterSame(DateTime target,
      {DateUnit unit = DateUnit.day, String? message}) {
    addRule(
      name: 'afterSame',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.invalid || result == DateCompare.before) {
          return false;
        }

        return _getDifference(value!, target, unit) >= 0;
      },
      message: message ??
          ":name must be after or equal ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  DateTime? _valueToDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateFormat(pattern).tryParse(value);
    }

    return null;
  }

  @override
  Result<DateTime> parse(dynamic value, {String path = 'field'}) {
    strictCheck(value, path);

    return super.parse(_valueToDateTime(value), path: path);
  }

  @override
  Result<DateTime> tryParse(dynamic value, {String path = 'field'}) {
    var result = super.tryParse(_valueToDateTime(value), path: path);

    tryStrictCheck(result, value, path);

    return result;
  }

  @override
  Future<Result<DateTime>> parseAsync(dynamic value, {String path = 'field'}) {
    strictCheck(value, path);

    return super.parseAsync(value, path: path);
  }

  @override
  Future<Result<DateTime>> tryParseAsync(dynamic value,
      {String path = 'field'}) async {
    var result = await super.tryParseAsync(value, path: path);

    tryStrictCheck(result, value, path);

    return result;
  }
}
