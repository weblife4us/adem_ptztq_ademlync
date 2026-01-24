part of 'log.dart';

class DailyLog extends Log {
  final int corDailyVol;
  final int uncDailyVol;
  final double? avgPress;
  final double? avgTemp;
  final double avgTotalFactor;
  final num avgUncFlow;
  final num avgCorFlow;
  final double avgBatteryVoltage;
  final num? qMargin;
  final double? percentageOfMaxFlowRate;
  final String? diffPress;

  const DailyLog(
    super.logNumber,
    super.date,
    super.time,
    this.corDailyVol,
    this.uncDailyVol,
    this.avgPress,
    this.avgTemp,
    this.avgTotalFactor,
    this.avgUncFlow,
    this.avgCorFlow,
    this.avgBatteryVoltage,
    this.qMargin,
    this.percentageOfMaxFlowRate,
    this.diffPress,
  );
}
