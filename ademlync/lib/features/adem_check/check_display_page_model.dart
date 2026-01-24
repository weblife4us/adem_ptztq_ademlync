import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class CheckDisplayPageModel extends Equatable {
  final IntervalLogInterval? intervalSetting;
  final IntervalLogType? intervalType;
  final List<CustDispItem?> cstmDispParams;
  final List<IntervalLogField?>? intervalFields;
  final List<PulseChannel?> pulseChannels;
  final double? displacement;
  final bool? isProvingPulsesEnabled;
  final int? provingTimeout;
  final String? productType;

  const CheckDisplayPageModel(
    this.intervalSetting,
    this.intervalType,
    this.cstmDispParams,
    this.intervalFields,
    this.pulseChannels,
    this.displacement,
    this.isProvingPulsesEnabled,
    this.provingTimeout,
    this.productType,
  );

  @override
  List<Object?> get props => [
    intervalSetting,
    intervalType,
    cstmDispParams,
    intervalFields,
    pulseChannels,
    displacement,
    isProvingPulsesEnabled,
    provingTimeout,
    productType,
  ];
}
