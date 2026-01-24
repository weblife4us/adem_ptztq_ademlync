part of 'adem_param.dart';

extension ParamUnit on Param {
  String? unit(Adem adem) {
    switch (this) {
      case Param.batteryVoltage:
        return 'V';

      case Param.batteryRemaining:
      case Param.gasMoleCO2:
      case Param.gasMoleN2:
      case Param.gasMoleH2:
      case Param.minAllowFlowRate:
      case Param.aga8GasComponentMolar:
        return '%';

      case Param.gasMoleHs:
      case Param.gasMoleHsInEventLog:
        return switch (adem.meterSystem) {
          MeterSystem.imperial => 'BTU/CF',
          MeterSystem.metric => 'MJ/CM',
        };

      case Param.diffPress:
      case Param.dpSensorRange:
      case Param.diffUncertainty:
        return _mapDPressUnit(
          adem.differentialPressureUnit,
          adem,
          def: 'G',
          isH2o: true,
        );

      case Param.lineGaugePress:
        return adem.lineGaugePressureUnit?.displayName;

      case Param.atmosphericPress:
        return adem.type.isAdemTq
            ? _mapDPressUnit(adem.differentialPressureUnit, adem, def: 'A')
            : _mapPressUnit(adem.pressUnit, adem, def: 'A');

      case Param.basePress:
        return _mapPressUnit(adem.pressUnit, adem, def: 'A');

      case Param.dpTestPressure:
        return _mapDPressUnit(adem.differentialPressureUnit, adem, def: 'A');

      case Param.dpCalib1PtOffset:
      case Param.threePtDpCalibParams:
        return _mapDPressUnit(adem.differentialPressureUnit, adem);

      case Param.absPress:
        return adem.type.isAdemTq
            ? _mapDPressUnit(adem.differentialPressureUnit, adem, def: 'A')
            : _mapPressUnit(adem.pressUnit, adem, def: 'A');

      case Param.gaugePress:
        return adem.type.isAdemTq
            ? _mapDPressUnit(adem.differentialPressureUnit, adem, def: 'G')
            : _mapPressUnit(adem.pressUnit, adem, def: 'G');

      //Press
      case Param.pressHighLimit:
      case Param.pressLowLimit:
      case Param.pressTransRange:
      case Param.maxPress:
      case Param.minPress:
      case Param.isPressHigh:
      case Param.isPressLow:
        return adem.type.isAdemTq
            ? _mapDPressUnit(adem.differentialPressureUnit, adem)
            : _mapPressUnit(adem.pressUnit, adem);

      case Param.pressCalib1PtOffset:
      case Param.threePtPressCalibParams:
        return _mapPressUnit(adem.pressUnit, adem);

      case Param.tempHighLimit:
      case Param.tempLowLimit:
      case Param.tempCalib1PtOffset:
      case Param.temp:
      case Param.baseTemp:
      case Param.caseTemp:
      case Param.maxTemp:
      case Param.minTemp:
      case Param.maxCaseTemp:
      case Param.minCaseTemp:
      case Param.threePtTempCalibParams:
      case Param.qCutoffTempLow:
      case Param.qCutoffTempHigh:
      case Param.isTempHigh:
      case Param.isTempLow:
        return adem.tempUnit?.displayName;

      case Param.corHighResVol:
      case Param.corFullVol:
      case Param.uncHighResVol:
      case Param.uncFullVol:
      case Param.corDailyVol:
      case Param.corPrevDayVol:
      case Param.uncDailyVol:
      case Param.uncPrevDayVol:
      case Param.uncVolSinceMalf:
        return adem.volumeType.displayName;

      case Param.corVol:
      case Param.corLastSavedVol:
        return adem.measureCache.corVolUnit?.displayName;

      case Param.uncVol:
      case Param.provingVol:
      case Param.uncLastSavedVol:
        return adem.measureCache.uncVolUnit?.displayName;

      case Param.uncFlowRateHighLimit:
      case Param.uncFlowRateLowLimit:
      case Param.uncFlowRate:
      case Param.corFlowRate:
      case Param.uncPeakFlowRate:
      case Param.isUncFlowRateHigh:
      case Param.isUncFlowRateLow:
        return adem.flowRateType.displayName;

      // MARK: AdEM 25

      case Param.tmr1:
      case Param.tmr2:
        return null;

      case Param.overSpeed:
        return null;

      case Param.provingTimeout:
        return 'Sec';

      // MARK: Other

      default:
        return null;
    }
  }
}

String? _mapPressUnit(PressUnit? unit, Adem adem, {String? def}) {
  if (unit == null) return null;

  final c = def ?? (adem.isAbsPressTrans ? 'A' : 'G');
  return '${unit.displayName}$c';
}

String? _mapDPressUnit(
  DiffPressUnit? unit,
  Adem adem, {
  String? def,
  bool isH2o = false,
}) => switch (unit) {
  DiffPressUnit.inH2o when isH2o => DiffPressUnit.inH2o.displayName,
  DiffPressUnit.inH2o => _mapPressUnit(PressUnit.psi, adem, def: def),
  DiffPressUnit.kpa => _mapPressUnit(PressUnit.kpa, adem, def: def),
  null => null,
};
