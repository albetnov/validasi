import 'package:intl/intl.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

/// The Supported Unit of Date.
enum DateUnit {
  day,
  month,
  year;
}

/// The result of Date Comparasion determing if the date is
/// before, after, same, or is invalid.
enum DateCompare {
  before,
  after,
  same;
}

/// Responsible for validating [DateTime] or formatted [String] Date Time.
class DateValidator extends Validator<DateTime> {
  final String pattern;

  @override
  DateValidator nullable() => super.nullable();

  @override
  DateValidator custom(CustomCallback<DateTime> callback) =>
      super.custom(callback);

  @override
  DateValidator customFor(CustomRule<DateTime> customRule) =>
      super.customFor(customRule);

  DateValidator({super.transformer, this.pattern = 'y-MM-dd'});

  int _getDifference(DateTime from, DateTime to, DateUnit unit) {
    switch (unit) {
      case DateUnit.year:
        return (from.year - to.year).abs();
      case DateUnit.month:
        return (from.month - to.month).abs();
      default:
        Duration diff = from.difference(to);
        return diff.inDays.abs();
    }
  }

  DateCompare _compare(DateTime from, DateTime to) {
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

  /// [before] indicate that the value must be before of [target] based on
  /// given [unit] and [difference] for comparasion.
  DateValidator before(DateTime target,
      {DateUnit unit = DateUnit.day, int difference = 1, String? message}) {
    addRule(
      name: 'before',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result != DateCompare.before) {
          return false;
        }

        return _getDifference(value, target, unit) >= difference;
      },
      message: message ??
          ":name must be before ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  /// [after] indicate that the value must be after of [target] based on
  /// given [unit] and [difference] for comparasion.
  DateValidator after(DateTime target,
      {DateUnit unit = DateUnit.day, int difference = 1, String? message}) {
    addRule(
      name: 'after',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result != DateCompare.after) {
          return false;
        }

        return _getDifference(value, target, unit) >= difference;
      },
      message: message ??
          ":name must be after ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  /// Similar to [before]. [beforeSame] allows if the [target] is the same as
  /// value.
  DateValidator beforeSame(DateTime target,
      {DateUnit unit = DateUnit.day, String? message}) {
    addRule(
      name: 'beforeSame',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.after) {
          return false;
        }

        return _getDifference(value, target, unit) >= 0;
      },
      message: message ??
          ":name must be before or equal ${DateFormat(pattern).format(target)}",
    );

    return this;
  }

  /// Similar to [after]. [afterSame] allows if the [target] is the same as
  /// value.
  DateValidator afterSame(DateTime target,
      {DateUnit unit = DateUnit.day, String? message}) {
    addRule(
      name: 'afterSame',
      test: (value) {
        DateCompare result = _compare(value, target);
        if (result == DateCompare.before) {
          return false;
        }

        return _getDifference(value, target, unit) >= 0;
      },
      message: message ??
          ":name must be after or equal ${DateFormat(pattern).format(target)}",
    );

    return this;
  }
}
