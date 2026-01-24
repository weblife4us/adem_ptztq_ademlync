import 'package:equatable/equatable.dart';

import '../../utils/value_tracker.dart';

class SetupStatisticsPageModel extends Equatable {
  final ValueTracker<double>? peakUncFlowRate;
  final DateTime? peakUncFlowrateDateTime;
  final ValueTracker<double>? maxGasPress;
  final DateTime? maxPressDateTime;
  final ValueTracker<double>? minGasPress;
  final DateTime? minPressDateTime;
  final ValueTracker<double>? maxGasTemp;
  final DateTime? maxTempDateTime;
  final ValueTracker<double>? minGasTemp;
  final DateTime? minTempDateTime;
  final ValueTracker<double>? maxCaseTemp;
  final ValueTracker<double>? minCaseTemp;
  final ValueTracker<int>? provingVol;
  final ValueTracker<int>? backupIdxCtr;
  final ValueTracker<bool>? isDotShowed;

  const SetupStatisticsPageModel(
    this.peakUncFlowRate,
    this.peakUncFlowrateDateTime,
    this.maxGasPress,
    this.maxPressDateTime,
    this.minGasPress,
    this.minPressDateTime,
    this.maxGasTemp,
    this.maxTempDateTime,
    this.minGasTemp,
    this.minTempDateTime,
    this.maxCaseTemp,
    this.minCaseTemp,
    this.provingVol,
    this.backupIdxCtr,
    this.isDotShowed,
  );

  @override
  List<Object?> get props => [
    peakUncFlowRate,
    peakUncFlowrateDateTime,
    maxGasPress,
    maxPressDateTime,
    minGasPress,
    minPressDateTime,
    maxGasTemp,
    maxTempDateTime,
    minGasTemp,
    minTempDateTime,
    maxCaseTemp,
    minCaseTemp,
    provingVol,
    backupIdxCtr,
    isDotShowed,
  ];
}
