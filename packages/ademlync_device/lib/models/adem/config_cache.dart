import 'package:equatable/equatable.dart';

import '../../utils/adem_param.dart';

class ConfigCache extends Equatable {
  final DateTime gasDayStartTime;
  final UnitDateFmt dateFmt;
  final String timeFmt;
  final DateTime? lastSaveDate;
  final DateTime? lastSaveTime;
  final int backupIdxCounter;
  final String dispTestPattern;
  final BatteryType batteryType;
  final bool isSealed;

  const ConfigCache({
    required this.gasDayStartTime,
    required this.dateFmt,
    required this.timeFmt,
    required this.lastSaveDate,
    required this.lastSaveTime,
    required this.backupIdxCounter,
    required this.dispTestPattern,
    required this.batteryType,
    required this.isSealed,
  });

  ConfigCache copyWith({DateTime? gasDayStartTime}) => ConfigCache(
    gasDayStartTime: gasDayStartTime ?? this.gasDayStartTime,
    dateFmt: dateFmt,
    timeFmt: timeFmt,
    lastSaveDate: lastSaveDate,
    lastSaveTime: lastSaveTime,
    backupIdxCounter: backupIdxCounter,
    dispTestPattern: dispTestPattern,
    batteryType: batteryType,
    isSealed: isSealed,
  );

  @override
  List<Object?> get props => [
    gasDayStartTime,
    dateFmt,
    timeFmt,
    lastSaveDate,
    lastSaveTime,
    backupIdxCounter,
    dispTestPattern,
    batteryType,
    isSealed,
  ];
}
