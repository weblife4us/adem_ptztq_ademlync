import 'package:ademlync_device/ademlync_device.dart';

import 'date_time_fmt_manager.dart';

class ParamFormatManager {
  bool canDecode(Param key, String? value) {
    return decode(key, value) != null;
  }

  /// Decode returned string to date and to displayable value
  String? decodeToDisplayValue(Param key, String? value, Adem adem) {
    final volumeType = adem.volumeType;
    final decimal = key.decimal(adem);

    return switch (decode(key, value)) {
      MeterSize o => o.displayName,
      UnitDateFmt o => o.displayName,
      BatteryType o => o.displayName,
      SuperXAlgo o => o.displayName,
      IntervalLogInterval o => o.displayName,
      IntervalLogType o => o.displayName,
      DispVolSelect o => o.displayName,
      VolDigits o => o.displayName,
      OutPulseSpacing o => o.displayName,
      OutPulseWidth o => o.displayName,
      PressTransType o => o.displayName,
      PressUnit o => o.displayName,
      TempUnit o => o.displayName,
      InputPulseVolumeUnit o => o.displayName,
      PressDispRes o => o.displayName,
      VolumeUnit o => o.displayName,
      FactorType o => o.displayName,
      IntervalLogField o => o.displayName,
      PulseChannel o => o.displayName,
      CustDispItem o when o == CustDispItem.notSet => 'Not Set',
      CustDispItem o => o.toParam(adem).displayName,
      String o => o,
      bool o => o.toString(),
      int o => o.toString(),
      double o when _isHighResParam(key) =>
        volumeType.highResVolMultiplier(o)?.toStringAsFixed(decimal),
      double o when _isFullVolParam(key) =>
        volumeType.volumeMultiplier(o)?.toStringAsFixed(decimal),
      double o => o.toStringAsFixed(decimal),
      DateTime o when _isDateParam(key) => DateTimeFmtManager.formatDate(o),
      DateTime o when _isTimeParam(key) => DateTimeFmtManager.formatTime(o),
      _ => null,
    };
  }

  dynamic autoDecode(Param key, Map<Param, AdemResponse?> map) {
    return decode(key, map[key]?.body);
  }

  /// Decode returned string to date
  dynamic decode(Param key, String? value) {
    return switch (key) {
      // Enum
      Param.meterSize => MeterSize.from(value),
      Param.dateFormat => UnitDateFmt.from(value),
      Param.batteryType => BatteryType.from(value),
      Param.superXAlgo => SuperXAlgo.from(value),
      Param.intervalLogInterval => IntervalLogInterval.from(value),
      Param.intervalLogType => IntervalLogType.from(value),
      Param.dispVolSelect => DispVolSelect.from(value),
      Param.corVolDigits || Param.uncVolDigits => VolDigits.from(value),
      Param.outPulseSpacing => OutPulseSpacing.from(value),
      Param.outPulseWidth => OutPulseWidth.from(value),
      Param.pressTransType => PressTransType.from(value),
      Param.pressUnit => PressUnit.from(value),
      Param.tempUnit => TempUnit.from(value),
      Param.inputPulseVolUnit => InputPulseVolumeUnit.from(value),
      Param.pressDispRes => PressDispRes.from(value),
      Param.outputPulseChannel3 => PulseChannel.from(value),
      Param.aga8GasComponentMolar => Aga8Config.from(value),

      // Volume unit
      Param.corVolUnit ||
      Param.corOutputPulseVolUnit ||
      Param.uncVolUnit ||
      Param.uncOutputPulseVolUnit => VolumeUnit.from(value),

      // Factor
      Param.tempFactorType ||
      Param.pressFactorType ||
      Param.superXFactorType => FactorType.from(value),

      // Interval Field
      Param.intervalField5 ||
      Param.intervalField6 ||
      Param.intervalField7 ||
      Param.intervalField8 ||
      Param.intervalField9 ||
      Param.intervalField10 => IntervalLogField.from(value),

      // Output pulse channel
      Param.outputPulseChannel1 ||
      Param.outputPulseChannel2 ||
      Param.outputPulseChannel3 => PulseChannel.from(value),

      // Customer display
      Param.cstmDispParam1 ||
      Param.cstmDispParam2 ||
      Param.cstmDispParam3 ||
      Param.cstmDispParam4 ||
      Param.cstmDispParam5 ||
      Param.cstmDispParam6 ||
      Param.cstmDispParam7 ||
      Param.cstmDispParam8 ||
      Param.cstmDispParam9 ||
      Param.cstmDispParam10 ||
      Param.cstmDispParam11 ||
      Param.cstmDispParam12 ||
      Param.cstmDispParam13 ||
      Param.cstmDispParam14 ||
      Param.cstmDispParam15 => CustDispItem.from(value),

      // String
      Param.firmwareVersion ||
      Param.productType ||
      Param.serialNumber ||
      Param.serialNumberPart2 ||
      Param.firmwareChecksum ||
      Param.displayTestPattern ||
      Param.dpSensorSn => value?.trim() == 'NA' ? null : value,

      // Bool
      Param.isPressHigh ||
      Param.isPressLow ||
      Param.isPressTxdrMalf ||
      Param.isTempHigh ||
      Param.isTempLow ||
      Param.isTempTxdrMalf ||
      Param.isBatteryMalf ||
      Param.isAlarmOutput ||
      Param.isUncFlowRateHigh ||
      Param.isUncFlowRateLow ||
      Param.qMonitorFunction ||
      Param.isDpTxdrMalf ||
      Param.pushBtnProvingPulsesOpFunc ||
      Param.isMemoryError ||
      Param.sealStatus ||
      Param.isUncIndexRolledOver ||
      Param.isCorIndexRolledOver ||
      Param.showDot => DataParser.asBool(value),

      // Int
      Param.batteryRemaining ||
      Param.corVol ||
      Param.provingVol ||
      Param.uncVol ||
      Param.uncVolSinceMalf ||
      Param.corDailyVol ||
      Param.uncDailyVol ||
      Param.corPrevDayVol ||
      Param.uncPrevDayVol ||
      Param.corLastSavedVol ||
      Param.uncLastSavedVol ||
      Param.backupIndexCounter ||
      Param.pressTransSn ||
      Param.pressADReadCounts ||
      Param.tempADReadCounts ||
      Param.batteryLife ||
      Param.legacyUncorrectedIndexRollover ||
      Param.legacyCorrectedIndexRollover ||
      Param.uncorrectedIndexRollover ||
      Param.correctedIndexRollover ||
      Param.provingTimeout ||
      Param.gasMoleHs => DataParser.asInt(value),

      // Double
      Param.batteryVoltage ||
      Param.corFlowRate ||
      Param.uncFlowRate ||
      Param.tempFactor ||
      Param.basePress ||
      Param.atmosphericPress ||
      Param.gaugePress ||
      Param.absPress ||
      Param.pressFactor ||
      Param.maxPress ||
      Param.minPress ||
      Param.fixedSuperXFactor ||
      Param.liveSuperXFactor ||
      Param.totalFactor ||
      Param.uncPeakFlowRate ||
      Param.pressTransRange ||
      Param.pressHighLimit ||
      Param.pressLowLimit ||
      Param.uncFlowRateHighLimit ||
      Param.uncFlowRateLowLimit ||
      Param.gasSpecificGravity ||
      Param.gasMoleN2 ||
      Param.gasMoleCO2 ||
      Param.gasMoleH2 ||
      Param.lineGaugePress ||
      Param.minAllowFlowRate ||
      Param.dpSensorRange ||
      Param.maxAllowableDp ||
      Param.pressCalib1PtOffset ||
      Param.dpCalib1PtOffset ||
      Param.diffPress ||
      Param.tempCalib1PtOffset ||
      Param.dpTestPressure ||
      Param.qCutoffTempLow ||
      Param.qCutoffTempHigh ||
      Param.qCoefficientA ||
      Param.qCoefficientC ||
      Param.diffUncertainty ||
      Param.qSafetyMultiplier ||
      Param.gasMoleHsInEventLog => DataParser.asDouble(value),
      Param.displacement =>
        value == null || value.isEmpty || DataParser.asDouble(value) == null
            ? null
            : DataParser.asDouble(value.contains('.') ? value : '0.$value'),

      // Multi Double
      Param.corHighResVol ||
      Param.uncHighResVol ||
      Param.corFullVol ||
      Param.uncFullVol => DataParser.asNum(value),

      // Temp
      Param.temp ||
      Param.maxTemp ||
      Param.minTemp ||
      Param.caseTemp ||
      Param.maxCaseTemp ||
      Param.minCaseTemp ||
      Param.baseTemp ||
      Param.tempHighLimit ||
      Param.tempLowLimit => DataParser.asTemp(value),

      // Date
      Param.date ||
      Param.lastSaveDate ||
      Param.maxTempDate ||
      Param.minTempDate ||
      Param.maxPressDate ||
      Param.minPressDate ||
      Param.pressTxdrMalfDate ||
      Param.tempTxdrMalfDate ||
      Param.batteryMalfDate ||
      Param.memoryErrorDate ||
      Param.uncPeakFlowRateDate ||
      Param.batteryInstallDate ||
      Param.dpTxdrMalfDate ||
      Param.peakFlowRateResetDate => DataParser.asDate(value),

      // Time
      Param.time ||
      Param.gasDayStartTime ||
      Param.lastSaveTime ||
      Param.maxTempTime ||
      Param.minTempTime ||
      Param.maxPressTime ||
      Param.minPressTime ||
      Param.pressTxdrMalfTime ||
      Param.tempTxdrMalfTime ||
      Param.batteryMalfTime ||
      Param.memoryErrorTime ||
      Param.uncPeakFlowRateTime ||
      Param.dpTxdrMalfTime ||
      Param.peakFlowRateResetTime => DataParser.asTime(value),
      _ => null,
    };
  }

  String? encodeFromDisplayValue(Param key, dynamic value) {
    final string = switch (value) {
      MeterSize o => o.receiveKey,
      CustDispItem o => o.receiveKey.toAdemStringFmt(),
      VolumeUnit o => o.sendKey,
      UnitDateFmt o => o.sendKey,
      DispVolSelect o => o.sendKey,
      VolDigits o => o.sendKey,
      OutPulseSpacing o => o.sendKey,
      OutPulseWidth o => o.sendKey,
      PressTransType o => o.sendKey,
      FactorType o => o.sendKey,
      SuperXAlgo o => o.sendKey,
      PulseChannel o => o.sendKey,
      IntervalLogInterval o => o.sendKey,
      IntervalLogType o => o.sendKey,
      String o => o,
      int o => o.toAdemStringFmt(),
      double o when _isDoubleWithSParam(key) && key == Param.baseTemp =>
        o.toAdemStringFmt(
          decimal: o.toString().split('.').last.length + 1,
          prefix: 'S',
        ),
      double o when _isDoubleWithSParam(key) => o.toAdemStringFmt(
        decimal: o.toString().split('.').last.length,
        prefix: 'S',
      ),
      double o => o.toAdemStringFmt(
        decimal: o.toString().split('.').last.length,
      ),
      DateTime o when _isTimeParam(key) => unitTimeFmt.format(o),
      _ => null,
    };

    return encode(key, string);
  }

  String? encode(Param key, String? value) {
    return switch (value) {
      String o when key == Param.meterSize => MeterSize.from(o)?.sendKey,
      String o when _isCustomDisplayParam(key) => CustDispItem.from(
        o,
      )?.sendKey.toAdemStringFmt(),
      String o => o,
      _ => null,
    };
  }

  bool _isDoubleWithSParam(Param key) {
    return switch (key) {
      Param.basePress || Param.baseTemp || Param.atmosphericPress => true,
      _ => false,
    };
  }

  bool _isCustomDisplayParam(Param key) {
    return switch (key) {
      Param.cstmDispParam1 ||
      Param.cstmDispParam2 ||
      Param.cstmDispParam3 ||
      Param.cstmDispParam4 ||
      Param.cstmDispParam5 ||
      Param.cstmDispParam6 ||
      Param.cstmDispParam7 ||
      Param.cstmDispParam8 ||
      Param.cstmDispParam9 ||
      Param.cstmDispParam10 ||
      Param.cstmDispParam11 ||
      Param.cstmDispParam12 ||
      Param.cstmDispParam13 ||
      Param.cstmDispParam14 ||
      Param.cstmDispParam15 => true,
      _ => false,
    };
  }

  bool _isDateParam(Param key) {
    return switch (key) {
      Param.date ||
      Param.lastSaveDate ||
      Param.maxTempDate ||
      Param.minTempDate ||
      Param.maxPressDate ||
      Param.minPressDate ||
      Param.pressTxdrMalfDate ||
      Param.tempTxdrMalfDate ||
      Param.batteryMalfDate ||
      Param.memoryErrorDate ||
      Param.uncPeakFlowRateDate ||
      Param.batteryInstallDate ||
      Param.peakFlowRateResetDate => true,
      _ => false,
    };
  }

  bool _isTimeParam(Param key) {
    return switch (key) {
      Param.time ||
      Param.gasDayStartTime ||
      Param.lastSaveTime ||
      Param.maxTempTime ||
      Param.minTempTime ||
      Param.maxPressTime ||
      Param.minPressTime ||
      Param.pressTxdrMalfTime ||
      Param.tempTxdrMalfTime ||
      Param.batteryMalfTime ||
      Param.memoryErrorTime ||
      Param.uncPeakFlowRateTime ||
      Param.peakFlowRateResetTime => true,
      _ => false,
    };
  }

  bool _isHighResParam(Param key) {
    return switch (key) {
      Param.corHighResVol || Param.uncHighResVol => true,
      _ => false,
    };
  }

  bool _isFullVolParam(Param key) {
    return switch (key) {
      Param.corFullVol || Param.uncFullVol => true,
      _ => false,
    };
  }
}
