import 'package:equatable/equatable.dart';

import '../../utils/adem_param.dart';

class MeasureCache extends Equatable {
  final MeterSize? meterSize;
  final bool? isDotShowed;

  final VolumeUnit? uncVolUnit;
  final VolumeUnit? corVolUnit;
  final VolDigits? uncVolDigits;
  final VolDigits? corVolDigits;
  final DispVolSelect? dispVolSelect;

  final FactorType? superXFactorType;
  final SuperXAlgo? superXAlgorithm;

  final IntervalLogType intervalType;
  final IntervalLogInterval? intervalSetting;
  final List<IntervalLogField?>? intervalFields;

  final FactorType? pressFactorType;
  final PressUnit? pressUnit;
  final PressTransType? pressTransType;
  // NOTE: Not working from AdEM
  final DiffPressUnit? differentialPressureUnit;
  // NOTE: Not working from AdEM
  final LineGaugePressUnit? lineGaugePressureUnit;

  final FactorType? tempFactorType;
  final TempUnit? tempUnit;

  final InputPulseVolumeUnit? inputPulseVolUnit;
  final VolumeUnit? uncOutputPulseVolUnit;
  final VolumeUnit? corOutputPulseVolUnit;

  const MeasureCache({
    required this.meterSize,
    required this.isDotShowed,
    required this.uncVolUnit,
    required this.corVolUnit,
    required this.uncVolDigits,
    required this.corVolDigits,
    required this.dispVolSelect,
    required this.superXFactorType,
    required this.superXAlgorithm,
    required this.intervalType,
    required this.intervalSetting,
    required this.intervalFields,
    required this.pressFactorType,
    required this.pressUnit,
    required this.pressTransType,
    required this.differentialPressureUnit,
    required this.lineGaugePressureUnit,
    required this.tempFactorType,
    required this.tempUnit,
    required this.inputPulseVolUnit,
    required this.uncOutputPulseVolUnit,
    required this.corOutputPulseVolUnit,
  });

  MeasureCache copyWith({
    MeterSize? meterSize,
    bool? isDotShowed,
    VolumeUnit? uncVolUnit,
    VolumeUnit? corVolUnit,
    VolDigits? uncVolDigits,
    VolDigits? corVolDigits,
    DispVolSelect? dispVolSelect,
    FactorType? superXFactorType,
    SuperXAlgo? superXAlgorithm,
    IntervalLogType? intervalType,
    List<IntervalLogField?>? intervalFields,
    FactorType? pressFactorType,
    PressUnit? pressUnit,
    PressTransType? pressTransType,
    DiffPressUnit? differentialPressureUnit,
    LineGaugePressUnit? lineGaugePressureUnit,
    FactorType? tempFactorType,
    TempUnit? tempUnit,
    InputPulseVolumeUnit? inputPulseVolUnit,
    VolumeUnit? uncOutputPulseVolUnit,
    VolumeUnit? corOutputPulseVolUnit,
  }) => MeasureCache(
    meterSize: meterSize ?? this.meterSize,
    isDotShowed: isDotShowed ?? this.isDotShowed,
    uncVolUnit: uncVolUnit ?? this.uncVolUnit,
    corVolUnit: corVolUnit ?? this.corVolUnit,
    uncVolDigits: uncVolDigits ?? this.uncVolDigits,
    corVolDigits: corVolDigits ?? this.corVolDigits,
    dispVolSelect: dispVolSelect ?? this.dispVolSelect,
    superXFactorType: superXFactorType ?? this.superXFactorType,
    superXAlgorithm: superXAlgorithm ?? this.superXAlgorithm,
    intervalType: intervalType ?? this.intervalType,
    intervalSetting: intervalSetting,
    intervalFields: intervalFields ?? this.intervalFields,
    pressFactorType: pressFactorType ?? this.pressFactorType,
    pressUnit: pressUnit ?? this.pressUnit,
    pressTransType: pressTransType ?? this.pressTransType,
    differentialPressureUnit:
        differentialPressureUnit ?? this.differentialPressureUnit,
    lineGaugePressureUnit: lineGaugePressureUnit ?? this.lineGaugePressureUnit,
    tempFactorType: tempFactorType ?? this.tempFactorType,
    tempUnit: tempUnit ?? this.tempUnit,
    inputPulseVolUnit: inputPulseVolUnit ?? this.inputPulseVolUnit,
    uncOutputPulseVolUnit: uncOutputPulseVolUnit ?? this.uncOutputPulseVolUnit,
    corOutputPulseVolUnit: corOutputPulseVolUnit ?? this.corOutputPulseVolUnit,
  );

  @override
  List<Object?> get props => [
    meterSize,
    isDotShowed,
    uncVolUnit,
    corVolUnit,
    uncVolDigits,
    corVolDigits,
    dispVolSelect,
    superXFactorType,
    superXAlgorithm,
    intervalType,
    intervalSetting,
    intervalFields,
    pressFactorType,
    pressUnit,
    pressTransType,
    differentialPressureUnit,
    lineGaugePressureUnit,
    tempFactorType,
    tempUnit,
    inputPulseVolUnit,
    uncOutputPulseVolUnit,
    corOutputPulseVolUnit,
  ];
}
