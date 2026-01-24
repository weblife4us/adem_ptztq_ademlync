import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import '../../utils/value_tracker.dart';

class SetupPressAndTempPageModel extends Equatable {
  final PressTransType? pressTxdrType;
  final ValueTracker<int>? pressTxdrSn;
  final ValueTracker<double>? pressTxdrRange;
  final ValueTracker<FactorType>? pressFactorType;
  final ValueTracker<double>? pressFactor;
  final double? gasAbsPress;
  final double? gasGaugePress;
  final ValueTracker<double>? pressHighLimit;
  final ValueTracker<double>? pressLowLimit;
  final ValueTracker<double>? atmosphericPress;
  final ValueTracker<double>? basePress;
  final ValueTracker<FactorType>? tempFactorType;
  final ValueTracker<double>? tempFactor;
  final double? gasTemp;
  final ValueTracker<double>? tempHighLimit;
  final ValueTracker<double>? tempLowLimit;
  final ValueTracker<double>? baseTemp;
  final ValueTracker<FactorType>? superXFactorType;
  final ValueTracker<double>? superXFactor;
  final ValueTracker<SuperXAlgo>? superXAlgo;
  final ValueTracker<double>? gasSpecificGravity;
  final ValueTracker<double>? gasMoleN2;
  final ValueTracker<double>? gasMoleH2;
  final ValueTracker<double>? gasMoleCO2;
  final ValueTracker<int>? gasMoleHs;
  final ValueTracker<double>? uncFlowrateHighLimit;
  final ValueTracker<double>? uncFlowrateLowLimit;

  const SetupPressAndTempPageModel(
    this.pressTxdrType,
    this.pressTxdrSn,
    this.pressTxdrRange,
    this.pressFactorType,
    this.pressFactor,
    this.gasAbsPress,
    this.gasGaugePress,
    this.pressHighLimit,
    this.pressLowLimit,
    this.atmosphericPress,
    this.basePress,
    this.tempFactorType,
    this.tempFactor,
    this.gasTemp,
    this.tempHighLimit,
    this.tempLowLimit,
    this.baseTemp,
    this.superXFactorType,
    this.superXFactor,
    this.superXAlgo,
    this.gasSpecificGravity,
    this.gasMoleN2,
    this.gasMoleH2,
    this.gasMoleCO2,
    this.gasMoleHs,
    this.uncFlowrateHighLimit,
    this.uncFlowrateLowLimit,
  );

  @override
  List<Object?> get props => [
    pressTxdrType,
    pressTxdrSn,
    pressTxdrRange,
    pressFactorType,
    pressFactor,
    gasAbsPress,
    gasGaugePress,
    pressHighLimit,
    pressLowLimit,
    atmosphericPress,
    basePress,
    tempFactorType,
    tempFactor,
    gasTemp,
    tempHighLimit,
    tempLowLimit,
    baseTemp,
    superXFactorType,
    superXFactor,
    superXAlgo,
    gasSpecificGravity,
    gasMoleN2,
    gasMoleH2,
    gasMoleCO2,
    gasMoleHs,
    uncFlowrateHighLimit,
    uncFlowrateLowLimit,
  ];
}
