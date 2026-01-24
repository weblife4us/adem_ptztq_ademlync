import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class CheckBatteryPageModel extends Equatable {
  final double? batteryVoltage;
  final BatteryType? batteryType;
  final DateTime? batteryInstallDate;
  final int? batteryLife;
  final int? batteryRemaining;
  final String? dispTestPattern;
  final PressDispRes? pressDispRes;
  final OutPulseSpacing? outputPulseSpacing;
  final OutPulseWidth? outputPulseWidth;
  final VolumeUnit? corOutputPulseVolUnit;
  final VolumeUnit? uncOutputPulseVolUnit;

  const CheckBatteryPageModel(
    this.batteryVoltage,
    this.batteryType,
    this.batteryInstallDate,
    this.batteryLife,
    this.batteryRemaining,
    this.dispTestPattern,
    this.pressDispRes,
    this.outputPulseSpacing,
    this.outputPulseWidth,
    this.corOutputPulseVolUnit,
    this.uncOutputPulseVolUnit,
  );

  @override
  List<Object?> get props => [
    batteryVoltage,
    batteryType,
    batteryInstallDate,
    batteryLife,
    batteryRemaining,
    dispTestPattern,
    pressDispRes,
    outputPulseSpacing,
    outputPulseWidth,
    corOutputPulseVolUnit,
    uncOutputPulseVolUnit,
  ];
}
