part of 'adem_param.dart';

/// Pressure unit enum.
enum PressUnit {
  psi(1, 2), // Pound per square inch
  kpa(2, 1), // Kilopascal
  bar(4, 3); // Bar

  /// Unique key for each enum value.
  final int key;

  /// Number of decimal places to display.
  final int decimal;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for PressUnit enum.
  const PressUnit(this.key, this.decimal);

  /// Get PressUnit from a given key.
  static PressUnit? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = PressUnit.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : PressUnit.values[i];
    }
  }
}

/// Pressure Transmission Type enum.
enum PressTransType {
  gauge(0), // Pressure measured relative to atmospheric pressure
  absolute(1); // Pressure measured relative to absolute zero pressure

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for PressTransType enum.
  const PressTransType(this.key);

  /// Get PressTransType from a given key.
  static PressTransType? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = PressTransType.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : PressTransType.values[i];
    }
  }
}

/// Temperature unit enum.
enum TempUnit {
  f(0, 1), // Fahrenheit
  c(1, 1); // Celsius

  /// Unique key for each enum value.
  final int key;

  /// Number of decimal places to display.
  final int decimal;

  /// Constructor for TempUnit enum.
  const TempUnit(this.key, this.decimal);

  /// Get TempUnit from a given key.
  static TempUnit? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = TempUnit.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : TempUnit.values[i];
    }
  }
}

/// Factor type enum.
enum FactorType {
  live(0), // Factor type for live data
  fixed(1); // Factor type for fixed data

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for FactorType enum.
  const FactorType(this.key);

  /// Get FactorType from a given key.
  static FactorType? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = FactorType.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : FactorType.values[i];
    }
  }
}

/// SuperX algorithm enum.
enum SuperXAlgo {
  nx19(0), // SuperX Algorithm: NX-19
  aga8(1), // SuperX Algorithm: AGA8
  sgerg88(2), // SuperX Algorithm: SGerg 88
  aga8G1(3), // SuperX Algorithm: AGA8 G1
  aga8G2(4); // SuperX Algorithm: AGA8 G2

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for SuperXAlgo enum.
  const SuperXAlgo(this.key);

  /// Get SuperXAlgorithm from a given key.
  static SuperXAlgo? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = SuperXAlgo.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : SuperXAlgo.values[i];
    }
  }
}

/// Pressure Display Resolution enum.
enum PressDispRes {
  decimal0(0), // Pressure display resolution: 0 decimal places
  decimal1(1), // Pressure display resolution: 1 decimal place
  decimal2(2), // Pressure display resolution: 2 decimal places
  decimal3(3), // Pressure display resolution: 3 decimal places
  decimal4(4); // Pressure display resolution: 4 decimal places

  /// Unique key for each enum value.
  final int key;

  /// Constructor for PressDispRes enum.
  const PressDispRes(this.key);

  /// Get PressDispRes from a given key.
  static PressDispRes? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = PressDispRes.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : PressDispRes.values[i];
    }
  }
}

/// Output Pulse Spacing enum.
enum OutPulseSpacing {
  ms50(0), // Output pulse spacing: 50 milliseconds
  ms750(1), // Output pulse spacing: 750 milliseconds
  ms150(2), // Output pulse spacing: 150 milliseconds
  ms200(3), // Output pulse spacing: 200 milliseconds
  ms250(4), // Output pulse spacing: 250 milliseconds
  ms350(5), // Output pulse spacing: 350 milliseconds
  ms500(6), // Output pulse spacing: 500 milliseconds
  pulseOff(7); // Output pulse spacing: Pulse off

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for OutPulseSpacing enum.
  const OutPulseSpacing(this.key);

  /// Get OutPulseSpacing from a given key.
  static OutPulseSpacing? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = OutPulseSpacing.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : OutPulseSpacing.values[i];
    }
  }
}

/// Output Pulse Width enum.
enum OutPulseWidth {
  ms5(1), // Output pulse width: 5 milliseconds
  ms10(2), // Output pulse width: 10 milliseconds
  ms15(3), // Output pulse width: 15 milliseconds
  ms20(4), // Output pulse width: 20 milliseconds
  ms25(5), // Output pulse width: 25 milliseconds
  ms30(6), // Output pulse width: 30 milliseconds
  ms35(7), // Output pulse width: 35 milliseconds
  ms40(8), // Output pulse width: 40 milliseconds
  ms45(9), // Output pulse width: 45 milliseconds
  ms50(10), // Output pulse width: 50 milliseconds
  ms65(13), // Output pulse width: 65 milliseconds
  ms120(24), // Output pulse width: 120 milliseconds
  ms125(25), // Output pulse width: 125 milliseconds
  ms250(50); // Output pulse width: 250 milliseconds

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for OutPulseWidth enum.
  const OutPulseWidth(this.key);

  /// Get OutPulseWidth from a given key.
  static OutPulseWidth? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = OutPulseWidth.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : OutPulseWidth.values[i];
    }
  }
}

/// Display Volume Selection enum.
enum DispVolSelect {
  corVol(0), // Corrected Volume
  uncVol(1); // Uncorrected Volume

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for DispVolSelect enum.
  const DispVolSelect(this.key);

  /// Get DispVolSelect from a given key.
  static DispVolSelect? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = DispVolSelect.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : DispVolSelect.values[i];
    }
  }
}

/// Volume Digits enum.
enum VolDigits {
  digit8(0), // 8 digits
  digit7(1), // 7 digits
  digit6(2), // 6 digits
  digit5(3); // 5 digits

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for VolDigits enum.
  const VolDigits(this.key);

  /// Get VolDigits from a given key.
  static VolDigits? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = VolDigits.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : VolDigits.values[i];
    }
  }
}

/// Prove And Pulse Function enum.
enum ProvePulseFunc {
  disabled(0), // Prove and Pulse function is disabled
  enabled(1); // Prove and Pulse function is enabled

  /// Unique key for each enum value.
  final int key;

  /// Constructor for ProvePulseFunc enum.
  const ProvePulseFunc(this.key);

  /// Get ProveAndPulseFunction from a given key.
  static ProvePulseFunc? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = ProvePulseFunc.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : ProvePulseFunc.values[i];
    }
  }
}

/// Input Pulse Volume Unit enum.
enum InputPulseVolumeUnit {
  cf1(0, MeterSystem.imperial), // Cubic feet per pulse (1 cubic foot)
  cf5(1, MeterSystem.imperial), // Cubic feet per pulse (5 cubic feet)
  cf10(2, MeterSystem.imperial), // Cubic feet per pulse (10 cubic feet)
  cf100(3, MeterSystem.imperial), // Cubic feet per pulse (100 cubic feet)
  cf1000(4, MeterSystem.imperial), // Cubic feet per pulse (1000 cubic feet)
  m301(5, MeterSystem.metric), // Cubic meters per pulse (0.1 cubic meter)
  m31(6, MeterSystem.metric), // Cubic meters per pulse (1 cubic meter)
  m310(7, MeterSystem.metric), // Cubic meters per pulse (10 cubic meter)
  m3100(8, MeterSystem.metric), // Cubic meters per pulse (100 cubic meter)
  m3001(9, MeterSystem.metric); // Cubic meters per pulse (0.01 cubic meters)

  /// Unique key for each enum value.
  final int key;
  final MeterSystem meterSystem;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for InPulseVolUnit enum.
  const InputPulseVolumeUnit(this.key, this.meterSystem);

  /// Get InPulseVolUnit from a given key.
  static InputPulseVolumeUnit? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = InputPulseVolumeUnit.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : InputPulseVolumeUnit.values[i];
    }
  }
}

/// Volume Unit enum.
enum VolumeUnit {
  cf001(97, MeterSystem.imperial), // Cubic feet (0.01 cubic feet)
  cf1(3, MeterSystem.imperial), // Cubic feet (1 cubic foot)
  cf10(4, MeterSystem.imperial), // Cubic feet (10 cubic feet)
  cf100(5, MeterSystem.imperial), // Cubic feet (100 cubic feet)
  cf1000(6, MeterSystem.imperial), // Cubic feet (1000 cubic feet)
  cf10000(14, MeterSystem.imperial), // Cubic feet (10000 cubic feet)
  m300001(98, MeterSystem.metric), // Cubic meters (0.0001 cubic meter)
  m3001(99, MeterSystem.metric), // Cubic meters (0.01 cubic meter)
  m301(9, MeterSystem.metric), // Cubic meters (0.1 cubic meter)
  m31(10, MeterSystem.metric), // Cubic meters (10 cubic meter)
  m310(11, MeterSystem.metric), // Cubic meters (10 cubic meter)
  m3100(12, MeterSystem.metric); // Cubic meters (100 cubic meters)

  /// Unique key for each enum value.
  final int key;

  /// Measurement system.
  final MeterSystem measSys;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for VolUnit enum.
  const VolumeUnit(this.key, this.measSys);

  /// Get VolumeUnit from a given key.
  static VolumeUnit? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = VolumeUnit.values.indexWhere((o) => o.key == int.tryParse(key));
      return i == -1 ? null : VolumeUnit.values[i];
    }
  }
}

/// Battery Type enum.
enum BatteryType {
  largeAlkaline(0), // Large Alkaline battery
  smallAlkaline(1), // Small Alkaline battery
  smallLithium(2), // Small Lithium battery
  largeLithium(3); // Large Lithium battery

  /// Unique key for each enum value.
  final int key;

  /// Constructor for BatteryType enum.
  const BatteryType(this.key);

  /// Get BatteryType from a given key.
  static BatteryType? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = BatteryType.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : BatteryType.values[i];
    }
  }
}

/// Pulse Channel enum.
enum PulseChannel {
  corVolPulse(0), // Corrected Volume Pulse
  malfAlarmPulse(1), // Malfunction Alarm Pulse
  uncVolPulse(2); // Uncorrected Volume Pulse

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for PulseChannel enum.
  const PulseChannel(this.key);

  /// Get PulseChannel from a given key.
  static PulseChannel? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = PulseChannel.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : PulseChannel.values[i];
    }
  }
}

/// Interval Log Type enum.
enum IntervalLogType {
  fullFields(0), // Full fields interval log
  selectableFields(1), // Selectable fields interval log
  fixed4Fields(2); // Fixed 4 fields interval log

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for IntervalLogType enum.
  const IntervalLogType(this.key);

  /// Get IntervalLogType from a given key.
  static IntervalLogType? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = IntervalLogType.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : IntervalLogType.values[i];
    }
  }
}

/// Interval Log Interval enum.
enum IntervalLogInterval {
  minutes5(5), // 5 minutes interval
  minutes15(15), // 15 minutes interval
  minutes30(30), // 30 minutes interval
  minutes60(60), // 60 minutes interval
  hours2(2), // 2 hours interval
  hours6(6), // 6 hours interval
  hours12(12), // 12 hours interval
  hours24(24); // 24 hours interval

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value with padded string.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for IntervalLogInterval enum.
  const IntervalLogInterval(this.key);

  /// Get IntervalLogInterval from a given key.
  static IntervalLogInterval? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = IntervalLogInterval.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : IntervalLogInterval.values[i];
    }
  }
}

/// Unit Date Format enum.
enum UnitDateFmt {
  monthDateYear(0), // Month, Date, Year format
  dateMonthYear(1), // Date, Month, Year format
  yearMonthDate(2); // Year, Month, Date format

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for UnitDateFmt enum.
  const UnitDateFmt(this.key);

  /// Get UnitDateFmt from a given key.
  static UnitDateFmt? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = UnitDateFmt.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : UnitDateFmt.values[i];
    }
  }
}

/// Flow Rate Type enum.
enum FlowRateType {
  cf(0, 0), // Cubic feet per minute (0 decimal places)
  cm(1, 2); // Cubic meters per minute (2 decimal places)

  /// Unique key for each enum value.
  final int key; // Unique key for each enum value for each enum value
  /// Number of decimal places to display.
  final int decimal; // Decimal precision for the flow rate type

  /// Constructor for FlowRateType enum.
  const FlowRateType(this.key, this.decimal);
}

/// Volume Type enum.
enum VolumeType {
  cf(0), // Cubic feet
  cm(2); // Cubic meters

  /// Number of decimal places to display.
  final int decimal;

  /// Constructor for VolumeType enum.
  const VolumeType(this.decimal);
}

/// Measurement System enum.
enum MeterSystem {
  imperial, // Imperial measurement system (e.g., cubic feet)
  metric; // Metric measurement system (e.g., cubic meters)

  List<MeterSerial> get series =>
      MeterSerial.values.where((e) => e.system == this).toList();

  /// Converts the measurement system to the corresponding FlowRateType.
  FlowRateType get toFlowRateType => switch (this) {
    MeterSystem.imperial => FlowRateType.cf,
    MeterSystem.metric => FlowRateType.cm,
  };

  /// Converts the measurement system to the corresponding VolumeType.
  VolumeType get toVolumeType => switch (this) {
    MeterSystem.imperial => VolumeType.cf,
    MeterSystem.metric => VolumeType.cm,
  };

  /// Converts the measurement system to the corresponding DiffPressUnit.
  DiffPressUnit get toDiffPressUnit => switch (this) {
    MeterSystem.imperial => DiffPressUnit.inH2o,
    MeterSystem.metric => DiffPressUnit.kpa,
  };

  /// Converts the measurement system to the corresponding LineGaugePressUnit.
  LineGaugePressUnit get toLineGaugePressUnit => switch (this) {
    MeterSystem.imperial => LineGaugePressUnit.psig,
    MeterSystem.metric => LineGaugePressUnit.kpag,
  };
}

/// Differential Pressure Unit enum.
enum DiffPressUnit {
  kpa(0, 1), // Kilopascal with 1 decimal place
  inH2o(1, 3); // Inches of water column with 3 decimal places

  /// Unique key for each enum value.
  final int key;

  /// Number of decimal places to display.
  final int decimal;

  /// Constructor for DiffPressUnit enum.
  const DiffPressUnit(this.key, this.decimal);

  /// Converts the differential pressure unit to the corresponding PressUnit.
  PressUnit get toPressUnit => switch (this) {
    DiffPressUnit.inH2o => PressUnit.psi,
    DiffPressUnit.kpa => PressUnit.kpa,
  };
}

/// Line Gauge Pressure Unit enum.
enum LineGaugePressUnit {
  kpag(0, 1), // Kilopascal gauge with 1 decimal place
  psig(1, 2); // Pounds per square inch gauge with 2 decimal places

  /// Unique key for each enum value.
  final int key;

  /// Number of decimal places to display.
  final int decimal;

  /// Constructor for LineGaugePressUnit enum.
  const LineGaugePressUnit(this.key, this.decimal);
}

/// Meter Size enum.
enum MeterSize {
  // Romet Imperial Meters
  rm600(0, 'RM600', 600, MeterSerial.rmImperial),
  rm1000(1, 'RM1000', 1000, MeterSerial.rmImperial),
  rm1500(2, 'RM1500', 1500, MeterSerial.rmImperial),
  rm2000(3, 'RM2000', 2000, MeterSerial.rmImperial),
  rm3000(4, 'RM3000', 3000, MeterSerial.rmImperial),
  rm5000(5, 'RM5000', 5000, MeterSerial.rmImperial),
  rm7000(6, 'RM7000', 7000, MeterSerial.rmImperial),
  rm11000(7, 'RM11000', 11000, MeterSerial.rmImperial),
  rm16000(8, 'RM16000', 16000, MeterSerial.rmImperial),
  rm23000(9, 'RM23000', 23000, MeterSerial.rmImperial),
  rm25000(10, 'RM25000', 25000, MeterSerial.rmImperial),
  rm38000(11, 'RM38000', 38000, MeterSerial.rmImperial),
  rm56000(12, 'RM56000', 56000, MeterSerial.rmImperial),

  // Dresser Imperial Meters
  m1_5LmmaI(13, '1.5MLMMA', 1500, MeterSerial.lmmaImperial),
  m3LmmaI(14, '3MLMMA', 3000, MeterSerial.lmmaImperial),
  m5LmmaI(15, '5MLMMA', 5000, MeterSerial.lmmaImperial),
  m7LmmaI(16, '7MLMMA', 7000, MeterSerial.lmmaImperial),
  m11LmmaI(17, '11MLMMA', 11000, MeterSerial.lmmaImperial),
  m16LmmaI(18, '16MLMMA', 16000, MeterSerial.lmmaImperial),
  m23LmmaI(90, '23MLMMA', 23000, MeterSerial.lmmaImperial),
  m38LmmaI(91, '38MLMMA', 38000, MeterSerial.lmmaImperial),
  m56LmmaI(92, '56MLMMA', 56000, MeterSerial.lmmaImperial),
  m102LmmaI(93, '102MLMMA', 102000, MeterSerial.lmmaImperial),

  // Romet Hard Metric Meters
  g10(19, 'G10', 16, MeterSerial.rmHardMetric),
  g16(20, 'G16', 25, MeterSerial.rmHardMetric),
  g25(21, 'G25', 40, MeterSerial.rmHardMetric),
  g40(22, 'G40', 65, MeterSerial.rmHardMetric),
  g65(23, 'G65', 100, MeterSerial.rmHardMetric),
  g100(24, 'G100', 160, MeterSerial.rmHardMetric),
  g160(25, 'G160', 250, MeterSerial.rmHardMetric),
  g250(26, 'G250', 400, MeterSerial.rmHardMetric),
  g400(27, 'G400', 650, MeterSerial.rmHardMetric),
  g400_150(28, 'G400-150', 650, MeterSerial.rmHardMetric),
  g650(29, 'G650', 1100, MeterSerial.rmHardMetric),
  g1000(30, 'G1000', 1600, MeterSerial.rmHardMetric),

  // Romet Soft Metric Meters
  rm16(31, 'RM16', 16, MeterSerial.rmSoftMetric),
  rm30(32, 'RM30', 30, MeterSerial.rmSoftMetric),
  rm40(33, 'RM40', 40, MeterSerial.rmSoftMetric),
  rm55(34, 'RM55', 55, MeterSerial.rmSoftMetric),
  rm85(35, 'RM85', 85, MeterSerial.rmSoftMetric),
  rm140(36, 'RM140', 140, MeterSerial.rmSoftMetric),
  rm200(37, 'RM200', 200, MeterSerial.rmSoftMetric),
  rm300(38, 'RM300', 300, MeterSerial.rmSoftMetric),
  rm450(39, 'RM450', 450, MeterSerial.rmSoftMetric),
  rm650(40, 'RM650', 650, MeterSerial.rmSoftMetric),
  rm700(41, 'RM700', 700, MeterSerial.rmSoftMetric),
  rm1100(42, 'RM1100', 1100, MeterSerial.rmSoftMetric),
  rm1600(43, 'RM1600', 1600, MeterSerial.rmSoftMetric),

  // Dresser Metric Meters
  m1_5LmmaM(44, '1.5M(40)', 40, MeterSerial.lmmaMetric),
  m3LmmaM(45, '3M(85)', 85, MeterSerial.lmmaMetric),
  m5LmmaM(46, '5M(140)', 140, MeterSerial.lmmaMetric),
  m7LmmaM(47, '7M(200)', 200, MeterSerial.lmmaMetric),
  m11LmmaM(48, '11M(300)', 300, MeterSerial.lmmaMetric),
  m16LmmaM(49, '16M(450)', 450, MeterSerial.lmmaMetric),

  // Romet RMT Imperial
  rmt600(80, 'RMT600', 600, MeterSerial.rmtImperial),
  rmt1000(81, 'RMT1000', 1000, MeterSerial.rmtImperial),
  rmt1500(82, 'RMT1500', 1500, MeterSerial.rmtImperial),
  rmt2000(83, 'RMT2000', 2000, MeterSerial.rmtImperial),
  rmt3000(84, 'RMT3000', 3000, MeterSerial.rmtImperial),
  rmt5000(85, 'RMT5000', 5000, MeterSerial.rmtImperial),
  rmt7000(86, 'RMT7000', 7000, MeterSerial.rmtImperial),
  rmt11000(87, 'RMT11000', 11000, MeterSerial.rmtImperial),
  rmt16000(88, 'RMT16000', 16000, MeterSerial.rmtImperial),
  rmt23000(89, 'RMT23000', 23000, MeterSerial.rmtImperial),

  // Romet RMT Soft Metric
  rmt16(94, 'RMT16', 16, MeterSerial.rmtSoftMetric),
  rmt30(95, 'RMT30', 30, MeterSerial.rmtSoftMetric),
  rmt40(96, 'RMT40', 40, MeterSerial.rmtSoftMetric),
  rmt55(97, 'RMT55', 55, MeterSerial.rmtSoftMetric),
  rmt85(98, 'RMT85', 85, MeterSerial.rmtSoftMetric),
  rmt140(99, 'RMT140', 140, MeterSerial.rmtSoftMetric),
  rmt200(100, 'RMT200', 200, MeterSerial.rmtSoftMetric),
  rmt300(101, 'RMT300', 300, MeterSerial.rmtSoftMetric),
  rmt450(102, 'RMT450', 450, MeterSerial.rmtSoftMetric),
  rmt650(103, 'RMT650', 650, MeterSerial.rmtSoftMetric),

  // Dresser B3 roots Imperial CF
  c8B3I(50, '8C175I', 800, MeterSerial.b3Imperial),
  c11B3I(51, '11C175I', 1100, MeterSerial.b3Imperial),
  c15B3I(52, '15C175I', 1500, MeterSerial.b3Imperial),
  m2B3I(53, '2M175I', 2000, MeterSerial.b3Imperial),
  m3B3I(54, '3M175I', 3000, MeterSerial.b3Imperial),
  m5B3I(55, '5M175I', 5000, MeterSerial.b3Imperial),
  m7B3I(56, '7M175I', 7000, MeterSerial.b3Imperial),
  m11B3I(57, '11M175I', 11000, MeterSerial.b3Imperial),
  m16B3I(58, '16M175I', 16000, MeterSerial.b3Imperial),
  m23B3I(59, '23M175I', 23000, MeterSerial.b3Imperial),
  m23_232B3I(60, '23M232I', 23000, MeterSerial.b3Imperial),
  m38B3I(61, '38M175I', 38000, MeterSerial.b3Imperial),
  m1_300B3I(62, '1M300I', 1000, MeterSerial.b3Imperial),
  m3_300B3I(63, '3M300I', 3000, MeterSerial.b3Imperial),
  m56B3I(64, '56M175I', 56000, MeterSerial.b3Imperial),

  // Dresser B3 roots Metric CM
  c8B3M(65, '8C175M', 23, MeterSerial.b3Metric),
  c11B3M(66, '11C175M', 31, MeterSerial.b3Metric),
  c15B3M(67, '15C175M', 40, MeterSerial.b3Metric),
  m2B3M(68, '2M175M', 55, MeterSerial.b3Metric),
  m3B3M(69, '3M175M', 85, MeterSerial.b3Metric),
  m5B3M(70, '5M175M', 140, MeterSerial.b3Metric),
  m7B3M(71, '7M175M', 200, MeterSerial.b3Metric),
  m11B3M(72, '11M175M', 300, MeterSerial.b3Metric),
  m16B3M(73, '16M175M', 450, MeterSerial.b3Metric),
  m23B3M(74, '23M175M', 650, MeterSerial.b3Metric),
  m23_232B3M(75, '23M232M', 650, MeterSerial.b3Metric),
  m38B3M(76, '38M175M', 1100, MeterSerial.b3Metric),
  m1_300B3M(77, '1M300M', 30, MeterSerial.b3Metric),
  m3_300B3M(78, '3M300M', 85, MeterSerial.b3Metric),
  m56B3M(79, '56M175M', 1600, MeterSerial.b3Metric),

  // HP Imperial Dresser Roots B3 Meter
  hp1M740I(104, '1M740I', 1000, MeterSerial.hpB3Imperial),
  hp3M740I(105, '3M740I', 3000, MeterSerial.hpB3Imperial),
  hp5M740I(106, '5M740I', 5000, MeterSerial.hpB3Imperial),
  hp7M740I(107, '7M740I', 7000, MeterSerial.hpB3Imperial),
  hp11M740I(108, '11M740I', 11000, MeterSerial.hpB3Imperial),

  //HP Metric Dresser Roots B3 Meter
  hp1M740M(109, '1M740M', 30, MeterSerial.hpB3Metric),
  hp3M740M(110, '3M740M', 85, MeterSerial.hpB3Metric),
  hp5M740M(111, '5M740M', 140, MeterSerial.hpB3Metric),
  hp7M740M(112, '7M740M', 200, MeterSerial.hpB3Metric),
  hp11M740M(113, '11M740M', 300, MeterSerial.hpB3Metric);

  /// Unique key for each enum value.
  final int key;

  /// Unique key for receiving data related to each enum value.
  final String receiveKey;

  /// Maximum flow rate for each enum value.
  final int maxFlowRate;

  /// Series associated with each enum value.
  final MeterSerial serial;

  /// Unique key for sending data related to each enum value with padded string.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for MeterSize enum.
  const MeterSize(this.key, this.receiveKey, this.maxFlowRate, this.serial);

  /// Converts a string key to the corresponding MeterSize enum value.
  static MeterSize? from(String? receiveKey) {
    if (receiveKey == null) {
      return null;
    } else {
      final i = MeterSize.values.indexWhere(
        (o) => o.receiveKey == receiveKey.replaceAll(' ', ''),
      );
      return i == -1 ? null : MeterSize.values[i];
    }
  }
}

/// Meter Series enum.
enum MeterSerial {
  rmImperial(MeterSystem.imperial), // RM series
  rmSoftMetric(MeterSystem.metric), // RM Soft series
  rmHardMetric(MeterSystem.metric), // RM Hard series
  lmmaImperial(MeterSystem.imperial), // LMMA series A
  lmmaMetric(MeterSystem.metric), // LMMA series A
  b3Imperial(MeterSystem.imperial), // B3 series
  b3Metric(MeterSystem.metric), // B3 series
  rmtImperial(MeterSystem.imperial), // RMT series
  rmtSoftMetric(MeterSystem.metric), // RMT Soft series
  // Note: Only for AdEM-PTZ (AdEM25)
  hpB3Imperial(MeterSystem.imperial), // HP Imperial Dresser Roots B3
  // Note: Only for AdEM-PTZ (AdEM25)
  hpB3Metric(MeterSystem.metric); // HP Metric Dresser Roots B3

  /// Measurement system associated with the series.
  final MeterSystem system;

  /// Retrieves a list of MeterSize values.
  List<MeterSize> get sizes =>
      MeterSize.values.where((e) => e.serial == this).toList();

  /// Constructor for MeterSeries enum.
  const MeterSerial(this.system);
}

/// Interval Log Field enum.
enum IntervalLogField {
  avgBatteryVoltage(48), // Average battery voltage
  avgTotalFactor(43), // Average total factor
  uncAvgFlowRate(208), // Uncorrected average flow rate
  maxPress(285), // Maximum pressure
  maxPressTime(286), // Time of maximum pressure
  maxTemp(293), // Maximum temperature
  maxTempTime(294), // Time of maximum temperature
  uncMaxFlowRate(273), // Uncorrected maximum flow rate
  uncMaxFlowRateTime(274), // Time of uncorrected maximum flow rate
  minPress(289), // Minimum pressure
  minPressTime(290), // Time of minimum pressure
  minTemp(297), // Minimum temperature
  minTempTime(298), // Time of minimum temperature
  uncMinFlowRate(860), // Uncorrected minimum flow rate
  uncMinFlowRateTime(861), // Time of uncorrected minimum flow rate
  corTotalVol(2), // Corrected total volume
  uncTotalVol(0), // Uncorrected total volume
  notSet(255); // Field not set

  /// Unique key for each enum value.
  final int key;

  /// Unique key for sending data related to each enum value.
  String get sendKey => key.toString().padLeft(8, '0');

  /// Constructor for IntervalLogField enum.
  const IntervalLogField(this.key);

  /// Get IntervalLogField from a given key.
  static IntervalLogField? from(String? key) {
    if (key == null) {
      return null;
    } else {
      final i = IntervalLogField.values.indexWhere(
        (o) => o.key == int.tryParse(key),
      );
      return i == -1 ? null : IntervalLogField.values[i];
    }
  }
}

/// Customer Display Item enum.
enum CustDispItem {
  uncVol(0, 2, 2), // Uncorrected volume
  corVol(1, 0, 0), // Corrected volume
  dispTestPattern(2, 61, 61), // Display test pattern
  batteryLife(3, 769, 769), // Battery life
  batteryVoltage(4, 48, 48), // Battery voltage
  batteryInstallDate(5, 772, 772), // Battery installation date
  meterSize(6, 768, 768), // Meter size
  gasTemp(7, 26, 26), // Gas temperature
  tempFactor(8, 45, 45), // Temperature factor
  gasAbsPress(9, 8, 8), // Gas absolute pressure
  gasGaugePress(10, 811, 811), // Gas gauge pressure
  atmosphericPress(11, 14, 14), // Atmospheric pressure
  pressFactor(12, 44, 44), // Pressure factor
  superXFactor(13, 47, 116), // Super compressibility factor
  totalCorFactor(14, 43, 43), // Total corrected factor
  // totalCorFactor(14, 43, 137), // Total corrected factor
  gasSpecificGravity(15, 53, 53), // Gas specific gravity
  gasMoleN2(16, 54, 54), // Gas mole fraction N2
  gasMoleCO2(17, 55, 55), // Gas mole fraction CO2
  uncOutputPulse(18, 56, 816), // Uncorrected output pulse
  corOutputPulse(19, 57, 817), // Corrected output pulse
  outputPulseSpacing(20, 115, 115), // Output pulse spacing
  baseTemp(21, 34, 34), // Base temperature
  basePress(22, 13, 13), // Base pressure
  date(23, 204, 204), // Date
  time(24, 203, 203), // Time
  uncFlowrate(25, 209, 209), // Uncorrected flow rate
  peakUncFlowrate(26, 198, 198), // Peak uncorrected flow rate
  peakUncFlowrateDate(27, 275, 275), // Peak uncorrected flow rate date
  peakUncFlowrateTime(28, 274, 274), // Peak uncorrected flow rate time
  peakFlowrateResetDate(29, 786, 786), // Peak flow rate reset date
  peakFlowrateResetTime(30, 785, 785), // Peak flow rate reset time
  batteryMalfDate(31, 780, 780), // Battery malfunction date
  tempTxdrMalfDate(32, 784, 784), // Temperature transducer malfunction date
  tempTxdrMalfTime(33, 783, 783), // Temperature transducer malfunction time
  pressTxdrMalfDate(34, 782, 782), // Pressure transducer malfunction date
  pressTxdrMalfTime(35, 781, 781), // Pressure transducer malfunction time
  lastSavedUncVol(36, 774, 774), // Last saved uncorrected volume
  lastSavedCorVol(37, 775, 775), // Last saved corrected volume
  lastSaveDate(38, 777, 777), // Last save date
  lastSaveTime(39, 776, 776), // Last save time
  uncVolSinceMalf(40, 773, 773), // Uncorrected volume since malfunction
  serialNumber(41, 62, 62), // Serial number
  firmwareVersion(42, 122, 122), // Firmware version
  pressTxdrRange(43, 137, 137), // Pressure transducer range
  pressTxdrSn(44, 138, 138), // Pressure transducer serial number
  caseTemp(45, 31, 31), // Case temperature
  gasMoleH2(46, 821, 821), // Gas mole fraction H2
  // uncVol(47,2,2),
  // uncVol(48,2,2),
  // uncVol(49,2,2),
  corFlowrate(50, 828, 828), // Corrected flow rate
  prevDayUncVol(51, 184, 184), // Previous day's uncorrected volume
  prevDayCorVol(52, 183, 183), // Previous day's corrected volume
  dailyUncVol(53, 224, 224), // Daily uncorrected volume
  dailyCorVol(54, 223, 223), // Daily corrected volume
  provingVol(55, 995, 995), // Proving volume
  backupIdxCtr(56, 117, 834), // Backup index counter
  outputPulseWidth(57, 836, 840), // Output pulse width
  batteryRemaining(58, 59, 59), // Battery remaining
  // uncFlowrateHighLimit(59,164,164),
  displacement(59, 806, 806), // Displacement
  highResCorVol(60, 113, 113), // High resolution corrected volume
  highResUncVol(61, 767, 767), // High resolution uncorrected volume
  serialNumberPart2(62, 201, 201), // Serial number part 2
  firmwareChecksum(63, 986, 986), // Firmware checksum
  diffPress(64, 858, 858), // Differential pressure
  // uncVol(65,2,2),
  maxAllowableDp(66, 856, 856), // Maximum allowable differential pressure
  lineGaugePress(67, 855, 855), // Line gauge pressure
  dpSensorSn(854, 854, 854), // Differential pressure sensor serial number
  dpSensorRange(69, 853, 853), // Differential pressure sensor range
  qMonitorFunction(65, 860, 860),
  inputPulseVolUnit(6, 98, 98),
  notSet(255, 255, 255); // Not set

  /// Unique key for sending data related to each enum value.
  final int sendKey;

  /// Unique key for receiving data related to each enum value.
  final int receiveKey;

  /// Key for retrieved to Param.
  final int itemNumber;

  /// Converts the item number of the enum to a Param.
  Param toParam(Adem adem) {
    if (receiveKey != 47) {
      return Param.from(itemNumber);
    } else {
      final superXFactorType = adem.measureCache.superXFactorType;
      return switch (superXFactorType) {
        FactorType.live => Param.liveSuperXFactor,
        _ => Param.fixedSuperXFactor,
      };
    }
  }

  /// Constructor for CustDispItem enum.
  const CustDispItem(this.sendKey, this.receiveKey, this.itemNumber);

  /// Factory method to retrieve a CustDispItem enum value based on its item number.
  factory CustDispItem.fromItemNumber(int itemNumber) => CustDispItem.values
      .firstWhere((e) => e.itemNumber == itemNumber, orElse: () => notSet);

  /// Get CustDispItem from a given key.
  static CustDispItem? from(String? receiveKey) {
    if (receiveKey == null) {
      return null;
    } else {
      final i = CustDispItem.values.indexWhere(
        (o) => o.receiveKey == int.tryParse(receiveKey),
      );
      return i == -1 ? null : CustDispItem.values[i];
    }
  }
}

/// AGA8 Parameters enum.
enum Aga8Param {
  methane, // CH4
  nitrogen, // N2
  carbonDioxide, // CO2
  ethane, // C2H6
  propane, // C3H8
  water, // H2O
  hydrogenSulphide, // H2S
  hydrogen, // H2
  carbonMonoxide, // CO
  oxygen, // O2
  isoButane, // i-C4H10
  nButane, // n-C4H10
  isoPentane, // i-C5H12
  nPentane, // n-C5H12
  nHexane, // n-C6H14
  nHeptane, // n-C7H16
  nOctane, // n-C8H18
  nNonane, // n-C9H20
  nDecane, // n-C10H22
  helium, // He
  argon, // Ar
}

// MARK: AdEM type

/// ### Pattern Descriptions:
///
/// #### 1. **ADEM-S (Basic)**
/// - Format: ####RS#5
/// - Ends with '5'
/// - 'R' = Romet Protocol (NO MODBUS)
/// - 'S' = Basic
///
/// #### 2. **ADEM-T (Temperature Compensated)**
/// - Format: ####RT#3
/// - Ends with '3'
/// - 'R' = Romet Protocol (NO MODBUS)
/// - 'T' = Temperature Compensated
///
/// #### 3. **ADEM-TQ (Q Margin)**
/// - Format: ####MQ#7 or ####RQ#7
/// - Ends with '7'
/// - 'M' = Modbus Protocols
/// - 'R' = Romet Protocols (NO MODBUS) (AdEM-25)
/// - 'Q' = Q Margin
///
/// #### 4. **Universal-T (NX19 Temperature Compensated)**
/// - Format: ###NMT#3
/// - Ends with '3'
/// - 'N' = NX19 – ADEM-PTZ BOARD
/// - 'M' = Modbus Protocols
/// - 'T' = Temperature Compensated
///
/// #### 5. **ADEM-PTZ (Advanced PTZ)**
/// - Format: ###XM##4 or ###XR##4
/// - Ends with '4'
/// - 'N' = NX19
/// - 'A' = AGA8 Detail
/// - 'G' = AGA8 Gross 1 and Gross 2
/// - 'S' = SGERG88
/// - 'M' = Modbus Protocols
/// - 'R' = Romet Protocols (NO MODBUS) (AdEM-25)
///
/// #### 6. **ADEM-PTZ-R**
/// - Format: ###XM##6 or ###XR##6
/// - Ends with '6'
/// - 'N' = NX19
/// - 'A' = AGA8 Detail
/// - 'G' = AGA8 Gross 1 and Gross 2
/// - 'S' = SGERG88
/// - 'M' = Modbus Protocols
/// - 'R' = Romet Protocols (NO MODBUS) (AdEM-25)
enum AdemType {
  ademS(3, 'RS', 1, 5),
  ademT(3, 'RT', 1, 3),
  universalT(3, 'MT', 1, 3),
  ademTq(3, '(M|R)Q', 1, 7),
  ademPtz(2, '[NAGS](M|R)', 2, 4),
  ademPtzq(2, '[NAGS](M|R)Q', 1, 8),  // PTZq: PTZ + TQ (DP monitoring)
  ademPtzR(2, '[NAGS](M|R)', 2, 6),
  ademR(2, '[NAGS](M|R)', 2, 6),
  ademMi(2, '[NAGS](M|R)', 2, 6);

  final int prefixLength;
  final String middlePattern;
  final int suffixLength;
  final int lastDigit;

  const AdemType(
    this.prefixLength,
    this.middlePattern,
    this.suffixLength,
    this.lastDigit,
  );

  /// Map AdEM type from firmware before firmware(E)
  /// Otherwise, check product type (#874)
  factory AdemType.from(String firmware, String? productType) {
    if (firmware.startsWith('E')) {
      final type = switch (productType?.trim().toUpperCase()) {
        'ADEM-T' || 'ADEM+T' => AdemType.ademT,
        'ADEM-TQ' || 'ADEM+TQ' => AdemType.ademTq,
        'ADEM-PTZ' || 'ADEM+PTZ' => AdemType.ademPtz,
        'ADEM-PTZQ' || 'ADEM+PTZQ' => AdemType.ademPtzq,  // PTZq: PTZ + TQ
        'ADEM-R' || 'ADEM+R' => AdemType.ademR,
        'ADEM-MI' || 'ADEM+MI' => AdemType.ademMi,
        null => throw const AdemCommError(
          AdemCommErrorType.productTypeNotFound,
        ),
        _ => null, // NOTE: Bypass, Old E version have different return...
      };

      if (type != null) return type;
    }

    return AdemType.values.firstWhere(
      (e) => RegExp(e.regexPattern).hasMatch(firmware),
      orElse: () =>
          throw AdemCommError(AdemCommErrorType.unsupportedFirmware, firmware),
    );
  }

  /// Constructs the full regex pattern based on the defined parameters.
  ///
  /// Breakdown of the regex structure:
  /// - `^` → Anchors the regex to the **start** of the string.
  /// - `\w` → Matches **one word character** (typically an uppercase letter).
  /// - `\d{prefixLength}` → Matches **a sequence of `prefixLength` digits**.
  /// - `${middlePattern}` → Inserts the **middle pattern** (e.g., "RS", "(R|M)Q").
  /// - `\d{suffixLength}` → Matches **a sequence of `suffixLength` digits**.
  /// - `${lastDigit}` → Ensures **the last fixed digit is exactly as defined**.
  /// - `$` → Anchors the regex to the **end** of the string (ensures full match).
  ///
  /// Example:
  /// - `ademS.regexPattern` → r`^\w\d{3}RS\d{1}5$`
  /// - `ademPtz.regexPattern` → r`^\w\d{2}[NAGS](R|M)\d{2}4$`
  String get regexPattern =>
      '^\\w\\d{$prefixLength}$middlePattern\\d{$suffixLength}$lastDigit\$';

  String get noDataSymbol => switch (this) {
    AdemType.ademS || AdemType.ademT || AdemType.ademTq => 'NA',
    AdemType.universalT ||
    AdemType.ademPtz ||
    AdemType.ademPtzq ||
    AdemType.ademPtzR ||
    AdemType.ademR ||
    AdemType.ademMi => '0',
  };

  bool get isAdemS => this == AdemType.ademS;
  bool get isAdemT => this == AdemType.ademT;
  bool get isUniversalT => this == AdemType.universalT;
  bool get isAdemTq => this == AdemType.ademTq;
  bool get isAdemPtz => this == AdemType.ademPtz;
  bool get isAdemPtzq => this == AdemType.ademPtzq;  // PTZq: PTZ + TQ
  bool get isAdemPtzR => this == AdemType.ademPtzR;
  bool get isAdemR => this == AdemType.ademR;
  bool get isAdemMi => this == AdemType.ademMi;

  /// Returns true if this device type has Q Monitor (DP monitoring) functionality.
  /// Both ademTq and ademPtzq have Q Monitor capabilities.
  bool get hasQMonitor => isAdemTq || isAdemPtzq;

  bool get isMeterSizeSupported =>
      isAdemS || isAdemT || isUniversalT || isAdemTq || isAdemPtz || isAdemPtzq;

  /// Determines if Super Access Code is supported based on firmware version and AdEM type.
  ///
  /// Minimum firmware requirements:
  /// - AdEM S: D020RT03 or higher
  /// - AdEM T: D020RT03 or higher
  /// - AdEM Ptz: D00XM004 or higher
  /// - AdEM Tq, AdEM Ptz-R, Universal T: Always supported regardless of firmware
  bool isSuperAccessCodeSupported(String firmwareVersion) {
    return switch (this) {
      AdemType.ademS || AdemType.ademT => meetsMinFirmwareVersion(
        firmwareVersion,
        minMajor: 'D',
        minMinor: 2,
      ),
      AdemType.ademPtz => meetsMinFirmwareVersion(
        firmwareVersion,
        minMajor: 'D',
      ),
      AdemType.universalT ||
      AdemType.ademTq ||
      AdemType.ademPtzq ||
      AdemType.ademPtzR ||
      AdemType.ademR ||
      AdemType.ademMi => true,
    };
  }

  /// Determines if Serial number part 2 is supported based on firmware version and AdEM type.
  ///
  /// Minimum firmware requirements:
  /// - AdEM S: D050RS25 or higher
  /// - AdEM T: D050RT33 or higher
  /// - AdEM Ptz: D05XM014 or higher, or E01XR004 or higher
  /// - AdEM Tq, AdEM Ptz-R, Universal T: Always supported regardless of firmware
  bool isSerialNumberPart2Supported(String firmwareVersion) {
    return switch (this) {
      AdemType.ademS => meetsMinFirmwareVersion(
        firmwareVersion,
        minMajor: 'D',
        minMinor: 5,
        minPatch: 2,
      ),
      AdemType.ademT => meetsMinFirmwareVersion(
        firmwareVersion,
        minMajor: 'D',
        minMinor: 5,
        minPatch: 3,
      ),
      AdemType.ademPtz => meetsMinFirmwareVersion(
        firmwareVersion,
        minMajor: 'D',
        minMinor: 5,
        minPatch: 1,
      ),
      AdemType.universalT ||
      AdemType.ademTq ||
      AdemType.ademPtzq ||
      AdemType.ademPtzR ||
      AdemType.ademR ||
      AdemType.ademMi => true,
    };
  }
}

// MARK: Log type

enum LogType {
  daily('daily-logs'),
  interval('interval-logs'),
  event('event-logs'),
  alarm('alarm-logs'),
  q('q-margin-logs'),
  flowDp('dp-logs');

  final String apiValue;

  /// Constructor for LogType enum.
  const LogType(this.apiValue);

  CloudFileType get toCloudFileType => switch (this) {
    LogType.daily => CloudFileType.dailyLog,
    LogType.interval => CloudFileType.intervalLog,
    LogType.event => CloudFileType.eventLog,
    LogType.alarm => CloudFileType.alarmLog,
    LogType.q => CloudFileType.qLog,
    LogType.flowDp => CloudFileType.flowDpLog,
  };
}

enum CloudFileType {
  dailyLog('daily-logs'),
  intervalLog('interval-logs'),
  eventLog('event-logs'),
  alarmLog('alarm-logs'),
  qLog('q-margin-logs'),
  flowDpLog('dp-logs'),
  setupReport('setup-report'),
  setupConfig('setup-config'),
  checkReport('check-report');

  final String apiValue;

  const CloudFileType(this.apiValue);
}

enum Adem25AlarmLogType {
  fullFields(0);

  final int key;

  const Adem25AlarmLogType(this.key);
}

enum Adem25EventLogType {
  fullFields(0);

  final int key;

  const Adem25EventLogType(this.key);
}
