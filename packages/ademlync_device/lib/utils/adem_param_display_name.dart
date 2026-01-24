part of 'adem_param.dart';

extension ParamDisplayName on Param {
  String get displayName => switch (this) {
    Param.serialNumber => 'Serial Number',
    Param.serialNumberPart2 => 'Serial Number Part 2',
    Param.firmwareVersion => 'Firmware Version',
    Param.firmwareChecksum => 'Firmware Checksum',
    Param.date => 'Date',
    Param.time => 'Time',
    Param.gasDayStartTime => 'Gas Day Start Time',
    Param.dateFormat => 'Date Format',
    Param.meterSize => 'Meter Size',
    Param.lastSaveTime => 'Last Save Time',
    Param.lastSaveDate => 'Last Save Date',
    Param.backupIndexCounter => 'Backup Index Counter',
    Param.displayTestPattern => 'Display Test Pattern',
    Param.batteryVoltage => 'Battery Voltage',
    Param.batteryLife => 'Battery Life',
    Param.batteryRemaining => 'Battery Remaining',
    Param.batteryInstallDate => 'Battery Install Date',
    Param.totalFactor => 'Total Factor',
    Param.corVol => 'Cor. Volume',
    Param.corFullVol => 'Full Cor. Vol.',
    Param.corDailyVol => 'Daily Cor. Vol.',
    Param.corPrevDayVol => 'Prev. Day Cor. Vol.',
    Param.corLastSavedVol => 'Last Saved Cor. Vol.',
    Param.corHighResVol => 'High Res. Cor. Vol.',
    Param.uncFullVol => 'Full Unc. Vol.',
    Param.uncVol => 'Unc. Volume',
    Param.uncDailyVol => 'Daily Unc. Vol.',
    Param.uncPrevDayVol => 'Prev. Day Unc. Vol.',
    Param.uncLastSavedVol => 'Last Saved Unc. Vol.',
    Param.uncVolSinceMalf => 'Unc. Vol. Since Malf.',
    Param.uncHighResVol => 'High Res. Unc. Vol.',
    Param.tempFactor => 'Temp. Factor',
    Param.temp => 'Temperature',
    Param.tempHighLimit => 'Temp. High Limit',
    Param.tempLowLimit => 'Temp. Low Limit',
    Param.maxTempDate => 'Max. Temp. Date',
    Param.maxTempTime => 'Max. Temp. Time',
    Param.minTempDate => 'Min. Temp. Date',
    Param.minTempTime => 'Min. Temp. Time',
    Param.maxTemp => 'Max. Temp.',
    Param.minTemp => 'Min. Temp.',
    Param.caseTemp => 'Case Temp.',
    Param.maxCaseTemp => 'Max. Case Temp.',
    Param.minCaseTemp => 'Min. Case Temp.',
    Param.baseTemp => 'Base Temp.',
    Param.pressFactor => 'Press. Factor',
    Param.pressHighLimit => 'Press. High Limit',
    Param.pressLowLimit => 'Press. Low Limit',
    Param.maxPressDate => 'Max. Press. Date',
    Param.maxPressTime => 'Max. Press. Time',
    Param.minPressDate => 'Min. Press. Date',
    Param.minPressTime => 'Min. Press. Time',
    Param.pressTransSn => 'Press. Trans. SN.',
    Param.pressTransRange => 'Press. Trans. Range',
    Param.maxPress => 'Max. Press.',
    Param.minPress => 'Min. Press.',
    Param.absPress => 'Abs. Press.',
    Param.gaugePress => 'Gauge Press.',
    Param.lineGaugePress => 'Line Gauge Press.',
    Param.atmosphericPress => 'Atmospheric Press.',
    Param.basePress => 'Base Press.',
    Param.inputPulseVolUnit => 'Input Pulse Vol. Unit',
    Param.uncFlowRate => 'Unc. Flow Rate',
    Param.corFlowRate => 'Cor. Flow Rate',
    Param.uncPeakFlowRate => 'Unc. Peak Flow Rate',
    Param.uncFlowRateHighLimit => 'Unc. Flow Rate High Limit',
    Param.uncFlowRateLowLimit => 'Unc. Flow Rate Low Limit',
    Param.minAllowFlowRate => 'Min. Allow Flow Rate',
    Param.uncPeakFlowRateTime => 'Unc. Peak Flow Rate Time',
    Param.uncPeakFlowRateDate => 'Unc. Peak Flow Rate Date',
    Param.peakFlowRateResetDate => 'Peak Flow Rate Reset Date',
    Param.peakFlowRateResetTime => 'Peak Flow Rate Reset Time',
    Param.liveSuperXFactor => 'SuperX Factor',
    Param.fixedSuperXFactor => 'SuperX Factor',
    Param.gasMoleCO2 => 'CO<d>2</d>',
    Param.gasMoleH2 => 'H<d>2</d>',
    Param.gasMoleN2 => 'N<d>2</d>',
    Param.gasMoleHs => 'Hs',
    Param.gasMoleHsInEventLog => 'Hs',
    Param.aga8GasComponentMolar => 'AGA-8 Component Molar',
    Param.gasSpecificGravity => 'Specific Gravity',
    Param.isTempTxdrMalf => 'Temp. Trans. Malf.',
    Param.tempTxdrMalfDate => 'Temp.Trans. Malf. Date',
    Param.tempTxdrMalfTime => 'Temp. Trans. Malf. Time',
    Param.isPressTxdrMalf => 'Press. Trans. Malf.',
    Param.pressTxdrMalfDate => 'Press. Trans. Malf. Date',
    Param.pressTxdrMalfTime => 'Press. Trans. Malf. Time',
    Param.isDpTxdrMalf => 'Dp. Trans. Malf',
    Param.dpTxdrMalfDate => 'Dp. Trans. Malf. Date',
    Param.dpTxdrMalfTime => 'Dp. Trans. Malf. Time',
    Param.isBatteryMalf => 'Battery Malf.',
    Param.batteryMalfDate => 'Battery Malf. Date',
    Param.batteryMalfTime => 'Battery Malf. Date Time',
    Param.isMemoryError => 'Memory Error',
    Param.memoryErrorDate => 'Memory Error Date',
    Param.memoryErrorTime => 'Memory Error Time',
    Param.isTempHigh => 'Temp. High',
    Param.isTempLow => 'Temp. Low',
    Param.isPressHigh => 'Press. High',
    Param.isPressLow => 'Press. Low',
    Param.isUncFlowRateHigh => 'Unc. Flow Rate High',
    Param.isUncFlowRateLow => 'Unc. Flow Rate. Low',
    Param.isAlarmOutput => 'Has Alarm Output',
    Param.maxAllowableDp => 'Max. Allowable Dp.',
    Param.diffPress => 'Differential Pressure',
    Param.uncVolUnit => 'Unc. Vol. Unit',
    Param.corVolUnit => 'Cor. Vol. Unit',
    Param.uncVolDigits => 'Unc. Vol. Digits',
    Param.corVolDigits => 'Cor. Vol. Digits',
    Param.dispVolSelect => 'Display Vol. Select',
    Param.uncOutputPulseVolUnit => 'Unc. Output Pulse',
    Param.corOutputPulseVolUnit => 'Cor. Output Pulse',
    Param.outPulseSpacing => 'Output Pulse Spacing',
    Param.outPulseWidth => 'Output Pulse Width',
    Param.superXFactorType => 'SuperX Factor Type',
    Param.superXAlgo => 'SuperX Algorithm',
    Param.intervalLogType => 'Interval Log Type',
    Param.intervalLogInterval => 'Interval Log Duration',
    Param.batteryType => 'Battery Type',
    Param.pressFactorType => 'Press. Factor Type',
    Param.pressUnit => 'Press. Unit',
    Param.pressTransType => 'Press. Trans. Type',
    Param.tempFactorType => 'Temp. Factor Type',
    Param.tempUnit => 'Temp. Unit',
    Param.sealStatus => 'Seal Status',
    Param.pushBtnProvingPulsesOpFunc => 'Prove & Pulse Function',
    Param.showDot => 'Show Dot',
    Param.pressADReadCounts => 'Press. A/D Reading Counters',
    Param.pressCalib1PtOffset => '1 Points Press. Offset',
    Param.threePtPressCalibParams => '3 Point Press. Calibration Params',
    Param.tempADReadCounts => 'Temp. A/D Reading Counters',
    Param.tempCalib1PtOffset => '1 Points Temp. Offset',
    Param.threePtTempCalibParams => '3 Point Temp. Calibration Params',
    Param.dpADReadingCts => 'D.P. A/D Reading Counters',
    Param.dpCalib1PtOffset => '1 Points D.P. Offset',
    Param.threePtDpCalibParams => '3 Point D.P. Calibration Params',
    Param.pressDispRes => 'Press. Display Res.',
    Param.displacement => 'Displacement',
    Param.provingVol => 'Proving Vol.',
    Param.outputPulseChannel1 => 'Output Pulse Channel 1',
    Param.outputPulseChannel2 => 'Output Pulse Channel 2',
    Param.outputPulseChannel3 => 'Output Pulse Channel 3',
    Param.qMonitorFunction => 'Q Margin',
    Param.dpSensorSn => 'D.P. Sensor S.N.',
    Param.dpSensorRange => 'D.P. Sensor Range',
    Param.dpTestPressure => 'D.P. Test Press.',
    Param.qCutoffTempLow => 'Q Cutoff Temp. Low',
    Param.qCutoffTempHigh => 'Q Cutoff Temp. High',
    Param.qCoefficientA => 'Q Coefficient A',
    Param.qCoefficientC => 'Q Coefficient C',
    Param.diffUncertainty => 'Diff. Uncertainty',
    Param.qSafetyMultiplier => 'Q Safety Multiplier',
    Param.pressureCompensationFactor1 => 'Press. Comp. Factor 1',
    Param.pressureCompensationFactor2 => 'Press. Comp. Factor 2',
    Param.pressureCompensationFactor3 => 'Press. Comp. Factor 3',
    Param.pressureCompensationFactor4 => 'Press. Comp. Factor 4',
    Param.pressureCompensationFactor5 => 'Press. Comp. Factor 5',
    Param.pressureCompensationFactor6 => 'Press. Comp. Factor 6',
    Param.pressureCompensationFactor7 => 'Press. Comp. Factor 7',
    Param.pressureCompensationFactor8 => 'Press. Comp. Factor 8',
    Param.pressureCompensationFactor9 => 'Press. Comp. Factor 9',
    Param.pressureCompensationFactor10 => 'Press. Comp. Factor 10',
    Param.pressureCompensationFactor11 => 'Press. Comp. Factor 11',
    Param.pressureCompensationFactor12 => 'Press. Comp. Factor 12',
    Param.pushbuttonProvingMode => 'Push Button Proving Mode',
    Param.pushbuttonOutputPulses => 'Push Button Output Pulses',
    Param.intervalField5 => 'Interval Field 5',
    Param.intervalField6 => 'Interval Field 6',
    Param.intervalField7 => 'Interval Field 7',
    Param.intervalField8 => 'Interval Field 8',
    Param.intervalField9 => 'Interval Field 9',
    Param.intervalField10 => 'Interval Field 10',
    Param.cstmDispParam1 => 'Customer Display 1',
    Param.cstmDispParam2 => 'Customer Display 2',
    Param.cstmDispParam3 => 'Customer Display 3',
    Param.cstmDispParam4 => 'Customer Display 4',
    Param.cstmDispParam5 => 'Customer Display 5',
    Param.cstmDispParam6 => 'Customer Display 6',
    Param.cstmDispParam7 => 'Customer Display 7',
    Param.cstmDispParam8 => 'Customer Display 8',
    Param.cstmDispParam9 => 'Customer Display 9',
    Param.cstmDispParam10 => 'Customer Display 10',
    Param.cstmDispParam11 => 'Customer Display 11',
    Param.cstmDispParam12 => 'Customer Display 12',
    Param.cstmDispParam13 => 'Customer Display 13',
    Param.cstmDispParam14 => 'Customer Display 14',
    Param.cstmDispParam15 => 'Customer Display 15',

    // MARK: AdEM 25
    Param.tmr1 => 'TMR 1',
    Param.tmr2 => 'TMR 2',
    Param.overSpeed => 'Over Speed',
    Param.customerId => 'Customer ID',
    Param.legacyUncorrectedIndexRollover => 'UC Index Rollover',
    Param.legacyCorrectedIndexRollover => 'CC Index Rollover',
    Param.uncorrectedIndexRollover => 'UC Index Rollover',
    Param.correctedIndexRollover => 'CC Index Rollover',
    Param.isUncIndexRolledOver => 'UC Index Rolled Over',
    Param.isCorIndexRolledOver => 'CC Index Rolled Over',
    Param.provingTimeout => 'Proving Time-out',
    Param.productType => 'Product Type',

    // MARK: Other
    _ => '-',
  };
}

extension ChemDisplayName on Aga8Param {
  String get displayName => switch (this) {
    Aga8Param.methane => 'Methane',
    Aga8Param.nitrogen => 'Nitrogen',
    Aga8Param.carbonDioxide => 'Carbon Dioxide',
    Aga8Param.ethane => 'Ethane',
    Aga8Param.propane => 'Propane',
    Aga8Param.water => 'Water',
    Aga8Param.hydrogenSulphide => 'Hydrogen Sulphide',
    Aga8Param.hydrogen => 'Hydrogen',
    Aga8Param.carbonMonoxide => 'Carbon Monoxide',
    Aga8Param.oxygen => 'Oxygen',
    Aga8Param.isoButane => 'iso-Butane',
    Aga8Param.nButane => 'n-Butane',
    Aga8Param.isoPentane => 'iso-Pentane',
    Aga8Param.nPentane => 'n-Pentane',
    Aga8Param.nHexane => 'n-Hexane',
    Aga8Param.nHeptane => 'n-Heptane',
    Aga8Param.nOctane => 'n-Octane',
    Aga8Param.nNonane => 'n-Nonane',
    Aga8Param.nDecane => 'n-Decane',
    Aga8Param.helium => 'Helium',
    Aga8Param.argon => 'Argon',
  };

  String get formula => switch (this) {
    Aga8Param.methane => 'CH<d>4</d>',
    Aga8Param.nitrogen => 'N<d>2</d>',
    Aga8Param.carbonDioxide => 'CO<d>2</d>',
    Aga8Param.ethane => 'C<d>2</d>H<d>2</d>',
    Aga8Param.propane => 'C<d>3</d>H<d>8</d>',
    Aga8Param.water => 'H<d>2</d>O',
    Aga8Param.hydrogenSulphide => 'H<d>2</d>S',
    Aga8Param.hydrogen => 'H<d>2</d>',
    Aga8Param.carbonMonoxide => 'CO',
    Aga8Param.oxygen => 'O<d>2</d>',
    Aga8Param.isoButane => 'i-C<d>4</d>H<d>10</d>',
    Aga8Param.nButane => 'n-C<d>4</d>H<d>10</d>',
    Aga8Param.isoPentane => 'i-C<d>5</d>H<d>12</d>',
    Aga8Param.nPentane => 'n-C<d>5</d>H<d>12</d>',
    Aga8Param.nHexane => 'n-C<d>6</d>H<d>14</d>',
    Aga8Param.nHeptane => 'n-C<d>7</d>H<d>16</d>',
    Aga8Param.nOctane => 'n-C<d>8</d>H<d>18</d>',
    Aga8Param.nNonane => 'n-C<d>9</d>H<d>20</d>',
    Aga8Param.nDecane => 'n-C<d>10</d>H<d>22</d>',
    Aga8Param.helium => 'He',
    Aga8Param.argon => 'Ar',
  };
}

extension MeterSeriesDisplayName on MeterSerial {
  String get displayName => switch (this) {
    MeterSerial.rmImperial => 'Romet RM Imperial',
    MeterSerial.rmSoftMetric => 'Romet RM Soft Metric',
    MeterSerial.rmHardMetric => 'Romet G Hard Metric',
    MeterSerial.lmmaImperial => 'Dresser LMMA Imperial',
    MeterSerial.lmmaMetric => 'Dresser LMMA Metric',
    MeterSerial.b3Imperial => 'Dresser B3 Imperial',
    MeterSerial.b3Metric => 'Dresser B3 Metric',
    MeterSerial.rmtImperial => 'Romet RMT Imperial',
    MeterSerial.rmtSoftMetric => 'Romet RMT Soft Metric',
    MeterSerial.hpB3Imperial => 'Dresser B3 HPC Imperial',
    MeterSerial.hpB3Metric => 'Dresser B3 HPC Metric',
  };
}

extension MeasSysDisplayName on MeterSystem {
  String get displayName => switch (this) {
    MeterSystem.imperial => 'Imperial',
    MeterSystem.metric => 'Metric',
  };
}

extension DisplayVolSelectDisplayName on DispVolSelect {
  String get displayName => switch (this) {
    DispVolSelect.corVol => 'Cor. Volume',
    DispVolSelect.uncVol => 'Unc. Volume',
  };
}

extension VolumeUnitDisplayName on VolumeUnit {
  String get displayName => switch (this) {
    VolumeUnit.cf001 => '0.01 Ft<u>3</u>',
    VolumeUnit.cf1 => '1 Ft<u>3</u>',
    VolumeUnit.cf10 => '10 Ft<u>3</u>',
    VolumeUnit.cf100 => 'CCF',
    VolumeUnit.cf1000 => 'MCF',
    VolumeUnit.cf10000 => '10000 Ft<u>3</u>',
    VolumeUnit.m300001 => '0.0001 M<u>3</u>',
    VolumeUnit.m3001 => '0.01 M<u>3</u>',
    VolumeUnit.m301 => '0.10 M<u>3</u>',
    VolumeUnit.m31 => '1.00 M<u>3</u>',
    VolumeUnit.m310 => '10.00 M<u>3</u>',
    VolumeUnit.m3100 => '100.00 M<u>3</u>',
  };
}

extension InputPulseVolumeUnitDisplayName on InputPulseVolumeUnit {
  String get displayName => switch (this) {
    InputPulseVolumeUnit.cf1 => '1 Ft<u>3</u>',
    InputPulseVolumeUnit.cf5 => '5 Ft<u>3</u>',
    InputPulseVolumeUnit.cf10 => '10 Ft<u>3</u>',
    InputPulseVolumeUnit.cf100 => 'CCF',
    InputPulseVolumeUnit.cf1000 => 'MCF',
    InputPulseVolumeUnit.m3001 => '0.01 M<u>3</u>',
    InputPulseVolumeUnit.m301 => '0.10 M<u>3</u>',
    InputPulseVolumeUnit.m31 => '1.00 M<u>3</u>',
    InputPulseVolumeUnit.m310 => '10.00 M<u>3</u>',
    InputPulseVolumeUnit.m3100 => '100.00 M<u>3</u>',
  };
}

extension VolumeDigitsDisplayName on VolDigits {
  String get displayName => switch (this) {
    VolDigits.digit8 => '8 digits',
    VolDigits.digit7 => '7 digits',
    VolDigits.digit6 => '6 digits',
    VolDigits.digit5 => '5 digits',
  };
}

extension PressureDisplayResolutionDisplayName on PressDispRes {
  String get displayName => switch (this) {
    PressDispRes.decimal0 => '0 decimal place',
    PressDispRes.decimal1 => '1 decimal place',
    PressDispRes.decimal2 => '2 decimal place',
    PressDispRes.decimal3 => '3 decimal place',
    PressDispRes.decimal4 => '4 decimal place',
  };
}

extension OutputPulseSpacingDisplayName on OutPulseSpacing {
  String get displayName => switch (this) {
    OutPulseSpacing.ms50 => '50 ms',
    OutPulseSpacing.ms750 => '750 ms',
    OutPulseSpacing.ms150 => '150 ms',
    OutPulseSpacing.ms200 => '200 ms',
    OutPulseSpacing.ms250 => '250 ms',
    OutPulseSpacing.ms350 => '350 ms',
    OutPulseSpacing.ms500 => '500 ms',
    OutPulseSpacing.pulseOff => 'Pulse Off',
  };
}

extension OutputPulseWidthDisplayName on OutPulseWidth {
  String get displayName => switch (this) {
    OutPulseWidth.ms5 => '5 ms',
    OutPulseWidth.ms10 => '10 ms',
    OutPulseWidth.ms15 => '15 ms',
    OutPulseWidth.ms20 => '20 ms',
    OutPulseWidth.ms25 => '25 ms',
    OutPulseWidth.ms30 => '30 ms',
    OutPulseWidth.ms35 => '35 ms',
    OutPulseWidth.ms40 => '40 ms',
    OutPulseWidth.ms45 => '45 ms',
    OutPulseWidth.ms50 => '50 ms',
    OutPulseWidth.ms65 => '65 ms',
    OutPulseWidth.ms120 => '120 ms',
    OutPulseWidth.ms125 => '125 ms',
    OutPulseWidth.ms250 => '250 ms',
  };
}

extension PressureFactorTypeDisplayName on FactorType {
  String get displayName => switch (this) {
    FactorType.live => 'Live',
    FactorType.fixed => 'Fixed',
  };
}

extension SuperXAlgorithmDisplayName on SuperXAlgo {
  String get displayName => switch (this) {
    SuperXAlgo.nx19 => 'NX-19',
    SuperXAlgo.aga8 => 'AGA-8',
    SuperXAlgo.sgerg88 => 'Sgerg',
    SuperXAlgo.aga8G1 => 'AGA-8 G1',
    SuperXAlgo.aga8G2 => 'AGA-8 G2',
  };
}

extension IntervalTypeDisplayName on IntervalLogType {
  String get displayName => switch (this) {
    IntervalLogType.fullFields => 'Full Fields',
    IntervalLogType.selectableFields => 'Selectable Fields',
    IntervalLogType.fixed4Fields => 'Fixed 4 Fields',
  };
}

extension IntervalSettingDisplayName on IntervalLogInterval {
  String get displayName => switch (this) {
    IntervalLogInterval.minutes5 => '5 minutes',
    IntervalLogInterval.minutes15 => '15 minutes',
    IntervalLogInterval.minutes30 => '30 minutes',
    IntervalLogInterval.minutes60 => '60 minutes',
    IntervalLogInterval.hours2 => '2 hours',
    IntervalLogInterval.hours6 => '6 hours',
    IntervalLogInterval.hours12 => '12 hours',
    IntervalLogInterval.hours24 => '24 hours',
  };
}

extension OutputChannelDisplayName on PulseChannel {
  String get displayName => switch (this) {
    PulseChannel.corVolPulse => 'Cor. Vol. Pulse',
    PulseChannel.uncVolPulse => 'Unc. Vol. Pulse',
    PulseChannel.malfAlarmPulse => 'Malf. Alarm Pulse',
  };
}

extension PressureUnitDisplayName on PressUnit {
  String get displayName => switch (this) {
    PressUnit.psi => 'PSI',
    PressUnit.kpa => 'kPa',
    PressUnit.bar => 'Bar',
  };
}

extension TemperatureUnitDisplayName on TempUnit {
  String get displayName => switch (this) {
    TempUnit.f => 'F',
    TempUnit.c => 'C',
  };
}

extension LineGaugePressureUnitExt on LineGaugePressUnit {
  String get displayName => switch (this) {
    LineGaugePressUnit.psig => 'PSIG',
    LineGaugePressUnit.kpag => 'kPaG',
  };
}

extension DifferentialPressureUnitExt on DiffPressUnit {
  String get displayName => switch (this) {
    DiffPressUnit.inH2o => 'inH<d>2</d>O',
    DiffPressUnit.kpa => 'kPa',
  };
}

extension PressureTransducerTypeExt on PressTransType {
  String get displayName => switch (this) {
    PressTransType.gauge => 'Gauge',
    PressTransType.absolute => 'Absolute',
  };
}

extension IntervalFieldDisplayName on IntervalLogField {
  String get displayName => switch (this) {
    IntervalLogField.corTotalVol => 'Total Cor. Vol.',
    IntervalLogField.uncTotalVol => 'Total Unc. Vol.',
    IntervalLogField.maxPress => 'Max. Press.',
    IntervalLogField.maxPressTime => 'Max. Press. Time',
    IntervalLogField.minPress => 'Min. Press.',
    IntervalLogField.minPressTime => 'Min. Press. Time',
    IntervalLogField.maxTemp => 'Max. Temp.',
    IntervalLogField.maxTempTime => 'Max. Temp. Time',
    IntervalLogField.minTemp => 'Min. Temp.',
    IntervalLogField.minTempTime => 'Min. Temp. Time',
    IntervalLogField.uncMaxFlowRate => 'Max. Unc. Flow Rate',
    IntervalLogField.uncMaxFlowRateTime => 'Max. Unc. Flow Rate Time',
    IntervalLogField.uncMinFlowRate => 'Min. Unc. Flow Rate',
    IntervalLogField.uncMinFlowRateTime => 'Min. Unc. Flow Rate Time',
    IntervalLogField.avgBatteryVoltage => 'Avg. Battery Voltage',
    IntervalLogField.avgTotalFactor => 'Avg. Total Factor',
    IntervalLogField.uncAvgFlowRate => 'Avg. Unc. Flow Rate',
    // IntervalField.superXFactor=>locale.superXFactorString,
    // IntervalField.uncVolSinceMalf=>locale.uncVolSinceMalfString,
    IntervalLogField.notSet => 'Not Set',
  };
}

extension BatteryTypeDisplayName on BatteryType {
  String get displayName => switch (this) {
    BatteryType.largeLithium => 'Large Lithium',
    BatteryType.largeAlkaline => 'Large Alkaline',
    BatteryType.smallLithium => 'Small Lithium',
    BatteryType.smallAlkaline => 'Small Alkaline',
  };
}

extension AlarmLogTypeDisplayName on AlarmLogType {
  String get displayName => switch (this) {
    AlarmLogType.rise => 'Rise',
    AlarmLogType.acknowledge => 'Acknowledge',
    AlarmLogType.clear => 'Clear',
  };
}

extension EventLogTypeDisplayName on EventLogActionType {
  String get displayName => switch (this) {
    EventLogActionType.itemChange => 'Item Change',
    EventLogActionType.calibration => 'Calibration',
    EventLogActionType.download => 'Event Log Update',
    EventLogActionType.shutDown => 'Shut Down',
    EventLogActionType.aga8Download => 'AGA8 Download',
    EventLogActionType.slaveFirmwareUpdate => 'Slave Firmware Update',
    EventLogActionType.masterFirmwareUpdate => 'Master Firmware Update',
    EventLogActionType.firmwareUpdate => 'Firmware Update',
  };
}

extension QStatusDisplayName on QStatus {
  String get displayName => switch (this) {
    QStatus.noData => 'Flow Rate out of range',
    QStatus.check => 'Check Qm',
    QStatus.pass => 'Qm Pass',
  };
}

extension UnitDateFormatDisplayName on UnitDateFmt {
  String get displayName => switch (this) {
    UnitDateFmt.monthDateYear => 'MM-DD-YY',
    UnitDateFmt.dateMonthYear => 'DD-MM-YY',
    UnitDateFmt.yearMonthDate => 'YY-MM-DD',
  };
}

extension FlowRateTypeDisplayName on FlowRateType {
  String get displayName => switch (this) {
    FlowRateType.cf => 'Ft<u>3</u>/H',
    FlowRateType.cm => 'M<u>3</u>/H',
  };
}

extension VolumeTypeDisplayName on VolumeType {
  String get displayName => switch (this) {
    VolumeType.cf => 'Ft<u>3</u>',
    VolumeType.cm => 'M<u>3</u>',
  };
}

extension MeterSizeDisplayName on MeterSize {
  String get displayName => switch (this) {
    // Romet Imperial Meters
    MeterSize.rm600 => 'RM 600',
    MeterSize.rm1000 => 'RM 1000',
    MeterSize.rm1500 => 'RM 1500',
    MeterSize.rm2000 => 'RM 2000',
    MeterSize.rm3000 => 'RM 3000',
    MeterSize.rm5000 => 'RM 5000',
    MeterSize.rm7000 => 'RM 7000',
    MeterSize.rm11000 => 'RM 11000',
    MeterSize.rm16000 => 'RM 16000',
    MeterSize.rm23000 => 'RM 23000',
    MeterSize.rm25000 => 'RM 25000',
    MeterSize.rm38000 => 'RM 38000',
    MeterSize.rm56000 => 'RM 56000',

    // Dresser Imperial Meters
    MeterSize.m1_5LmmaI => '1.5MLMMA',
    MeterSize.m3LmmaI => '3MLMMA',
    MeterSize.m5LmmaI => '5MLMMA',
    MeterSize.m7LmmaI => '7MLMMA',
    MeterSize.m11LmmaI => '11MLMMA',
    MeterSize.m16LmmaI => '16MLMMA',
    MeterSize.m23LmmaI => '23MLMMA',
    MeterSize.m38LmmaI => '38MLMMA',
    MeterSize.m56LmmaI => '56MLMMA',
    MeterSize.m102LmmaI => '102MLMMA',

    // Romet Hard Metric Meters
    MeterSize.g10 => 'G 10',
    MeterSize.g16 => 'G 16',
    MeterSize.g25 => 'G 25',
    MeterSize.g40 => 'G 40',
    MeterSize.g65 => 'G 65',
    MeterSize.g100 => 'G 100',
    MeterSize.g160 => 'G 160',
    MeterSize.g250 => 'G 250',
    MeterSize.g400 => 'G 400',
    MeterSize.g400_150 => 'G 400-150',
    MeterSize.g650 => 'G 650',
    MeterSize.g1000 => 'G 1000',

    // Romet Soft Metric Meters
    MeterSize.rm16 => 'RM 16',
    MeterSize.rm30 => 'RM 30',
    MeterSize.rm40 => 'RM 40',
    MeterSize.rm55 => 'RM 55',
    MeterSize.rm85 => 'RM 85',
    MeterSize.rm140 => 'RM 140',
    MeterSize.rm200 => 'RM 200',
    MeterSize.rm300 => 'RM 300',
    MeterSize.rm450 => 'RM 450',
    MeterSize.rm650 => 'RM 650',
    MeterSize.rm700 => 'RM 700',
    MeterSize.rm1100 => 'RM 1100',
    MeterSize.rm1600 => 'RM 160',

    // Dresser Metric Meters
    MeterSize.m1_5LmmaM => '1.5M(40)',
    MeterSize.m3LmmaM => '3M(85)',
    MeterSize.m5LmmaM => '5M(140)',
    MeterSize.m7LmmaM => '7M(200)',
    MeterSize.m11LmmaM => '11M(300)',
    MeterSize.m16LmmaM => '16M(450)',

    // Romet RMT Imperial
    MeterSize.rmt600 => 'RMT 600',
    MeterSize.rmt1000 => 'RMT 1000',
    MeterSize.rmt1500 => 'RMT 1500',
    MeterSize.rmt2000 => 'RMT 2000',
    MeterSize.rmt3000 => 'RMT 3000',
    MeterSize.rmt5000 => 'RMT 5000',
    MeterSize.rmt7000 => 'RMT 7000',
    MeterSize.rmt11000 => 'RMT 11000',
    MeterSize.rmt16000 => 'RMT 16000',
    MeterSize.rmt23000 => 'RMT 23000',

    // Romet RMT Soft Metric
    MeterSize.rmt16 => 'RMT 16',
    MeterSize.rmt30 => 'RMT 30',
    MeterSize.rmt40 => 'RMT 40',
    MeterSize.rmt55 => 'RMT 55',
    MeterSize.rmt85 => 'RMT 85',
    MeterSize.rmt140 => 'RMT 140',
    MeterSize.rmt200 => 'RMT 200',
    MeterSize.rmt300 => 'RMT 300',
    MeterSize.rmt450 => 'RMT 450',
    MeterSize.rmt650 => 'RMT 650',

    // Dresser B3 roots Imperial CF
    MeterSize.c8B3I => '8C175I',
    MeterSize.c11B3I => '11C175I',
    MeterSize.c15B3I => '15C175I',
    MeterSize.m2B3I => '2M175I',
    MeterSize.m3B3I => '3M175I',
    MeterSize.m5B3I => '5M175I',
    MeterSize.m7B3I => '7M175I',
    MeterSize.m11B3I => '11M175I',
    MeterSize.m16B3I => '16M175I',
    MeterSize.m23B3I => '23M175I',
    MeterSize.m23_232B3I => '23M232I',
    MeterSize.m38B3I => '38M175I',
    MeterSize.m1_300B3I => '1M300I',
    MeterSize.m3_300B3I => '3M300I',
    MeterSize.m56B3I => '56M175I',

    // Dresser B3 roots Metric CM
    MeterSize.c8B3M => '8C175M',
    MeterSize.c11B3M => '11C175M',
    MeterSize.c15B3M => '15C175M',
    MeterSize.m2B3M => '2M175M',
    MeterSize.m3B3M => '3M175M',
    MeterSize.m5B3M => '5M175M',
    MeterSize.m7B3M => '7M175M',
    MeterSize.m11B3M => '11M175M',
    MeterSize.m16B3M => '16M175M',
    MeterSize.m23B3M => '23M175M',
    MeterSize.m23_232B3M => '23M232M',
    MeterSize.m38B3M => '38M175M',
    MeterSize.m1_300B3M => '1M300M',
    MeterSize.m3_300B3M => '3M300M',
    MeterSize.m56B3M => '56M175M',

    // HP Imperial Dresser Roots B3 Meter
    MeterSize.hp1M740I => '1M740 I',
    MeterSize.hp3M740I => '3M740 I',
    MeterSize.hp5M740I => '5M740 I',
    MeterSize.hp7M740I => '7M740 I',
    MeterSize.hp11M740I => '11M740 I',

    // HP Metric Dresser Roots B3 Meter
    MeterSize.hp1M740M => '1M740 M',
    MeterSize.hp3M740M => '3M740 M',
    MeterSize.hp5M740M => '5M740 M',
    MeterSize.hp7M740M => '7M740 M',
    MeterSize.hp11M740M => '11M740 M',
  };
}
