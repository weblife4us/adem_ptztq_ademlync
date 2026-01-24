import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class CheckBasicPageModel extends Equatable {
  final String? firmwareVersion;
  final String? firmwareChecksum;
  final bool? sealStatus;
  final DateTime? gasDayStartTime;
  final MeterSize? meterSize;
  final InputPulseVolumeUnit? inputPulseVolUnit;
  final int? corVol;
  final num? corFullVol;
  final double? corHighResVol;
  final int? corDailyVol;
  final int? corPrevDayVol;
  final int? uncVol;
  final num? uncFullVol;
  final double? uncHighResVol;
  final int? uncDailyVol;
  final int? uncPrevDayVol;
  final PressTransType? pressTransType;
  final int? pressTransSn;
  final double? pressTransRange;
  final double? absPress;
  final double? gaugePress;
  final double? temp;
  final double? caseTemp;
  final double? corFlowRate;
  final double? uncFlowRate;
  final PressUnit? pressUnit;
  final TempUnit? tempUnit;
  final VolumeUnit? corVolUnit;
  final VolumeUnit? uncVolUnit;
  final VolDigits? corVolDigits;
  final VolDigits? uncVolDigits;

  const CheckBasicPageModel(
    this.firmwareVersion,
    this.firmwareChecksum,
    this.sealStatus,
    this.gasDayStartTime,
    this.meterSize,
    this.inputPulseVolUnit,
    this.corVol,
    this.corFullVol,
    this.corHighResVol,
    this.corDailyVol,
    this.corPrevDayVol,
    this.uncVol,
    this.uncFullVol,
    this.uncHighResVol,
    this.uncDailyVol,
    this.uncPrevDayVol,
    this.pressTransType,
    this.pressTransSn,
    this.pressTransRange,
    this.absPress,
    this.gaugePress,
    this.temp,
    this.caseTemp,
    this.corFlowRate,
    this.uncFlowRate,
    this.pressUnit,
    this.tempUnit,
    this.corVolUnit,
    this.uncVolUnit,
    this.corVolDigits,
    this.uncVolDigits,
  );

  @override
  List<Object?> get props => [
    firmwareVersion,
    firmwareChecksum,
    sealStatus,
    gasDayStartTime,
    meterSize,
    inputPulseVolUnit,
    corVol,
    corFullVol,
    corHighResVol,
    corDailyVol,
    corPrevDayVol,
    uncVol,
    uncFullVol,
    uncHighResVol,
    uncDailyVol,
    uncPrevDayVol,
    pressTransType,
    pressTransSn,
    pressTransRange,
    absPress,
    gaugePress,
    temp,
    caseTemp,
    corFlowRate,
    uncFlowRate,
    pressUnit,
    tempUnit,
    corVolUnit,
    uncVolUnit,
    corVolDigits,
    uncVolDigits,
  ];
}
