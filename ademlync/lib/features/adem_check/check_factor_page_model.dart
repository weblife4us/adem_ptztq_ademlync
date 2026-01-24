import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class CheckFactorPageModel extends Equatable {
  final SuperXAlgo? superXAlgo;
  final double? gasSpecificGravity;
  final double? gasMoleCO2;
  final double? gasMoleH2;
  final double? gasMoleN2;
  final int? gasMoleHs;
  final FactorType? pressFactorType;
  final FactorType? tempFactorType;
  final FactorType? superXFactorType;
  final double? pressFactor;
  final double? tempFactor;
  final double? superXFactor;
  final double? corTotalFactor;
  final double? baseTemp;
  final double? basePress;
  final double? atmosphericPress;
  final DispVolSelect? dispVolSelect;

  const CheckFactorPageModel(
    this.superXAlgo,
    this.gasSpecificGravity,
    this.gasMoleCO2,
    this.gasMoleH2,
    this.gasMoleN2,
    this.gasMoleHs,
    this.pressFactorType,
    this.tempFactorType,
    this.superXFactorType,
    this.pressFactor,
    this.tempFactor,
    this.superXFactor,
    this.corTotalFactor,
    this.baseTemp,
    this.basePress,
    this.atmosphericPress,
    this.dispVolSelect,
  );

  @override
  List<Object?> get props => [
    superXAlgo,
    gasSpecificGravity,
    gasMoleCO2,
    gasMoleH2,
    gasMoleN2,
    gasMoleHs,
    pressFactorType,
    tempFactorType,
    superXFactorType,
    pressFactor,
    tempFactor,
    superXFactor,
    corTotalFactor,
    baseTemp,
    basePress,
    atmosphericPress,
    dispVolSelect,
  ];
}
