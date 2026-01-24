import 'package:equatable/equatable.dart';

class CheckQMonitorGroupPageModel extends Equatable {
  final bool? qMonitorFunction;
  final double? diffPress;
  final double? minAllowFlowRate;
  final String? dpSensorSn;
  final double? dpSensorRange;
  final double? lineGaugePress;
  final double? atmosphericPress;
  final double? dpTestPressure;
  final double? gasSpecificGravity;
  final bool? isDpTxdrMalf;
  final DateTime? dpTxdrMalfDate;
  final DateTime? dpTxdrMalfTime;
  final double? qCutoffTempLow;
  final double? qCutoffTempHigh;
  final double? qCoefficientA;
  final double? qCoefficientC;
  final double? diffUncertainty;
  final double? qSafetyMultiplier;

  const CheckQMonitorGroupPageModel(
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
