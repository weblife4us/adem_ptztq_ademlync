import 'package:equatable/equatable.dart';

import '../../utils/value_tracker.dart';

class SetupQMonitorGroupPageModel extends Equatable {
  final bool? qMonitorFunction;
  final double? diffPress;
  final double? minAllowFlowRate;
  final String? dpSensorSn;
  final double? dpSensorRange;
  final ValueTracker<double>? lineGaugePress;
  final ValueTracker<double>? atmosphericPress;
  final double? dpTestPressure;
  final ValueTracker<double>? gasSpecificGravity;
  final bool? isDpTxdrMalf;
  final DateTime? dpTxdrMalfDate;
  final DateTime? dpTxdrMalfTime;
  final ValueTracker<double>? qCutoffTempLow;
  final ValueTracker<double>? qCutoffTempHigh;
  final double? qCoefficientA;
  final double? qCoefficientC;
  final ValueTracker<double>? diffUncertainty;
  final double? qSafetyMultiplier;

  const SetupQMonitorGroupPageModel(
    this.qMonitorFunction,
    this.diffPress,
    this.minAllowFlowRate,
    this.dpSensorSn,
    this.dpSensorRange,
    this.lineGaugePress,
    this.atmosphericPress,
    this.dpTestPressure,
    this.gasSpecificGravity,
    this.isDpTxdrMalf,
    this.dpTxdrMalfDate,
    this.dpTxdrMalfTime,
    this.qCutoffTempLow,
    this.qCutoffTempHigh,
    this.qCoefficientA,
    this.qCoefficientC,
    this.diffUncertainty,
    this.qSafetyMultiplier,
  );

  @override
  List<Object?> get props => [
    qMonitorFunction,
    diffPress,
    minAllowFlowRate,
    dpSensorSn,
    dpSensorRange,
    lineGaugePress,
    atmosphericPress,
    dpTestPressure,
    gasSpecificGravity,
    isDpTxdrMalf,
    dpTxdrMalfDate,
    dpTxdrMalfTime,
    qCutoffTempLow,
    qCutoffTempHigh,
    qCoefficientA,
    qCoefficientC,
    diffUncertainty,
    qSafetyMultiplier,
  ];
}
