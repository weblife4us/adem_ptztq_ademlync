import 'package:equatable/equatable.dart';

import '../../ademlync_device.dart';

part 'calibration_3_point_config.dart';
part 'calibration_dp.dart';
part 'calibration_pressure.dart';
part 'calibration_temperature.dart';

class Calibration extends Equatable {
  final int aDReadCounts;

  const Calibration(this.aDReadCounts);

  @override
  List<Object?> get props => [aDReadCounts];
}
