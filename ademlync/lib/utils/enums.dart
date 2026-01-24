import 'package:equatable/equatable.dart';

enum NullSafety {
  user;

  String get message {
    switch (this) {
      case NullSafety.user:
        return 'No user found.';
    }
  }

  Exception get exception => SkyLabException(this, message);
}

class SkyLabException implements Exception {
  final NullSafety type;
  final String? message;

  const SkyLabException(this.type, this.message);
}

enum LoginState { unauthenticated, authenticated, expired }

enum SetupItem {
  basic,
  pressAndTemp,
  statistic,
  display,
  aga8,
  qMonitor,
  setupReportExport,
  configExport,
  configImport;

  String get text => switch (this) {
    SetupItem.basic => 'Basic',
    SetupItem.pressAndTemp => 'Press. & Temp.',
    SetupItem.statistic => 'Statistic',
    SetupItem.display => 'Display',
    SetupItem.aga8 => 'AGA8 Detail',
    SetupItem.qMonitor => 'Q Monitor',
    SetupItem.setupReportExport => 'Export Setup Report',
    SetupItem.configExport => 'Export Configuration',
    SetupItem.configImport => 'Import Configuration',
  };

  String get svg => switch (this) {
    SetupItem.basic => 'basic',
    SetupItem.pressAndTemp => 'pressAndTemp',
    SetupItem.statistic => 'statistic',
    SetupItem.display => 'display',
    SetupItem.aga8 => 'chem',
    SetupItem.qMonitor => 'chem',
    SetupItem.setupReportExport => 'export',
    SetupItem.configExport => 'export',
    SetupItem.configImport => 'import',
  };

  String get location => switch (this) {
    SetupItem.basic => '/setup/basic',
    SetupItem.pressAndTemp => '/setup/pressAndTemp',
    SetupItem.statistic => '/setup/statistic',
    SetupItem.display => '/setup/display',
    SetupItem.aga8 => '/setup/aga8',
    SetupItem.qMonitor => '/setup/qMonitor',
    SetupItem.configImport => '/setup/config/import',
    SetupItem.configExport ||
    SetupItem.setupReportExport => throw UnimplementedError(),
  };
}

enum CheckItem {
  basic,
  battery,
  alarm,
  factor,
  statistic,
  display,
  aga8,
  qMonitor,
  checkReportExport;

  String get text => switch (this) {
    CheckItem.basic => 'Basic',
    CheckItem.battery => 'Battery',
    CheckItem.alarm => 'Alarm',
    CheckItem.factor => 'Factor',
    CheckItem.statistic => 'Statistic',
    CheckItem.display => 'Display',
    CheckItem.aga8 => 'AGA8 Detail',
    CheckItem.qMonitor => 'Q Monitor',
    CheckItem.checkReportExport => 'Export Check Report',
  };

  String get svg => switch (this) {
    CheckItem.basic => 'basic',
    CheckItem.battery => 'battery',
    CheckItem.alarm => 'alert',
    CheckItem.factor => 'calculator',
    CheckItem.statistic => 'statistic',
    CheckItem.display => 'display',
    CheckItem.aga8 => 'chem',
    CheckItem.qMonitor => 'chem',
    CheckItem.checkReportExport => 'export',
  };

  String get location => switch (this) {
    CheckItem.basic => '/check/basic',
    CheckItem.battery => '/check/battery',
    CheckItem.alarm => '/check/alarm',
    CheckItem.factor => '/check/factor',
    CheckItem.statistic => '/check/statistic',
    CheckItem.display => '/check/display',
    CheckItem.aga8 => '/check/aga8',
    CheckItem.qMonitor => '/check/qMonitor',
    CheckItem.checkReportExport => throw UnimplementedError(),
  };
}

enum CalibrationItem {
  dp1Point,
  dp3Point,
  press1Point,
  press3Point,
  temp1Point,
  temp3Point;

  String get text => switch (this) {
    CalibrationItem.dp1Point => '1 Point D.P.',
    CalibrationItem.dp3Point => '3 Point D.P.',
    CalibrationItem.press1Point => '1 Point Pressure',
    CalibrationItem.press3Point => '3 Point Pressure',
    CalibrationItem.temp1Point => '1 Point Temperature',
    CalibrationItem.temp3Point => '3 Point Temperature',
  };

  String get svg => switch (this) {
    CalibrationItem.dp1Point => 'speed',
    CalibrationItem.dp3Point => 'speed',
    CalibrationItem.press1Point => 'speed',
    CalibrationItem.press3Point => 'speed',
    CalibrationItem.temp1Point => 'temperature',
    CalibrationItem.temp3Point => 'temperature',
  };

  String get location => switch (this) {
    CalibrationItem.dp1Point => '/calibration/onePoint/dp',
    CalibrationItem.dp3Point => '/calibration/threePoint/dp',
    CalibrationItem.press1Point => '/calibration/onePoint/pressure',
    CalibrationItem.press3Point => '/calibration/threePoint/pressure',
    CalibrationItem.temp1Point => '/calibration/onePoint/temperature',
    CalibrationItem.temp3Point => '/calibration/threePoint/temperature',
  };
}

enum LogItem {
  daily,
  interval,
  event,
  alarm,
  q,
  dp;

  String get text => switch (this) {
    LogItem.daily => 'Daily Log',
    LogItem.interval => 'Interval Log',
    LogItem.event => 'Event Log',
    LogItem.alarm => 'Alarm Log',
    LogItem.q => 'Q Log',
    LogItem.dp => 'Flow D.P. Log',
  };

  String get svg => switch (this) {
    LogItem.daily ||
    LogItem.interval ||
    LogItem.event ||
    LogItem.alarm ||
    LogItem.q ||
    LogItem.dp => 'log',
  };

  String get location => switch (this) {
    LogItem.daily => '/log/daily',
    LogItem.interval => '/log/interval',
    LogItem.event => '/log/event',
    LogItem.alarm => '/log/alarm',
    LogItem.q => '/log/q',
    LogItem.dp => '/log/dp',
  };
}

enum CloudItem {
  uploadSetupReport,
  uploadSetupConfig,
  uploadCheckReport,
  uploadLogs,
  downloadSetupReport,
  downloadSetupConfig,
  downloadCheckReport,
  downloadLogs;

  String get text => switch (this) {
    CloudItem.uploadSetupReport ||
    CloudItem.downloadSetupReport => 'Setup Report',
    CloudItem.uploadSetupConfig ||
    CloudItem.downloadSetupConfig => 'Setup Configuration',
    CloudItem.uploadCheckReport ||
    CloudItem.downloadCheckReport => 'Check Report',
    CloudItem.uploadLogs || CloudItem.downloadLogs => 'Logs',
  };
}

enum LimitedItem {
  customDisplay;

  String get text => switch (this) {
    LimitedItem.customDisplay => 'Custom Display',
  };

  String get svg => switch (this) {
    LimitedItem.customDisplay => 'display',
  };

  String get location => switch (this) {
    LimitedItem.customDisplay => '/limitedUser/customDisplay',
  };
}

class LogTimeRange extends Equatable {
  final DateTime from;
  final DateTime to;

  const LogTimeRange(this.from, this.to);

  LogTimeRange copyWith({DateTime? from, DateTime? to}) =>
      LogTimeRange(from ?? this.from, to ?? this.to);

  bool get isValid => from.isBefore(to);

  @override
  List<Object?> get props => [from, to];
}
