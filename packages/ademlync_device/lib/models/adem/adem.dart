import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../ademlync_device.dart';
import '../../controllers/cache_manager.dart';
import '../log/daily_log_params.dart';
import '../log/interval_log_params.dart';
import '../modules/push_button_module.dart';
import 'config_cache.dart';
import 'measure_cache.dart';

part 'unit.dart';

class Adem extends Unit {
  const Adem(
    super.serialNumber,
    super.serialNumberPart2,
    super.productType,
    super.firmwareVersion,
    super.firmwareChecksum,
    super.siteName,
    super.siteAddress,
    super.customerId,
    super.date,
    super.time,
  );

  static final _cache = CacheManager();

  ConfigCache get configCache => _cache.getConfig();
  MeasureCache get measureCache => _cache.getMeasure();
  PushButtonModule get pushButtonModule => _cache.getPushButtonModule();

  Adem copyWith({
    String? serialNumber,
    String? serialNumberPart2,
    String? productType,
    String? siteName,
    String? siteAddress,
    String? customerId,
    DateTime? date,
    DateTime? time,
  }) => Adem(
    serialNumber ?? this.serialNumber,
    serialNumberPart2 ?? this.serialNumberPart2,
    productType ?? this.productType,
    firmwareVersion,
    firmwareChecksum,
    siteName ?? this.siteName,
    siteAddress ?? this.siteAddress,
    customerId ?? this.customerId,
    date ?? this.date,
    time ?? this.time,
  );

  bool get isMeterSizeSupported => type.isMeterSizeSupported;

  /// Get the meter size
  MeterSize? get meterSize {
    MeterSize? res;

    if (isMeterSizeSupported) {
      final meterSize = measureCache.meterSize;

      if (meterSize == null) {
        throw Exception('Cannot get meter size');
      } else {
        res = meterSize;
      }
    }

    return res;
  }

  InputPulseVolumeUnit? get inputPulseVolUnit => measureCache.inputPulseVolUnit;

  /// Get the measurement system
  MeterSystem get meterSystem =>
      (isMeterSizeSupported
          ? meterSize?.serial.system
          : inputPulseVolUnit?.meterSystem) ??
      (throw Exception('Cannot get measurement system'));

  /// Get the max flow rate
  num get maxFlowRate => isMeterSizeSupported
      ? meterSize!.maxFlowRate
      : switch (meterSystem) {
          MeterSystem.imperial => 265000,
          MeterSystem.metric => 7500.00,
        };

  /// Get the volume type
  VolumeType get volumeType => meterSystem.toVolumeType;

  /// Get the flow rate type
  FlowRateType get flowRateType => meterSystem.toFlowRateType;

  /// Get the pressure unit
  PressUnit? get pressUnit => measureCache.pressUnit;

  /// Get the pressure transducer type
  PressTransType? get pressTransType => measureCache.pressTransType;

  /// Get the temp unit
  TempUnit? get tempUnit => measureCache.tempUnit;

  /// Get the Dp unit
  DiffPressUnit? get differentialPressureUnit {
    return measureCache.differentialPressureUnit;
  }

  /// Get the line gauge pressure unit
  LineGaugePressUnit? get lineGaugePressureUnit {
    return measureCache.lineGaugePressureUnit;
  }

  /// Determine if the AdEM is sealed
  bool get isSealed => configCache.isSealed;

  /// Determine if the AdEM is Aga8 algorithm
  bool get isAga8Algorithm => measureCache.superXAlgorithm == SuperXAlgo.aga8;

  /// Get the adem date time
  DateTime get dateTime =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Get the pressure factor type
  FactorType? get pressFactorType => measureCache.pressFactorType;

  /// Get the temperature factor type
  FactorType? get tempFactorType => measureCache.tempFactorType;

  /// Get the super x factor type
  FactorType? get superXFactorType => measureCache.superXFactorType;

  /// Get custom display params
  Set<CustDispItem> get customDisplayParams {
    final params = switch (type) {
      AdemType.ademS => customDisplayParamsAdemS(firmwareVersion),
      AdemType.ademT => customDisplayParamsAdemT(firmwareVersion),
      AdemType.universalT => customDisplayParamsUniversalT(firmwareVersion),
      AdemType.ademTq => customDisplayParamsAdemTq,
      AdemType.ademPtz => customDisplayParamsAdemPtz(firmwareVersion),
      AdemType.ademPtzR ||
      AdemType.ademR ||
      AdemType.ademMi => customDisplayParamsAdemPtzr,
    };

    final unknownItems = <int>{};
    final res = <CustDispItem>{};

    for (var e in params) {
      final param = CustDispItem.fromItemNumber(e);
      param == CustDispItem.notSet ? unknownItems.add(e) : res.add(param);
    }

    if (kDebugMode) print('Unsupported params: $unknownItems');

    return res;
  }

  /// Determine fixed 4 fields interval log
  bool get isF4FIntervalLog =>
      measureCache.intervalType == IntervalLogType.fixed4Fields;

  /// Determine selectable fields interval log
  bool get isSFIntervalLog =>
      measureCache.intervalType == IntervalLogType.selectableFields;

  /// Determine full fields interval log
  bool get isFFIntervalLog =>
      measureCache.intervalType == IntervalLogType.fullFields;

  /// Determine absolute press transducer
  bool get isAbsPressTrans =>
      measureCache.pressTransType == PressTransType.absolute;

  bool checkProtectedBySeal(Param param) {
    return sealProtectedParams.contains(param.key);
  }

  /// Get available daily log params
  DailyLogParams get dailyLogParams => switch (type) {
    AdemType.ademS => dailyLogParamsAdemS,
    AdemType.ademT => dailyLogParamsAdemT,
    AdemType.universalT => dailyLogParamsUniversalT,
    AdemType.ademTq => dailyLogParamsAdemTq,
    AdemType.ademPtz => dailyLogParamsAdemPtz,
    AdemType.ademPtzR ||
    AdemType.ademR ||
    AdemType.ademMi => dailyLogParamsAdemPtzr,
  };

  /// Get available interval log params
  IntervalLogParams get intervalLogParams => switch (type) {
    AdemType.ademS => intervalLogParamsAdemS,
    AdemType.ademT => intervalLogParamsAdemT,
    AdemType.universalT => intervalLogParamsUniversalT,
    AdemType.ademTq => intervalLogParamsAdemTq,
    AdemType.ademPtz => intervalLogParamsAdemPtz,
    AdemType.ademPtzR ||
    AdemType.ademR ||
    AdemType.ademMi => intervalLogParamsAdemPtzr,
  };

  /// Determines if the device qualifies as an AdEM25 model.
  /// The firmware version starts with `E`.
  bool get isAdem25 => firmwareVersion.startsWith('E');

  /// Returns `true` if the device is pressure-only (`POnly`).
  /// Applies to `AdEMPtz` or `AdEMPtzR` types where:
  /// - `pressFactorType` is `live`
  /// - `tempFactorType` is `fixed`
  bool get isPOnly =>
      (type.isAdemPtz || type.isAdemPtzR || type.isAdemR || type.isAdemMi) &&
      pressFactorType == FactorType.live &&
      tempFactorType == FactorType.fixed;

  /// Returns `true` if the device is temperature-only (`TOnly`).
  /// E firmware not support T-only
  /// Applies to `AdEMPtz` or `AdEMPtzR` types where:
  /// - `pressFactorType` is `fixed`
  /// - `tempFactorType` is `live`
  bool get isTOnly =>
      !isAdem25 &&
      (type.isAdemPtz || type.isAdemPtzR) &&
      pressFactorType == FactorType.fixed &&
      tempFactorType == FactorType.live;

  /// Determines if AdEM-Tq supports FLOWDP and QLOG based on firmware version.
  /// - Supported:
  ///   - Firmware starting with 'E' (e.g., E010RQ17 for ADEM-25 and later).
  ///   - Firmware starting with 'D' with suffix ≥ 47 (e.g., D060MQ47, D060MQ57, D060MQ67).
  /// - Not supported:
  ///   - Firmware starting with 'D' with suffix < 47 (e.g., D060MQ37, D060MQ27, D060MQ17).
  bool get hasTqLog => type.isAdemTq
      ? meetsMinFirmwareVersion(
          firmwareVersion,
          minMajor: 'D',
          minMinor: 6,
          minPatch: 4,
        )
      : false;

  /// Determines if AdEM firmware supports warning, excluding specific legacy versions.
  /// Excludes:
  /// - Legacy ADEM-PTZ: D06XM004 (X = S, N, A, G)
  /// - Legacy ADEM-T: D060RT03
  /// - Legacy ADEM-TQ: D060MQ67
  /// - Legacy UNIVERSAL-T: D060MT03
  /// - ADEM25 units with 'E' firmware versions.
  bool get hasPressureFactorTypeChangeWarning => isAdem25
      ? false
      : switch (type) {
          AdemType.ademS => true,
          AdemType.ademT => !meetsMinFirmwareVersion(
            firmwareVersion,
            minMajor: 'D',
            minMinor: 6,
          ),
          AdemType.universalT => !meetsMinFirmwareVersion(
            firmwareVersion,
            minMajor: 'D',
            minMinor: 6,
          ),
          AdemType.ademTq => !meetsMinFirmwareVersion(
            firmwareVersion,
            minMajor: 'D',
            minMinor: 6,
            minPatch: 6,
          ),
          AdemType.ademPtz => !meetsMinFirmwareVersion(
            firmwareVersion,
            minMajor: 'D',
            minMinor: 6,
          ),
          AdemType.ademPtzR || AdemType.ademR || AdemType.ademMi => true,
        };

  String get displayName {
    return switch (type) {
      AdemType.ademS => 'AdEM S',
      AdemType.ademT => 'AdEM T',
      AdemType.universalT => 'Universal T',
      AdemType.ademTq => 'AdEM Tq',
      AdemType.ademPtz => 'AdEM PTZ',
      AdemType.ademPtzR => 'AdEM PTZ-r',
      AdemType.ademR => 'AdEM R',
      AdemType.ademMi => 'AdEM Mi',
    };
  }
}
