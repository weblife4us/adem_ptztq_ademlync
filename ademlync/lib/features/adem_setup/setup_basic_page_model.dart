import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

import '../../utils/value_tracker.dart';

class SetupBasicPageModel extends Equatable {
  final ValueTracker<DateTime>? gasDayStartTime;
  final ValueTracker<DispVolSelect>? dispVolSelect;
  final ValueTracker<MeterSize>? meterSize;
  final ValueTracker<MeterSerial>? meterSerial;
  final ValueTracker<MeterSystem>? meterSystem;
  final ValueTracker<int>? corVol;
  final num? fullCorVol;
  final ValueTracker<VolumeUnit>? corVolUnit;
  final ValueTracker<VolDigits>? corVolDigits;
  final ValueTracker<int>? uncVol;
  final num? fullUncVol;
  final ValueTracker<VolumeUnit>? uncVolUnit;
  final ValueTracker<VolDigits>? uncVolDigits;
  final ValueTracker<InputPulseVolumeUnit>? inputPulseVolUnit;
  final ValueTracker<OutPulseSpacing>? outPulseSpacing;
  final ValueTracker<OutPulseWidth>? outPulseWidth;
  final ValueTracker<VolumeUnit>? corOutputPulseVolUnit;
  final ValueTracker<VolumeUnit>? uncOutputPulseVolUnit;
  final ValueTracker<PressUnit>? pressUnit;
  final TempUnit? tempUnit;

  const SetupBasicPageModel(
    this.gasDayStartTime,
    this.dispVolSelect,
    this.meterSize,
    this.meterSerial,
    this.meterSystem,
    this.corVol,
    this.fullCorVol,
    this.corVolUnit,
    this.corVolDigits,
    this.uncVol,
    this.fullUncVol,
    this.uncVolUnit,
    this.uncVolDigits,
    this.inputPulseVolUnit,
    this.outPulseSpacing,
    this.outPulseWidth,
    this.corOutputPulseVolUnit,
    this.uncOutputPulseVolUnit,
    this.pressUnit,
    this.tempUnit,
  );

  @override
  List<Object?> get props => [
    gasDayStartTime,
    dispVolSelect,
    meterSize,
    meterSerial,
    meterSystem,
    corVol,
    fullCorVol,
    corVolUnit,
    corVolDigits,
    uncVol,
    fullUncVol,
    uncVolUnit,
    uncVolDigits,
    inputPulseVolUnit,
    outPulseSpacing,
    outPulseWidth,
    corOutputPulseVolUnit,
    uncOutputPulseVolUnit,
    pressUnit,
    tempUnit,
  ];
}
