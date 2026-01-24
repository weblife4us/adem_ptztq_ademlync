import 'dart:convert';
import 'dart:typed_data';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

import '../../utils/constants.dart';

class AdemConfig extends Equatable {
  final Map<Param, String> config;

  const AdemConfig(this.config);

  Map<Param, String> importableConfig(Adem adem) =>
      Map.from(config)
        ..removeWhere((k, v) => excludedAdemConfigParams(adem).contains(k));

  /// Converts the [AdemConfig] to a JSON-encoded [Uint8List].
  Uint8List toBytes() {
    final map = {for (final o in config.entries) o.key.toString(): o.value};
    return utf8.encode(jsonEncode(map));
  }

  /// Converts the [AdemConfig] to an [AdemConfigDetail] with a filename and [Adem] instance.
  AdemConfigDetail toDetail(String filename, Adem adem) {
    return AdemConfigDetail.from(config, filename, adem);
  }

  @override
  List<Object?> get props => [config];
}

class AdemConfigDetail extends AdemConfig {
  final String filename;
  final Set<ConfigConflict> conflicts;

  /// Extracts the firmware version from [validConfig].
  String get firmwareVersion {
    final version = config[Param.firmwareVersion];
    if (version == null) throw Exception('Firmware version is null');
    return version;
  }

  /// Returns true if there are any configuration conflicts.
  bool get isConflict => conflicts.isNotEmpty;

  const AdemConfigDetail(super.config, this.filename, this.conflicts);

  /// Creates an [AdemConfigDetail] from raw data, filename, and [Adem] instance.
  factory AdemConfigDetail.from(
    Map<Param, String> rawData,
    String filename,
    Adem adem,
  ) {
    final conflicts = _checkCompatibility(adem, rawData);
    return AdemConfigDetail(rawData, filename, conflicts);
  }
}

enum ConfigConflict {
  ademTypeUnsupported,
  firmwareMissing,
  productTypeMissing,
  ademTypeMismatch,
  meterSizeMissing,
  inputPulseVolUnitMissing,
  meterSystemMismatch,
  outputPulseVolUnitMissing,
  outputPulseVolUnitMismatch,
  pressTransTypeMissing,
  pressTransTypeMismatch;

  String get text => switch (this) {
    ConfigConflict.ademTypeUnsupported => 'AdEM Type Unsupported',
    ConfigConflict.firmwareMissing => 'Firmware Missing',
    ConfigConflict.productTypeMissing => 'Product Type Missing',
    ConfigConflict.ademTypeMismatch => 'AdEM Type Mismatch',
    ConfigConflict.meterSizeMissing => 'Meter Size Missing',
    ConfigConflict.inputPulseVolUnitMissing =>
      'Input Pulse Volume Unit Missing',
    ConfigConflict.meterSystemMismatch => 'Measurement System Mismatch',
    ConfigConflict.outputPulseVolUnitMissing =>
      'Output Pulse Volume Unit Missing',
    ConfigConflict.outputPulseVolUnitMismatch =>
      'Output Pulse Volume Unit Mismatch with Meter Size',
    ConfigConflict.pressTransTypeMissing => 'Pressure Transducer Type Missing',
    ConfigConflict.pressTransTypeMismatch =>
      'Pressure Transducer Type Mismatch',
  };
}

Set<ConfigConflict> _checkCompatibility(Adem adem, Map<Param, String> config) {
  // Check for compatibility issues by invoking specific check functions
  // Collect all conflicts found and return them as a set
  return {
    _checkAdemType(adem, config),
    adem.isMeterSizeSupported
        ? _checkMeterSize(adem, config)
        : _checkInputPulseVolUnit(adem, config),
    _checkPressTransType(adem, config),
  }.whereType<ConfigConflict>().toSet();
}

ConfigConflict? _checkAdemType(Adem adem, Map<Param, String> config) {
  // Ensure firmware version found.
  final firmwareData = config[Param.firmwareVersion];
  if (firmwareData == null) return ConfigConflict.firmwareMissing;

  // Ensure produce type found for AdEM 25.
  String? productType;
  if (adem.isAdem25) {
    productType = config[Param.productType];
    if (productType == null) return ConfigConflict.productTypeMissing;
  }

  try {
    // Ensure AdEM type supported and match.
    if (adem.type != AdemType.from(firmwareData, productType)) {
      return ConfigConflict.ademTypeMismatch;
    }
  } catch (_) {
    return ConfigConflict.ademTypeUnsupported;
  }

  return null;
}

ConfigConflict? _checkMeterSize(Adem adem, Map<Param, String> config) {
  // Ensure meter size found.
  final size = MeterSize.from(config[Param.meterSize]);
  if (size == null) return ConfigConflict.meterSizeMissing;

  // Ensure meter system match.
  if (adem.meterSystem != size.serial.system) {
    return ConfigConflict.meterSystemMismatch;
  }

  // Get the available output pulse volume unit based on the meter size from configuration, instead of the current AdEM.
  // The meter size is importable and will replace the current AdEM value.
  return _checkOutputPulseVolUnits(config, size.optPulseVolUnits);
}

ConfigConflict? _checkInputPulseVolUnit(Adem adem, Map<Param, String> config) {
  // Ensure input pulse volume found.
  final unit = InputPulseVolumeUnit.from(config[Param.inputPulseVolUnit]);
  if (unit == null) return ConfigConflict.inputPulseVolUnitMissing;

  // Ensure meter system match.
  if (adem.meterSystem != unit.meterSystem) {
    return ConfigConflict.meterSystemMismatch;
  }

  // Get the available output pulse volume unit based on the input pulse volume unit from configuration, instead of the current AdEM.
  // The input pulse volume unit is importable and will replace the current AdEM value.
  return _checkOutputPulseVolUnits(config, unit.optPulseVolUnits);
}

ConfigConflict? _checkOutputPulseVolUnits(
  Map<Param, String> config,
  List<VolumeUnit> availableUnits,
) {
  // Ensure cor and unc output pulse volume unit found.
  final corUnit = VolumeUnit.from(config[Param.corOutputPulseVolUnit]);
  final uncUnit = VolumeUnit.from(config[Param.uncOutputPulseVolUnit]);
  if (corUnit == null || uncUnit == null) {
    return ConfigConflict.outputPulseVolUnitMissing;
  }

  // Ensure cor and unc output pulse volume valid.
  if (!availableUnits.contains(corUnit) || !availableUnits.contains(uncUnit)) {
    return ConfigConflict.outputPulseVolUnitMismatch;
  }

  return null;
}

ConfigConflict? _checkPressTransType(Adem adem, Map<Param, String> config) {
  // Ensure pressure transducer type found.
  final typeData = config[Param.pressTransType];
  if (typeData == null) return null;

  // Ensure pressure transducer type valid.
  final type = PressTransType.from(typeData);
  if (adem.pressTransType != type) return ConfigConflict.pressTransTypeMismatch;

  return null;
}
