import '../models/adem/adem.dart';
import '../models/log/log.dart';
import 'error_enum.dart';
import 'functions.dart';

part 'adem_param_decimal.dart';
part 'adem_param_display_name.dart';
part 'adem_param_enums.dart';
part 'adem_param_limit.dart';
part 'adem_param_unit.dart';

enum Param {
  serialNumber(062),
  serialNumberPart2(201),
  firmwareVersion(122),
  firmwareChecksum(986),
  date(204),
  time(203),
  gasDayStartTime(205),
  dateFormat(262),
  meterSize(768),
  lastSaveTime(776),
  lastSaveDate(777),
  // NOTE: 117 is deprecated
  backupIndexCounter(834),
  displayTestPattern(61),
  isEventLogEnable(123),

  // MARK: Battery

  batteryVoltage(48),
  batteryLife(769),
  batteryRemaining(59),
  batteryInstallDate(772),

  // MARK: Corrected volume

  totalFactor(43),
  corVol(0),
  corFullVol(808),
  corDailyVol(223),
  corPrevDayVol(183),
  corLastSavedVol(775),
  corHighResVol(113),

  // MARK: Uncorrected volume

  uncFullVol(807),
  uncVol(2),
  uncDailyVol(224),
  uncPrevDayVol(184),
  uncLastSavedVol(774),
  uncHighResVol(767),
  uncVolSinceMalf(773),

  // MARK: Temperature

  tempFactor(45),
  temp(26),
  tempHighLimit(28),
  tempLowLimit(27),
  maxTemp(64),
  maxTempDate(295),
  maxTempTime(294),
  minTemp(65),
  minTempDate(299),
  minTempTime(298),
  caseTemp(31),
  maxCaseTemp(32),
  minCaseTemp(33),
  baseTemp(34),

  // MARK: Pressure

  pressFactor(44),
  pressHighLimit(10),
  pressLowLimit(11),
  maxPress(9),
  maxPressDate(287),
  maxPressTime(286),
  minPress(63),
  minPressDate(291),
  minPressTime(290),
  pressTransSn(138),
  pressTransRange(137),
  absPress(8),
  gaugePress(811),
  lineGaugePress(855),
  atmosphericPress(14),
  basePress(13),

  // MARK: Output pulse

  outPulseSpacing(115),
  // NOTE: 836 is deprecated
  outPulseWidth(840),

  // MARK:  Flowrate

  corFlowRate(828),
  // NOTE: 56 is deprecated
  uncFlowRate(209),
  uncFlowRateHighLimit(164),
  uncFlowRateLowLimit(809),
  // NOTE: 209 is deprecated
  uncPeakFlowRate(198),
  uncPeakFlowRateDate(275),
  uncPeakFlowRateTime(274),
  peakFlowRateResetDate(786),
  peakFlowRateResetTime(785),
  minAllowFlowRate(857),

  // MARK:  Super X

  fixedSuperXFactor(47),
  liveSuperXFactor(116),
  gasMoleCO2(55),
  gasMoleH2(821),
  gasMoleN2(54),
  gasMoleHs(778),
  gasMoleHsInEventLog(142),
  aga8GasComponentMolar(827),
  gasSpecificGravity(53), // 000.0000 no AGA8

  // MARK: Malfunction

  isTempHigh(146),
  isTempLow(144),
  isPressHigh(145),
  isPressLow(143),
  isUncFlowRateHigh(163),
  isUncFlowRateLow(810),
  isAlarmOutput(108),
  isPressTxdrMalf(105),
  isTempTxdrMalf(106),
  isDpTxdrMalf(861),
  isBatteryMalf(99),
  isMemoryError(824),
  pressTxdrMalfDate(782),
  pressTxdrMalfTime(781),
  tempTxdrMalfDate(784),
  tempTxdrMalfTime(783),
  dpTxdrMalfDate(863),
  dpTxdrMalfTime(862),
  batteryMalfDate(780),
  batteryMalfTime(779),
  memoryErrorDate(825),
  memoryErrorTime(826),

  // MARK: Diff pressure

  maxAllowableDp(856),
  diffPress(858),
  qMonitorFunction(860),
  dpSensorSn(854),
  dpSensorRange(853),
  dpTestPressure(869),
  qCutoffTempLow(870),
  qCutoffTempHigh(871),
  qCoefficientA(864),
  qCoefficientC(865),
  diffUncertainty(867),
  qSafetyMultiplier(868),

  // MARK: Conversion

  uncOutputPulseVolUnit(816),
  // NOTE: 57 is deprecated
  corOutputPulseVolUnit(817),
  inputPulseVolUnit(98),
  pressFactorType(109),
  tempFactorType(111),
  superXFactorType(110),
  pressTransType(112),
  pressUnit(87),
  tempUnit(89),
  uncVolUnit(92),
  corVolUnit(90),
  differentialPressureUnit(980),
  lineGaugePressureUnit(981),
  uncVolDigits(97),
  corVolDigits(96),
  dispVolSelect(770),
  superXAlgo(147),
  intervalLogType(822),
  intervalLogInterval(202),
  batteryType(771),
  sealStatus(818),

  /// #987 - Push button proving and pulses output functions
  pushBtnProvingPulsesOpFunc(987),
  showDot(878),

  // MARK: Calibration

  dpADReadingCts(794),
  pressADReadCounts(793),
  tempADReadCounts(794),
  dpCalib1PtOffset(845),
  pressCalib1PtOffset(845),
  tempCalib1PtOffset(792),
  onePtTempTarget(823),
  threePtDpCalibParams(790),
  threePtPressCalibParams(790),
  threePtTempCalibParams(791),

  // MARK: Custom display

  cstmDispParam1(75),
  cstmDispParam2(76),
  cstmDispParam3(77),
  cstmDispParam4(78),
  cstmDispParam5(79),
  cstmDispParam6(80),
  cstmDispParam7(81),
  cstmDispParam8(82),
  cstmDispParam9(83),
  cstmDispParam10(84),
  cstmDispParam11(85),
  cstmDispParam12(86),
  cstmDispParam13(787),
  cstmDispParam14(788),
  cstmDispParam15(789),
  intervalField5(229),
  intervalField6(230),
  intervalField7(231),
  intervalField8(232),
  intervalField9(233),
  intervalField10(234),
  outputPulseChannel1(93),
  outputPulseChannel2(94),
  outputPulseChannel3(95),
  pressDispRes(88),

  // MARK: Pressure compensation

  pressureCompensationFactor1(301),
  pressureCompensationFactor2(302),
  pressureCompensationFactor3(303),
  pressureCompensationFactor4(304),
  pressureCompensationFactor5(305),
  pressureCompensationFactor6(306),
  pressureCompensationFactor7(307),
  pressureCompensationFactor8(308),
  pressureCompensationFactor9(309),
  pressureCompensationFactor10(310),
  pressureCompensationFactor11(311),
  pressureCompensationFactor12(312),

  // MARK: AdEM 25

  /// #127 - TMR1
  tmr1(127),

  /// #128 - TMR2
  tmr2(128),

  // #165 - Over speed
  overSpeed(165),
  customerId(873),

  // #875 - Proving time-out
  provingTimeout(875),

  // #874 - Product type
  productType(874),

  // NOTE: Both #831 and #879 are pointing to the same param

  /// #831 - Legacy Uncorrected Index Rollover
  legacyUncorrectedIndexRollover(831),

  /// #879 - Uncorrected Index Rollover
  uncorrectedIndexRollover(879),

  // NOTE: Both #832 and #880 are pointing to the same param

  /// #832 - Legacy Corrected Index Rollover
  legacyCorrectedIndexRollover(832),

  /// #880 - Corrected Index Rollover
  correctedIndexRollover(880),

  // MARK: Alarm Log

  /// #130 - Is uncorrected Index Rolled Over
  isUncIndexRolledOver(130),

  /// #131 - Is corrected Index Rolled Over
  isCorIndexRolledOver(131),

  // MARK: Other

  pushbuttonProvingMode(400),
  pushbuttonOutputPulses(401),
  displacement(806), // 0.00000000 ft3 need zero
  provingVol(995), // 00000000 ft3
  eventLogger(196),
  unknown(255);

  final int key;

  const Param(this.key);

  factory Param.from(int key) =>
      Param.values.firstWhere((e) => e.key == key, orElse: () => Param.unknown);
}
