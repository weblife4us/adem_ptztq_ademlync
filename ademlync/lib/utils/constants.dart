import 'package:ademlync_device/ademlync_device.dart';

import 'enums.dart';

const credentialKey = 'credential';
const uploadedFileKey = 'uploadedLogFilePaths';

const aga8DetailFoldername = 'Report-AGA8';
const alarmsFoldername = 'Report-Alarm';
const checkReportFoldername = 'Report-Check';
const setupReportFoldername = 'Report-Setup';
const configurationFoldername = 'Configuration';
const dpCalculatorReportFoldername = 'Dp Calculator Report';

const mainTimerDuration = Duration(seconds: 15);

const noDataString = 'N/A';
const noConfigFoundString =
    'No configuration file was found\nPlease export one to device storage';
const noLogFoundString =
    'No log file was found\nPlease export one to device storage';

// Appearance
const sysAppearanceKey = 'sysAppearance';
const sysTextScaleKey = 'sysTextScale';
const isDarkKey = 'isDark';
const textScaleKey = 'textScale';
const exportFmtKey = 'exportFmt';
const timeFmtKey = 'timeFmt';

// Maximum length
const int minUsernameLength = 4;
const int maxUsernameLength = 20;
const int minPasswordLength = 8;
const int maxPasswordLength = 20;
const int maxTotpLength = 6;
const int normalCharLength = 8;
const int snLength = 8;

// Timeout
const int btConnTimeoutInSec = 7200;

// Decimal
const factorDecimal = 4;
const percentDecimal = 2;
const logNumberDigital = 5;
const itemNumberDigital = 3;

// Duration
const fiveSec = Duration(seconds: 5);

// Text scale
const maxTextScale = 1.35;
const minTextScale = 0.75;

// MARK: DateTime

final defaultLogStartDate = DateTime(2000, 1, 1);
final defaultLogRange = LogTimeRange(defaultLogStartDate, DateTime.now());

const setupReportParams = {
  Param.firmwareVersion,
  Param.meterSize,
  Param.serialNumber,
  Param.serialNumberPart2,
  Param.date,
  Param.dateFormat,
  Param.time,
  Param.batteryType,
  Param.batteryInstallDate,
  Param.batteryVoltage,
  Param.dispVolSelect,
  Param.gasDayStartTime,
  Param.corFullVol,
  Param.corVol,
  Param.corVolUnit,
  Param.corOutputPulseVolUnit,
  Param.corVolDigits,
  Param.uncFullVol,
  Param.provingVol,
  Param.uncVol,
  Param.uncVolUnit,
  Param.uncOutputPulseVolUnit,
  Param.uncVolDigits,
  Param.outPulseSpacing,
  Param.outPulseWidth,
  Param.pressTransType,
  Param.pressTransSn,
  Param.pressTransRange,
  Param.pressFactorType,
  Param.pressUnit,
  Param.gaugePress,
  Param.absPress,
  Param.pressHighLimit,
  Param.pressLowLimit,
  Param.pressFactor,
  Param.temp,
  Param.tempHighLimit,
  Param.tempLowLimit,
  Param.tempFactorType,
  Param.uncFlowRateHighLimit,
  Param.uncFlowRateLowLimit,
  Param.superXFactorType,
  Param.superXAlgo,
  Param.liveSuperXFactor,
  Param.fixedSuperXFactor,
  Param.gasSpecificGravity,
  Param.gasMoleN2,
  Param.gasMoleCO2,
  Param.gasMoleH2,
  Param.gasMoleHs,
  Param.baseTemp,
  Param.basePress,
  Param.atmosphericPress,
  Param.uncPeakFlowRate,
  Param.uncPeakFlowRateDate,
  Param.uncPeakFlowRateTime,
  Param.maxPress,
  Param.maxPressDate,
  Param.maxPressTime,
  Param.minPress,
  Param.minPressDate,
  Param.minPressTime,
  Param.maxTemp,
  Param.maxTempDate,
  Param.maxTempTime,
  Param.minTemp,
  Param.minTempDate,
  Param.minTempTime,
  Param.maxCaseTemp,
  Param.minCaseTemp,
  Param.backupIndexCounter,
  Param.outputPulseChannel1,
  Param.outputPulseChannel2,
  Param.outputPulseChannel3,
  Param.intervalLogInterval,
  Param.intervalLogType,
  Param.intervalField5,
  Param.intervalField6,
  Param.intervalField7,
  Param.intervalField8,
  Param.intervalField9,
  Param.intervalField10,
  Param.cstmDispParam1,
  Param.cstmDispParam2,
  Param.cstmDispParam3,
  Param.cstmDispParam4,
  Param.cstmDispParam5,
  Param.cstmDispParam6,
  Param.cstmDispParam7,
  Param.cstmDispParam8,
  Param.cstmDispParam9,
  Param.cstmDispParam10,
  Param.cstmDispParam11,
  Param.cstmDispParam12,
  Param.cstmDispParam13,
  Param.cstmDispParam14,
  Param.cstmDispParam15,
};

const checkReportParams = {
  Param.firmwareVersion,
  Param.meterSize,
  Param.serialNumber,
  Param.serialNumberPart2,
  Param.date,
  Param.dateFormat,
  Param.time,
  Param.batteryType,
  Param.batteryVoltage,
  Param.batteryRemaining,
  Param.corHighResVol,
  Param.corFullVol,
  Param.corVol,
  Param.corFlowRate,
  Param.uncHighResVol,
  Param.uncFullVol,
  Param.provingVol,
  Param.uncVol,
  Param.uncFlowRate,
  Param.uncVolSinceMalf,
  Param.gasDayStartTime,
  Param.corDailyVol,
  Param.uncDailyVol,
  Param.corPrevDayVol,
  Param.uncPrevDayVol,
  Param.lastSaveDate,
  Param.lastSaveTime,
  Param.corLastSavedVol,
  Param.uncLastSavedVol,
  Param.temp,
  Param.tempFactor,
  Param.tempFactorType,
  Param.maxTemp,
  Param.maxTempDate,
  Param.maxTempTime,
  Param.minTemp,
  Param.minTempDate,
  Param.minTempTime,
  Param.caseTemp,
  Param.maxCaseTemp,
  Param.minCaseTemp,
  Param.baseTemp,
  Param.basePress,
  Param.atmosphericPress,
  Param.gaugePress,
  Param.absPress,
  Param.pressFactor,
  Param.pressFactorType,
  Param.maxPress,
  Param.maxPressDate,
  Param.maxPressTime,
  Param.minPress,
  Param.minPressDate,
  Param.minPressTime,
  Param.superXFactorType,
  Param.superXAlgo,
  Param.fixedSuperXFactor,
  Param.liveSuperXFactor,
  Param.gasSpecificGravity,
  Param.gasMoleN2,
  Param.gasMoleCO2,
  Param.gasMoleH2,
  Param.gasMoleHs,
  Param.totalFactor,
  Param.isPressHigh,
  Param.isPressLow,
  Param.isPressTxdrMalf,
  Param.pressTxdrMalfDate,
  Param.pressTxdrMalfTime,
  Param.isTempHigh,
  Param.isTempLow,
  Param.isTempTxdrMalf,
  Param.tempTxdrMalfDate,
  Param.tempTxdrMalfTime,
  Param.isBatteryMalf,
  Param.batteryMalfDate,
  Param.batteryMalfTime,
  Param.isMemoryError,
  Param.memoryErrorDate,
  Param.memoryErrorTime,
  Param.backupIndexCounter,
  Param.uncPeakFlowRate,
  Param.uncPeakFlowRateDate,
  Param.uncPeakFlowRateTime,
  Param.intervalLogInterval,
  Param.intervalLogType,
  Param.intervalField5,
  Param.intervalField6,
  Param.intervalField7,
  Param.intervalField8,
  Param.intervalField9,
  Param.intervalField10,
  Param.cstmDispParam1,
  Param.cstmDispParam2,
  Param.cstmDispParam3,
  Param.cstmDispParam4,
  Param.cstmDispParam5,
  Param.cstmDispParam6,
  Param.cstmDispParam7,
  Param.cstmDispParam8,
  Param.cstmDispParam9,
  Param.cstmDispParam10,
  Param.cstmDispParam11,
  Param.cstmDispParam12,
  Param.cstmDispParam13,
  Param.cstmDispParam14,
  Param.cstmDispParam15,
  Param.aga8GasComponentMolar,
};

Set<Param> excludedAdemConfigParams(Adem adem) => {
  if (adem.isAdem25) Param.productType,
  Param.firmwareVersion,
  Param.pressFactorType,
};

Set<Param> ademConfigParams(Adem adem) => {
  if (adem.isAdem25) Param.productType,
  Param.firmwareVersion,
  adem.isMeterSizeSupported ? Param.meterSize : Param.inputPulseVolUnit,
  Param.corOutputPulseVolUnit,
  Param.uncOutputPulseVolUnit,
  Param.dispVolSelect,
  Param.gasDayStartTime,
  Param.corVolUnit,
  Param.corVolDigits,
  Param.corVol,
  Param.uncVolUnit,
  Param.uncVolDigits,
  Param.uncVol,
  Param.outPulseSpacing,
  Param.outPulseWidth,
  Param.pressTransType,
  Param.pressFactorType,
  Param.tempHighLimit,
  Param.tempLowLimit,
  Param.tempFactorType,
  Param.uncFlowRateHighLimit,
  Param.uncFlowRateLowLimit,
  Param.superXFactorType,
  Param.superXAlgo,
  Param.baseTemp,
  Param.basePress,
  Param.atmosphericPress,
  Param.outputPulseChannel3,
  Param.intervalLogInterval,
  Param.intervalLogType,
  Param.cstmDispParam1,
  Param.cstmDispParam2,
  Param.cstmDispParam3,
  Param.cstmDispParam4,
  Param.cstmDispParam5,
  Param.cstmDispParam6,
  Param.cstmDispParam7,
  Param.cstmDispParam8,
  Param.cstmDispParam9,
  Param.cstmDispParam10,
  Param.cstmDispParam11,
  Param.cstmDispParam12,
  Param.cstmDispParam13,
  Param.cstmDispParam14,
  Param.cstmDispParam15,
};
