import 'dart:convert';

import 'adem_param.dart';
import 'communication_enums.dart';
import 'constants.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T e) test) {
    for (var e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

/// Calculates the CRC-16-CCITT checksum for a list of bytes.
/// !!! Input is bytes, not hex.
String crcCalculation(List<int> bytes) {
  // CRC-16-CCITT polynomial
  const polynomial = 0x1021;
  // Initial value
  const initial = 0x0000;

  // Start with 16-bit initial value
  int crc = initial & 0xFFFF;

  for (final byte in bytes) {
    // XOR byte into upper 8 bits
    crc ^= (byte << 8) & 0xFFFF;

    for (var i = 0; i < 8; ++i) {
      if (crc & 0x8000 != 0) {
        // MSB = 1 → shift left and XOR polynomial
        crc = ((crc << 1) ^ polynomial) & 0xFFFF;
      } else {
        // MSB = 0 → just shift left
        crc = (crc << 1) & 0xFFFF;
      }
    }
  }

  // Return as 4-digit uppercase hex string
  return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
}

extension NumFmt on num {
  // (Negative sign, if any, + (Prefix + (Positive value + decimal)))
  String toAdemStringFmt({
    int decimal = 0,
    String prefix = '0',
    int length = 8,
  }) {
    late String res;

    // Determine if the value is negative
    final isNegative = this < 0;
    num value = isNegative ? -this : this;

    // Format the value as a string with the specified decimal places and padding
    res = value.toStringAsFixed(decimal).padLeft(length, prefix);

    // Replace the first char with '-' if the value is negative
    if (isNegative) res = '-${res.substring(1)}';

    // Replace 'S' with space
    res = res.replaceAll('S', ' ');

    return res;
  }
}

/// Converts a list of bytes into a readable string by replacing certain control characters with their designated placeholders.
String bytesToReadableString(List<int> bytes) {
  try {
    // Decode the bytes to a string once.
    String decodedString = utf8.decode(bytes);

    // Replace control characters directly in the decoded string.
    return decodedString
        .replaceAll(utf8.decode([ControlChar.soh.byte]), '<SOH>')
        .replaceAll(utf8.decode([ControlChar.stx.byte]), '<STX>')
        .replaceAll(utf8.decode([ControlChar.etx.byte]), '<ETX>')
        .replaceAll(utf8.decode([ControlChar.eot.byte]), '<EOT>')
        .replaceAll(utf8.decode([ControlChar.enq.byte]), '<ENQ>')
        .replaceAll(utf8.decode([ControlChar.ack.byte]), '<ACK>')
        .replaceAll(utf8.decode([ControlChar.rs.byte]), '<RS>');
  } catch (_) {
    // NOTE: Handle 255 from AdEM
    return bytes.toString();
  }
}

extension VolumeTypeMultiple on VolumeType {
  /// Multiply volume for correct value display
  num? volumeMultiplier(num? value) => value != null
      ? switch (this) {
          VolumeType.cf => value,
          VolumeType.cm => value * 0.01,
        }
      : null;

  /// Multiply high resolution volume for correct value display
  double? highResVolMultiplier(num? value) => value != null
      ? switch (this) {
          VolumeType.cf => value * 0.01,
          VolumeType.cm => value * 0.001,
        }
      : null;
}

/// Map log period as a filter for fetching logs
String logPeriodFmtString(DateTime from, DateTime to) {
  final fromDate = unitDateFmt.format(from);
  final fromTime = unitTimeFmt.format(from);
  final toDate = unitDateFmt.format(to);
  final toTime = unitTimeFmt.format(to);

  return '$fromDate,$fromTime,$toDate,$toTime'.replaceAll(' ', '');
}

extension OutputPulseUnitsMapping on MeterSize {
  /// Get output pulse volume units available for the meter size.
  List<VolumeUnit> get optPulseVolUnits => switch (this) {
    // Romet Imperial Meters
    MeterSize.rm600 ||
    MeterSize.rm1000 ||
    MeterSize.rm1500 ||
    MeterSize.rm2000 ||
    MeterSize.rm3000 ||
    MeterSize.rm5000 ||
    MeterSize.rm7000 ||
    MeterSize.rm11000 => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    MeterSize.rm16000 ||
    MeterSize.rm23000 ||
    MeterSize.rm25000 ||
    MeterSize.rm38000 ||
    MeterSize.rm56000 => [
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],

    // Dresser Imperial Meters
    MeterSize.m1_5LmmaI ||
    MeterSize.m3LmmaI ||
    MeterSize.m5LmmaI ||
    MeterSize.m7LmmaI ||
    MeterSize.m11LmmaI => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    MeterSize.m16LmmaI ||
    MeterSize.m23LmmaI ||
    MeterSize.m38LmmaI ||
    MeterSize.m56LmmaI => [
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    MeterSize.m102LmmaI => [VolumeUnit.cf1000, VolumeUnit.cf10000],

    // Romet Hard Metric Meters
    MeterSize.g10 ||
    MeterSize.g16 ||
    MeterSize.g25 ||
    MeterSize.g40 ||
    MeterSize.g65 => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.g100 ||
    MeterSize.g160 ||
    MeterSize.g250 ||
    MeterSize.g400 ||
    MeterSize.g400_150 ||
    MeterSize.g650 ||
    MeterSize.g1000 => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],

    // Romet Soft Metric Meters
    MeterSize.rm16 ||
    MeterSize.rm30 ||
    MeterSize.rm40 ||
    MeterSize.rm55 ||
    MeterSize.rm85 => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.rm140 ||
    MeterSize.rm200 ||
    MeterSize.rm300 ||
    MeterSize.rm450 ||
    MeterSize.rm650 ||
    MeterSize.rm700 ||
    MeterSize.rm1100 ||
    MeterSize.rm1600 => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],

    // Dresser Metric Meters
    MeterSize.m1_5LmmaM || MeterSize.m3LmmaM => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.m5LmmaM ||
    MeterSize.m7LmmaM ||
    MeterSize.m11LmmaM ||
    MeterSize.m16LmmaM => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],

    // Romet RMT Imperial
    MeterSize.rmt600 ||
    MeterSize.rmt1000 ||
    MeterSize.rmt1500 ||
    MeterSize.rmt2000 ||
    MeterSize.rmt3000 ||
    MeterSize.rmt5000 ||
    MeterSize.rmt7000 ||
    MeterSize.rmt11000 => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    MeterSize.rmt16000 || MeterSize.rmt23000 => [
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],

    // Romet RMT Soft Metric
    MeterSize.rmt16 ||
    MeterSize.rmt30 ||
    MeterSize.rmt40 ||
    MeterSize.rmt55 ||
    MeterSize.rmt85 => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.rmt140 ||
    MeterSize.rmt200 ||
    MeterSize.rmt300 ||
    MeterSize.rmt450 ||
    MeterSize.rmt650 => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],

    // Dresser B3 roots Imperial CF
    // NOTE: Not sure.
    MeterSize.c8B3I ||
    MeterSize.c11B3I ||
    MeterSize.c15B3I ||
    MeterSize.m2B3I ||
    MeterSize.m3B3I ||
    MeterSize.m5B3I ||
    MeterSize.m1_300B3I ||
    MeterSize.m3_300B3I ||
    MeterSize.m7B3I ||
    MeterSize.m11B3I ||
    MeterSize.m16B3I ||
    MeterSize.m23B3I ||
    MeterSize.m23_232B3I ||
    MeterSize.m38B3I => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    MeterSize.m56B3I => [
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],

    // Dresser B3 roots Metric CM
    MeterSize.c8B3M ||
    MeterSize.c11B3M ||
    MeterSize.c15B3M ||
    MeterSize.m2B3M ||
    MeterSize.m3B3M ||
    MeterSize.m5B3M ||
    MeterSize.m1_300B3M ||
    MeterSize.m3_300B3M => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.m7B3M ||
    MeterSize.m11B3M ||
    MeterSize.m16B3M ||
    MeterSize.m23B3M ||
    MeterSize.m23_232B3M ||
    MeterSize.m38B3M ||
    MeterSize.m56B3M => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],

    // HP Imperial Dresser Roots B3 Meter
    MeterSize.hp1M740I ||
    MeterSize.hp3M740I ||
    MeterSize.hp5M740I ||
    MeterSize.hp7M740I ||
    MeterSize.hp11M740I => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],

    // HP Metric Dresser Roots B3 Meter
    MeterSize.hp1M740M || MeterSize.hp3M740M => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    MeterSize.hp5M740M ||
    MeterSize.hp7M740M ||
    MeterSize.hp11M740M => [VolumeUnit.m31, VolumeUnit.m310, VolumeUnit.m3100],
  };
}

extension InputPulseVolumeUnitExt on InputPulseVolumeUnit {
  /// Get output pulse volume units available for the input pulse volume unit.
  List<VolumeUnit> get optPulseVolUnits => switch (this) {
    InputPulseVolumeUnit.cf1 || InputPulseVolumeUnit.cf5 => [
      VolumeUnit.cf1,
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    InputPulseVolumeUnit.cf10 => [
      VolumeUnit.cf10,
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    InputPulseVolumeUnit.cf100 => [
      VolumeUnit.cf100,
      VolumeUnit.cf1000,
      VolumeUnit.cf10000,
    ],
    InputPulseVolumeUnit.cf1000 => [VolumeUnit.cf1000, VolumeUnit.cf10000],
    InputPulseVolumeUnit.m301 => [
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    InputPulseVolumeUnit.m31 => [
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
    InputPulseVolumeUnit.m310 => [VolumeUnit.m310, VolumeUnit.m3100],
    InputPulseVolumeUnit.m3100 => [VolumeUnit.m3100],
    InputPulseVolumeUnit.m3001 => [
      VolumeUnit.m3001,
      VolumeUnit.m301,
      VolumeUnit.m31,
      VolumeUnit.m310,
      VolumeUnit.m3100,
    ],
  };
}

extension MeterSizesMapping on MeterSerial {
  /// Get available meter sizes
  List<MeterSize> filterByFirmwareVersion(String fw) {
    final sizes = MeterSize.values.where((e) => e.serial == this).toList();

    switch (this) {
      case MeterSerial.rmImperial:
        return _filterRmImperial(sizes, fw);
      case MeterSerial.rmSoftMetric:
        return _filterRmSoftMetric(sizes, fw);
      case MeterSerial.rmHardMetric:
        return _filterRmHardMetric(sizes, fw);
      case MeterSerial.lmmaImperial:
        return _filterLmmaImperial(sizes, fw);
      case MeterSerial.lmmaMetric:
        return sizes;
      case MeterSerial.b3Imperial:
        return _filterB3Imperial(sizes, fw);
      case MeterSerial.b3Metric:
        return _filterB3Metric(sizes, fw);
      case MeterSerial.rmtImperial:
        return _filterRmtImperial(sizes, fw);
      case MeterSerial.rmtSoftMetric:
        return sizes;
      case MeterSerial.hpB3Imperial:
        return sizes;
      case MeterSerial.hpB3Metric:
        return sizes;
    }
  }

  List<MeterSize> _filterRmImperial(List<MeterSize> sizes, String fw) {
    List<String> versions = [
      'D050RS15',
      'D050RS05',
      'D020RT33',
      'D020RT23',
      'D020RT03',
    ];
    List<String> masks = [
      'D05XM014',
      'D05XM004',
      'D03XM004',
      'D02XM104',
      'D02XM004',
      'D00XM004',
      'C07XM004',
    ];
    List<MeterSize> target = [MeterSize.rm600];
    bool isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    masks = ['C05XM304', 'C05XM204', 'C05XM104', 'C05XM004'];
    target = [MeterSize.rm600, MeterSize.rm25000, MeterSize.rm56000];
    isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    return sizes;
  }

  List<MeterSize> _filterRmSoftMetric(List<MeterSize> sizes, String fw) {
    List<String> versions = [
      'D050RS15',
      'D050RS05',
      'D020RT33',
      'D020RT23',
      'D020RT03',
    ];
    List<String> masks = [
      'D05XM014',
      'D05XM004',
      'D03XM004',
      'D02XM104',
      'D02XM004',
      'D00XM004',
      'C07XM004',
    ];
    List<MeterSize> target = [MeterSize.rm16];
    bool isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    masks = ['C05XM304', 'C05XM204', 'C05XM104', 'C05XM004'];
    target = [MeterSize.rm16, MeterSize.rm700, MeterSize.rm1600];
    isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    return sizes;
  }

  List<MeterSize> _filterRmHardMetric(List<MeterSize> sizes, String fw) {
    List<String> versions = [
      'D050RS15',
      'D050RS05',
      'D020RT33',
      'D020RT23',
      'D020RT03',
    ];
    List<String> masks = [
      'D05XM014',
      'D05XM004',
      'D03XM004',
      'D02XM104',
      'D02XM004',
      'D00XM004',
      'C07XM004',
    ];
    List<MeterSize> target = [MeterSize.g10];
    bool isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    masks = ['C05XM304', 'C05XM204', 'C05XM104', 'C05XM004'];
    target = [MeterSize.g10, MeterSize.g400_150, MeterSize.g1000];
    isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    return sizes;
  }

  List<MeterSize> _filterLmmaImperial(List<MeterSize> sizes, String fw) {
    final versions = [
      'D050RS75',
      'D050RS65',
      'D050RS55',
      'D050RS45',
      'D050RS35',
      'D050RS25',
      'D050RS15',
      'D050RS05',
      'C050RS05',
      'C040RS03',
      'D050RT73',
      'D050RT63',
      'D050RT053',
      'D050RT043',
      'D050RT33',
      'D050RT23',
      'D020RT33',
      'D020RT23',
      'D020RT03',
      'C060RT03',
      'C040RT03',
    ];
    final masks = [
      'D05XM084',
      'D05XM074',
      'C05XM054',
      'D05XM064',
      'D05XM044',
      'D05XM034',
      'D05XM024',
      'D05XM014',
      'D05XM004',
      'D03XM004',
      'D02XM104',
      'D02XM004',
      'D00XM004',
      'C07XM004',
      'C05XM304',
      'C05XM204',
      'C05XM104',
      'C05XM004',
    ];
    final target = [
      MeterSize.m23LmmaI,
      MeterSize.m38LmmaI,
      MeterSize.m56LmmaI,
      MeterSize.m102LmmaI,
    ];
    final isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    return sizes;
  }

  List<MeterSize> _filterB3Imperial(List<MeterSize> sizes, String fw) {
    final versions = ['C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    final masks = [
      'D00XM004',
      'C07XM004',
      'C05XM304',
      'C05XM204',
      'C05XM104',
      'C05XM004',
    ];
    final isSupport = _isNotContained(fw, versions, masks);
    return isSupport ? sizes : [];
  }

  List<MeterSize> _filterB3Metric(List<MeterSize> sizes, String fw) {
    List<String> versions = ['C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    List<String> masks = [
      'D00XM004',
      'C07XM004',
      'C05XM304',
      'C05XM204',
      'C05XM104',
      'C05XM004',
    ];
    bool isSupport = _isNotContained(fw, versions, masks);
    return isSupport ? sizes : [];
  }

  List<MeterSize> _filterRmtImperial(List<MeterSize> sizes, String fw) {
    List<String> versions = ['D050RS15', 'D050RT23', 'D020RT33'];
    List<String> masks = ['D05XM024', 'D05XM014'];
    List<MeterSize> target = [MeterSize.rmt16000, MeterSize.rmt23000];
    bool isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['D020RT23', 'D020RT03'];
    masks = ['D05XM004'];
    target = [
      MeterSize.rmt7000,
      MeterSize.rmt11000,
      MeterSize.rmt16000,
      MeterSize.rmt23000,
    ];
    isSupport = _isNotContained(fw, versions, masks);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['D020RT23', 'D020RT03'];
    target = [MeterSize.rmt5000];
    isSupport = _isNotContained(fw, versions);
    if (!isSupport) sizes.removeWhere((e) => target.contains(e));

    versions = ['D050RS05', 'C050RS05', 'C040RS03', 'C060RT03', 'C040RT03'];
    masks = [
      'D03XM004',
      'D02XM104',
      'D02XM004',
      'D00XM004',
      'C07XM004',
      'C05XM304',
      'C05XM204',
      'C05XM104',
      'C05XM004',
    ];
    isSupport = _isNotContained(fw, versions, masks);

    return isSupport ? sizes : [];
  }

  /// Function to check if a firmware version is supported based on provided versions and masks.
  bool _isNotContained(
    String fw,
    List<String>? versions, [
    List<String>? masks,
  ]) {
    bool? sizes;
    if (versions != null && versions.contains(fw)) sizes = true;
    if (masks != null && masks.isNotEmpty) {
      for (var e in masks) {
        if (RegExp(e.replaceFirst('X', '[NAGS]')).hasMatch(fw)) {
          sizes = false;
          break;
        }
      }
    }
    return sizes ?? true;
  }
}

// Unit converts
double kpaToPsi(double val) => val * kpaToPsiOffset;
double psiaToKpa(double val) => val / kpaToPsiOffset;
double kpaToBar(double val) => val * kpaToBarOffset;
double barToKpa(double val) => val / kpaToBarOffset;
double kpaToInH2o(double val) => val * kpaToInH2oOffset;
double inH2oToKpa(double val) => val / kpaToInH2oOffset;
double cToF(double val) => (val * dpCalibOffset) + cToFOffset;
double fToC(double val) => (val - cToFOffset) / dpCalibOffset;

Set<int> unavailableParams(AdemType type) {
  return switch (type) {
    AdemType.ademS => unavailableParamsAdemS,
    AdemType.ademT => unavailableParamsAdemT,
    AdemType.universalT => unavailableParamsUniversalT,
    AdemType.ademTq => unavailableParamsAdemTq,
    AdemType.ademPtz => unavailableParamsAdemPtz,
    AdemType.ademPtzR ||
    AdemType.ademR ||
    AdemType.ademMi => unavailableParamsAdemPtzr,
  };
}

/// Helper method to validate firmware version against minimum requirements.
/// Assumes format like "D020RT03" where:
/// - First char is major version
/// - Chars 1-2 are version number (2 digits)
/// - Chars 6 are revision (1 digits)
bool meetsMinFirmwareVersion(
  String version, {
  required String minMajor,
  int minMinor = 0,
  int minPatch = 0,
}) {
  if (version.length != 8) return false;

  final major = version[0].codeUnits.single;
  final minor = int.tryParse(version.substring(1, 3));
  final patch = int.tryParse(version[6]);

  if (minor == null || patch == null) return false;

  if (major > minMajor.codeUnits.single) return true;
  if (major < minMajor.codeUnits.single) return false;
  if (minor > minMinor) return true;
  if (minor < minMinor) return false;
  return patch >= minPatch;
}
