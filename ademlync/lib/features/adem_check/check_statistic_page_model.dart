import 'package:equatable/equatable.dart';

class CheckStatisticPageModel extends Equatable {
  final double? maxPress;
  final DateTime? maxPressDate;
  final DateTime? maxPressTime;
  final double? minPress;
  final DateTime? minPressDate;
  final DateTime? minPressTime;
  final double? maxTemp;
  final DateTime? maxTempDate;
  final DateTime? maxTempTime;
  final double? minTemp;
  final DateTime? minTempDate;
  final DateTime? minTempTime;
  final double? maxCaseTemp;
  final double? minCaseTemp;
  final double? uncPeakFlowRate;
  final DateTime? uncPeakFlowRateDate;
  final DateTime? uncPeakFlowRateTime;
  final int? corLastSavedVol;
  final int? uncLastSavedVol;
  final DateTime? lastSaveDate;
  final DateTime? lastSaveTime;
  final int? backupIndexCounter;
  final bool? uncorrectedIndexRollover;
  final bool? correctedIndexRollover;
  final bool? showDot;

  const CheckStatisticPageModel(
    this.maxPress,
    this.maxPressDate,
    this.maxPressTime,
    this.minPress,
    this.minPressDate,
    this.minPressTime,
    this.maxTemp,
    this.maxTempDate,
    this.maxTempTime,
    this.minTemp,
    this.minTempDate,
    this.minTempTime,
    this.maxCaseTemp,
    this.minCaseTemp,
    this.uncPeakFlowRate,
    this.uncPeakFlowRateDate,
    this.uncPeakFlowRateTime,
    this.corLastSavedVol,
    this.uncLastSavedVol,
    this.lastSaveDate,
    this.lastSaveTime,
    this.backupIndexCounter,
    this.uncorrectedIndexRollover,
    this.correctedIndexRollover,
    this.showDot,
  );

  @override
  List<Object?> get props => [
    maxPress,
    maxPressDate,
    maxPressTime,
    minPress,
    minPressDate,
    minPressTime,
    maxTemp,
    maxTempDate,
    maxTempTime,
    minTemp,
    minTempDate,
    minTempTime,
    maxCaseTemp,
    minCaseTemp,
    uncPeakFlowRate,
    uncPeakFlowRateDate,
    uncPeakFlowRateTime,
    corLastSavedVol,
    uncLastSavedVol,
    lastSaveDate,
    lastSaveTime,
    backupIndexCounter,
    uncorrectedIndexRollover,
    correctedIndexRollover,
    showDot,
  ];
}
