import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

import '../../utils/value_tracker.dart';

class SetupDisplayPageModel extends Equatable {
  final ValueTracker<IntervalLogInterval>? intervalLogInterval;
  final ValueTracker<IntervalLogType>? intervalLogType;
  final List<ValueTracker<CustDispItem>?> cstmDispParams;
  final List<ValueTracker<IntervalLogField>?> intervalLogField;
  final ValueTracker<PulseChannel>? pulseChannel3;
  final ValueTracker<bool>? isProvingPulsesEnabled;
  final ValueTracker<int>? provingTimeout;
  final String? productType;
  final ValueTracker<bool>? isAdemR;
  final ValueTracker<double>? displacement;

  const SetupDisplayPageModel(
    this.intervalLogInterval,
    this.intervalLogType,
    this.cstmDispParams,
    this.intervalLogField,
    this.pulseChannel3,
    this.isProvingPulsesEnabled,
    this.provingTimeout,
    this.productType,
    this.isAdemR,
    this.displacement,
  );

  @override
  List<Object?> get props => [
    intervalLogInterval,
    intervalLogType,
    cstmDispParams,
    intervalLogField,
    pulseChannel3,
    isProvingPulsesEnabled,
    provingTimeout,
    productType,
    isAdemR,
    displacement,
  ];
}
