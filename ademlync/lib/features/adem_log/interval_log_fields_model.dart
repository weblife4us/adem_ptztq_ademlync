import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class IntervalLogFields extends Equatable {
  final bool hasTotalCorVol;
  final bool hasTotalUncVol;
  final bool hasAvgTotalFactor;
  final bool hasAvgUncFlowRate;
  final bool hasMaxPress;
  final bool hasMaxPressTime;
  final bool hasMinPress;
  final bool hasMinPressTime;
  final bool hasMaxTemp;
  final bool hasMaxTempTime;
  final bool hasMinTemp;
  final bool hasMinTempTime;
  final bool hasMaxUncFlowrate;
  final bool hasMaxUncFlowrateTime;
  final bool hasMinUncFlowrate;
  final bool hasMinUncFlowrateTime;
  final bool hasAvgBatteryVoltage;
  // final bool hasSuperXFactor;
  // final bool hasUncVolSinceMalf;

  IntervalLogFields(Set<IntervalLogField> set)
    : hasTotalCorVol = set.contains(IntervalLogField.corTotalVol),
      hasTotalUncVol = set.contains(IntervalLogField.uncTotalVol),
      hasAvgTotalFactor = set.contains(IntervalLogField.avgTotalFactor),
      hasAvgUncFlowRate = set.contains(IntervalLogField.uncAvgFlowRate),
      hasMaxPress = set.contains(IntervalLogField.maxPress),
      hasMaxPressTime = set.contains(IntervalLogField.maxPressTime),
      hasMinPress = set.contains(IntervalLogField.minPress),
      hasMinPressTime = set.contains(IntervalLogField.minPressTime),
      hasMaxTemp = set.contains(IntervalLogField.maxTemp),
      hasMaxTempTime = set.contains(IntervalLogField.maxTempTime),
      hasMinTemp = set.contains(IntervalLogField.minTemp),
      hasMinTempTime = set.contains(IntervalLogField.minTempTime),
      hasMaxUncFlowrate = set.contains(IntervalLogField.uncMaxFlowRate),
      hasMaxUncFlowrateTime = set.contains(IntervalLogField.uncMaxFlowRateTime),
      hasMinUncFlowrate = set.contains(IntervalLogField.uncMinFlowRate),
      hasMinUncFlowrateTime = set.contains(IntervalLogField.uncMinFlowRateTime),
      hasAvgBatteryVoltage = set.contains(IntervalLogField.avgBatteryVoltage);
  // hasSuperXFactor = set.contains(IntervalField.superXFactor),
  // hasUncVolSinceMalf = set.contains(IntervalField.uncVolSinceMalf);

  @override
  List<Object?> get props => [
    hasTotalCorVol,
    hasTotalUncVol,
    hasAvgUncFlowRate,
    hasMaxPress,
    hasMaxPressTime,
    hasMinPress,
    hasMinPressTime,
    hasMaxTemp,
    hasMaxTempTime,
    hasMinTemp,
    hasMinTempTime,
    hasMaxUncFlowrate,
    hasMaxUncFlowrateTime,
    hasMinUncFlowrate,
    hasMinUncFlowrateTime,
    hasAvgBatteryVoltage,
    hasAvgTotalFactor,
    // hasSuperXFactor,
    // hasUncVolSinceMalf,
  ];
}
