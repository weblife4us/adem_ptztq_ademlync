part of 'log.dart';

class IntervalLog extends Log {
  final num corIncrementVol;
  final num uncIncrementVol;
  final double? avgPress;
  final double? avgTemp;
  final num? corTotalVol;
  final num? uncTotalVol;
  final double? avgTotalFactor;
  final num? uncAvgFlowRate;
  final double? maxPress;
  final DateTime? maxPressTime;
  final double? minPress;
  final DateTime? minPressTime;
  final double? maxTemp;
  final DateTime? maxTempTime;
  final double? minTemp;
  final DateTime? minTempTime;
  final num? uncMaxFlowRate;
  final DateTime? uncMaxFlowRateTime;
  final num? uncMinFlowRate;
  final DateTime? uncMinFlowRateTime;
  final double? avgBatteryVoltage;
  // final double? superXFactor;
  // final int? uncVolSinceMalf;
  final IntervalLogAlarms alarms;

  const IntervalLog(
    super.logNumber,
    super.date,
    super.time, {
    required this.corIncrementVol,
    required this.uncIncrementVol,
    this.avgPress,
    this.avgTemp,
    this.corTotalVol,
    this.uncTotalVol,
    this.avgTotalFactor,
    this.uncAvgFlowRate,
    this.uncMaxFlowRate,
    this.uncMaxFlowRateTime,
    this.maxPress,
    this.maxPressTime,
    this.minPress,
    this.minPressTime,
    this.maxTemp,
    this.maxTempTime,
    this.minTemp,
    this.minTempTime,
    this.uncMinFlowRate,
    this.uncMinFlowRateTime,
    this.avgBatteryVoltage,
    // this.superXFactor,
    // this.uncVolSinceMalf,
    required this.alarms,
  });
}

class IntervalLogAlarms {
  final bool isMemoryError;
  final bool isFlowrateHigh;
  final bool isFlowrateLow;
  final bool? isPressHigh;
  final bool? isPressLow;
  final bool? isTempHigh;
  final bool? isTempLow;
  final bool? isTmr1Malf;
  final bool? isTmr2Malf;
  final bool isBatteryMalf;
  final bool? isTempMalf;
  final bool? isPressMalf;

  const IntervalLogAlarms(
    this.isMemoryError,
    this.isFlowrateHigh,
    this.isFlowrateLow,
    this.isPressHigh,
    this.isPressLow,
    this.isTempHigh,
    this.isTempLow,
    this.isTmr1Malf,
    this.isTmr2Malf,
    this.isBatteryMalf,
    this.isTempMalf,
    this.isPressMalf,
  );
}
