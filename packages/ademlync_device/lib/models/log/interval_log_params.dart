class IntervalLogParams {
  final bool hasAvgPress;
  final bool hasAvgTemp;
  final bool hasTotalCorVol;
  final bool hasTotalUncVol;
  final bool hasMaxPress;
  final bool hasMaxPressTime;
  final bool hasMinPress;
  final bool hasMinPressTime;
  final bool hasMaxTemp;
  final bool hasMaxTempTime;
  final bool hasMinTemp;
  final bool hasMinTempTime;
  final bool hasMaxUncFlowrate;
  final bool hasMaxUncFlowrateTime;
  final bool hasMinUncFlowrate;
  final bool hasMinUncFlowrateTime;
  final IntervalLogAlarmParams alarms;

  const IntervalLogParams(
    this.hasAvgPress,
    this.hasAvgTemp,
    this.hasTotalCorVol,
    this.hasTotalUncVol,
    this.hasMaxPress,
    this.hasMaxPressTime,
    this.hasMinPress,
    this.hasMinPressTime,
    this.hasMaxTemp,
    this.hasMaxTempTime,
    this.hasMinTemp,
    this.hasMinTempTime,
    this.hasMaxUncFlowrate,
    this.hasMaxUncFlowrateTime,
    this.hasMinUncFlowrate,
    this.hasMinUncFlowrateTime,
    this.alarms,
  );
}

class IntervalLogAlarmParams {
  final bool hasTmr1;
  final bool hasTmr2;
  final bool hasPressHigh;
  final bool hasPressLow;
  final bool hasPressMalf;
  final bool hasTempHigh;
  final bool hasTempLow;
  final bool hasTempMalf;

  const IntervalLogAlarmParams(
    this.hasTmr1,
    this.hasTmr2,
    this.hasPressHigh,
    this.hasPressLow,
    this.hasPressMalf,
    this.hasTempHigh,
    this.hasTempLow,
    this.hasTempMalf,
  );
}
