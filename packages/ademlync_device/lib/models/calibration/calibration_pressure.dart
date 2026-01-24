part of 'calibration.dart';

class PressCalib extends Calibration {
  final double press;
  final double pressTransRange;

  const PressCalib(super.aDReadCounts, this.press, this.pressTransRange);

  @override
  List<Object?> get props => [aDReadCounts, press, pressTransRange];
}

class PressCalib1Pt extends PressCalib {
  final double offset;

  const PressCalib1Pt(
    super.aDReadCounts,
    super.press,
    super.pressTransRange,
    this.offset,
  );

  @override
  List<Object?> get props => [aDReadCounts, press, pressTransRange, offset];
}

class PressCalib3Pt extends PressCalib {
  final Calib3PtConfig config;

  const PressCalib3Pt(
    super.aDReadingCts,
    super.press,
    super.pressTransRange,
    this.config,
  );

  @override
  List<Object?> get props => [aDReadCounts, press, pressTransRange, config];
}
