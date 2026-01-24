import 'package:intl/intl.dart';

import '../app_delegate.dart';

const _dateTime24Pattern = 'MMM dd, yyyy | HH:mm';
const _dateTime12Pattern = 'MMM dd, yyyy | hh:mm a';
const _datePattern = 'MMM dd, yyyy';
const _monthYearPattern = 'MMM, yyyy';
const _timestamp24Pattern = 'HH:mm:ss';
const _timestamp12Pattern = 'hh:mm:ss a';
const _time24Pattern = 'HH:mm';
const _time12Pattern = 'hh:mm a';
const _hour24Pattern = 'HH:00';
const _hour12Pattern = 'hh:00 a';
const _filename24Pattern = 'yyyy_MM_dd_HHmm';
const _filename12Pattern = 'yyyy_MM_dd_hhmma';

class DateTimeFmtManager {
  static bool get _is24HFmt => AppDelegate().is24HTimeFmt;

  static String formatDateTime(DateTime value) {
    final fmt = DateFormat(_is24HFmt ? _dateTime24Pattern : _dateTime12Pattern);
    return fmt.format(value);
  }

  static String formatDate(DateTime value) {
    final fmt = DateFormat(_datePattern);
    return fmt.format(value);
  }

  static String formatMonthYear(DateTime value) {
    final fmt = DateFormat(_monthYearPattern);
    return fmt.format(value);
  }

  static String formatTime(DateTime value) {
    final fmt = DateFormat(_is24HFmt ? _time24Pattern : _time12Pattern);
    return fmt.format(value);
  }

  static String formatTimestamp(DateTime value) {
    final fmt = DateFormat(
      _is24HFmt ? _timestamp24Pattern : _timestamp12Pattern,
    );
    return fmt.format(value);
  }

  static String formatHour(DateTime value) {
    final fmt = DateFormat(_is24HFmt ? _hour24Pattern : _hour12Pattern);
    return fmt.format(value);
  }

  static String formatFilenameDateTime(DateTime value) {
    final fmt = DateFormat(_is24HFmt ? _filename24Pattern : _filename12Pattern);
    return fmt.format(value);
  }
}
