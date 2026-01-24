part of 'calibration.dart';

class DpCalib extends Calibration {
  final double dp;

  const DpCalib(super.aDReadCounts, this.dp);

  @override
  List<Object?> get props => [aDReadCounts, dp];
}

class DpCalib1Pt extends DpCalib {
  final double offset;

  const DpCalib1Pt(super.aDReadCounts, super.dp, this.offset);

  @override
  List<Object?> get props => [aDReadCounts, dp, offset];
}

class DpCalib3Pt extends DpCalib {
  final Calib3PtConfig config;

  const DpCalib3Pt(super.aDReadingCts, super.dp, this.config);

  @override
  List<Object?> get props => [aDReadCounts, dp, config];
}
