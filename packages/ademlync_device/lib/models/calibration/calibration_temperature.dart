part of 'calibration.dart';

class TempCalib extends Calibration {
  final double temp;

  const TempCalib(super.aDReadCounts, this.temp);

  @override
  List<Object?> get props => [aDReadCounts, temp];
}

class TempCalib1Pt extends TempCalib {
  final double offset;

  const TempCalib1Pt(super.aDReadCounts, super.temp, this.offset);

  @override
  List<Object?> get props => [aDReadCounts, temp, offset];
}

class TempCalib3Pt extends TempCalib {
  final Calib3PtConfig config;

  const TempCalib3Pt(super.aDReadingCts, super.temp, this.config);

  @override
  List<Object?> get props => [aDReadCounts, temp, config];
}
