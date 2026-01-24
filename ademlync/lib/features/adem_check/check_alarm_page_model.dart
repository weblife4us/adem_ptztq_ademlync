import 'package:equatable/equatable.dart';

class CheckAlarmPageModel extends Equatable {
  final bool? isAlarmOutput;
  final bool? isPressTxdrMalf;
  final bool? isPressHigh;
  final bool? isPressLow;
  final double? pressHighLimit;
  final double? pressLowLimit;
  final DateTime? pressMalfDate;
  final DateTime? pressMalfTime;
  final bool? isTempTxdrMalf;
  final bool? isTempHigh;
  final bool? isTempLow;
  final double? tempHighLimit;
  final double? tempLowLimit;
  final DateTime? tempMalfDate;
  final DateTime? tempMalfTime;
  final bool? isBatteryMalf;
  final DateTime? batteryMalfDate;
  final DateTime? batteryMalfTime;
  final bool? isMemoryError;
  final DateTime? memoryErrorDate;
  final DateTime? memoryErrorTime;
  final int? uncVolSinceMalf;
  final bool? isUncFlowRateHigh;
  final bool? isUncFlowRateLow;
  final double? uncFlowrate;
  final double? uncFlowRateHighLimit;
  final double? uncFlowRateLowLimit;

  const CheckAlarmPageModel(
    this.isAlarmOutput,
    this.isPressTxdrMalf,
    this.isPressHigh,
    this.isPressLow,
    this.pressHighLimit,
    this.pressLowLimit,
    this.pressMalfDate,
    this.pressMalfTime,
    this.isTempTxdrMalf,
    this.isTempHigh,
    this.isTempLow,
    this.tempHighLimit,
    this.tempLowLimit,
    this.tempMalfDate,
    this.tempMalfTime,
    this.isBatteryMalf,
    this.batteryMalfDate,
    this.batteryMalfTime,
    this.isMemoryError,
    this.memoryErrorDate,
    this.memoryErrorTime,
    this.uncVolSinceMalf,
    this.isUncFlowRateHigh,
    this.isUncFlowRateLow,
    this.uncFlowrate,
    this.uncFlowRateHighLimit,
    this.uncFlowRateLowLimit,
  );

  @override
  List<Object?> get props => [
    isAlarmOutput,
    isPressTxdrMalf,
    isPressHigh,
    isPressLow,
    pressHighLimit,
    pressLowLimit,
    pressMalfDate,
    pressMalfTime,
    isTempTxdrMalf,
    isTempHigh,
    isTempLow,
    tempHighLimit,
    tempLowLimit,
    tempMalfDate,
    tempMalfTime,
    isBatteryMalf,
    batteryMalfDate,
    batteryMalfTime,
    isMemoryError,
    memoryErrorDate,
    memoryErrorTime,
    uncVolSinceMalf,
    isUncFlowRateHigh,
    isUncFlowRateLow,
    uncFlowrate,
    uncFlowRateHighLimit,
    uncFlowRateLowLimit,
  ];
}
