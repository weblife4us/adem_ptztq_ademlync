import '../ademlync_device.dart';

class DataParser {
  /// Map as a bool value
  static bool? asBool<T>(T? o) => switch (_parser(o)) {
    (String o) => o == '00000001',
    _ => null,
  };

  /// Map as an int value
  static int? asInt<T>(T? o) => switch (_parser(o)) {
    (String o) => int.tryParse(o),
    _ => null,
  };

  /// Map as a double value
  static double? asDouble<T>(T? o) => switch (_parser(o)) {
    (String o) => double.tryParse(o),
    _ => null,
  };

  /// Map as a num value
  static num? asNum<T>(T? o) => switch (_parser(o)) {
    (String o) => num.tryParse(o),
    _ => null,
  };

  /// Map as a date value
  static DateTime? asDate<T>(T? o) {
    try {
      final str = _parser(o);
      return str != null ? unitDateFmt.parse(str) : null;
    } catch (_) {
      return null;
    }
  }

  /// Map as a time value
  static DateTime? asTime<T>(T? o) {
    try {
      final str = _parser(o);
      return str != null && str != '00 00 00' ? unitTimeFmt.parse(str) : null;
    } catch (_) {
      return null;
    }
  }

  /// Map as a q log date value
  static DateTime? asQLogDate<T>(T? o) {
    try {
      final str = _parser(o);
      return str != null && str != '00 00 00' ? qLogDateFmt.parse(str) : null;
    } catch (_) {
      return null;
    }
  }

  /// Map as a temp double value
  static double? asTemp<T>(T? o) => switch (_parser(o)) {
    (String o) => double.tryParse(o.replaceAll('S', '')),
    _ => null,
  };

  static String? _parser<T>(T? o) => switch (o) {
    (String o) => o,
    (AdemResponse o) => o.body,
    _ => null,
  };
}
