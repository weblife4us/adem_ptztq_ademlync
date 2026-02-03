part of 'adem_param.dart';

extension ParamDecimal on Param {
  int decimal(Adem adem) {
    final dpUnit = adem.differentialPressureUnit;
    final pressUnit = adem.pressUnit;
    final lineGaugePressUnit = adem.lineGaugePressureUnit;
    final tempUnit = adem.tempUnit;
    final volumeType = adem.volumeType;
    final flowRateType = adem.flowRateType;
    final isTq = adem.type == AdemType.ademTq || adem.type == AdemType.ademPtzq;

    return switch (this) {
          // MARK: Battery
          Param.batteryVoltage => 2,
          Param.batteryRemaining => 2,

          // MARK: DP
          Param.diffPress => 3,
          Param.qCoefficientA => 4,
          Param.qCoefficientC => 4,
          Param.qCutoffTempLow => tempUnit?.decimal,
          Param.qCutoffTempHigh => tempUnit?.decimal,
          Param.dpSensorSn => 0,
          Param.dpSensorRange => dpUnit?.decimal,
          Param.diffUncertainty => 3,
          Param.qSafetyMultiplier => 2,
          Param.dpTestPressure => 3,

          // MARK: Press
          Param.pressFactor => 4,
          Param.maxPress => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.minPress => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.pressHighLimit => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.pressLowLimit => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.pressTransRange => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.basePress =>
            adem.pressUnit?.decimal != null
                ? adem.pressUnit!.decimal +
                      (adem.pressUnit == PressUnit.psi ? 0 : 2)
                : null,
          Param.absPress => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.gaugePress => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.lineGaugePress =>
            isTq
                ? lineGaugePressUnit == LineGaugePressUnit.psig
                      ? 2
                      : 3
                : pressUnit?.decimal,
          Param.atmosphericPress =>
            isTq ? dpUnit?.toPressUnit.decimal : pressUnit?.decimal,
          Param.isPressHigh => isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.isPressLow => isTq ? dpUnit?.decimal : pressUnit?.decimal,

          // MARK: Temp
          Param.tempFactor => 4,
          Param.temp => tempUnit?.decimal,
          Param.maxTemp => tempUnit?.decimal,
          Param.minTemp => tempUnit?.decimal,
          Param.tempHighLimit => tempUnit?.decimal,
          Param.tempLowLimit => tempUnit?.decimal,
          Param.caseTemp => tempUnit?.decimal,
          Param.maxCaseTemp => tempUnit?.decimal,
          Param.minCaseTemp => tempUnit?.decimal,
          Param.baseTemp => tempUnit?.decimal,
          Param.isTempHigh => tempUnit?.decimal,
          Param.isTempLow => tempUnit?.decimal,

          // MARK: Volume
          Param.totalFactor => 4,
          Param.corFullVol => volumeType.decimal,
          Param.uncFullVol => volumeType.decimal,
          Param.corVol => 0,
          Param.uncVol => 0,
          Param.corHighResVol => volumeType.decimal + 2,
          Param.uncHighResVol => volumeType.decimal + 2,
          Param.corLastSavedVol => 0,
          Param.uncLastSavedVol => 0,
          Param.corDailyVol => 0,
          Param.uncDailyVol => 0,
          Param.corPrevDayVol => 0,
          Param.uncPrevDayVol => 0,
          Param.uncVolSinceMalf => 0,
          Param.provingVol => 0,

          // MARK: Flow rate
          Param.corFlowRate => flowRateType.decimal,
          Param.uncFlowRate => flowRateType.decimal,
          Param.uncFlowRateHighLimit => flowRateType.decimal,
          Param.uncFlowRateLowLimit => flowRateType.decimal,
          Param.uncPeakFlowRate => flowRateType.decimal,
          Param.minAllowFlowRate => 0,
          Param.isUncFlowRateHigh => flowRateType.decimal,
          Param.isUncFlowRateLow => flowRateType.decimal,

          // MARK: SuperX

          // NOTE:
          // Firmware versions C05XM004, C05XM204, C05XM304, C07XM004:
          // - Gravity (Item #53): Set to 3 decimal places from 4.
          // - N2 (Item #54): Set to 2 decimal places from 3.
          // - CO2 (Item #55): Set to 2 decimal places from 3.
          // - H2 (Item #821): Set to 2 decimal places from 3.
          Param.liveSuperXFactor => 4,
          Param.fixedSuperXFactor => 4,
          Param.aga8GasComponentMolar => 2,
          Param.gasSpecificGravity when _isSpecialMolar(adem) => 3,
          Param.gasMoleCO2 when _isSpecialMolar(adem) => 2,
          Param.gasMoleN2 when _isSpecialMolar(adem) => 2,
          Param.gasMoleH2 when _isSpecialMolar(adem) => 2,
          Param.gasSpecificGravity => 4,
          Param.gasMoleCO2 => 3,
          Param.gasMoleN2 => 3,
          Param.gasMoleH2 => 3,
          Param.gasMoleHs => 0,
          Param.gasMoleHsInEventLog => 2,

          // MARK: Calibration
          Param.dpCalib1PtOffset => 3,
          Param.pressCalib1PtOffset =>
            isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.tempCalib1PtOffset => tempUnit?.decimal,
          Param.threePtDpCalibParams => 3,
          Param.threePtPressCalibParams =>
            isTq ? dpUnit?.decimal : pressUnit?.decimal,
          Param.threePtTempCalibParams => tempUnit?.decimal,
          Param.displacement => 8,

          // MARK: AdEM 25
          Param.tmr1 || Param.tmr2 => 0,
          Param.overSpeed => 0,

          // MARK: Other
          _ => null,
        } ??
        0;
  }
}

bool _isSpecialMolar(Adem adem) =>
    adem.type.isAdemPtz && adem.firmwareVersion[0] == 'C';
