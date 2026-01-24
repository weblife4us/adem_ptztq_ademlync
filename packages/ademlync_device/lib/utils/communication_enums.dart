import 'dart:convert';

import 'functions.dart';

enum Protocol {
  read('RD'),
  write('WD'),
  readLocation('RS'),
  readCustomerId('RI'),
  writeLocation('WS'),
  writeCustomerId('WI'),
  dailyLog('RM'),
  eventLog('RE'),
  eventLogAdem25('EE'),
  intervalLog('DD'),
  readAlarmLogger('RL'),
  readAlarmLoggerAdem25('LL'),
  alarmLog('T'),
  qLog('RQ'),
  flowDpLog('RF'),
  changeAccessCode('CA'),
  changeSuperAccess('CC'),
  provingMode('PR'),
  firmwareUpdate('WM'),
  disconnectLink('SF'),
  shutDown('ES'),
  cleanMemory('CM'),
  readEEPROM('ER'),
  writeEEPROM('EW');

  final String key;

  const Protocol(this.key);
}

enum PMessage {
  acknowledge('00'),
  formatError('01'),
  signOn('20'),
  timeOutError('21'),
  frameError('22'),
  crcError('23'),
  incorrectInstrumentAccessCode('27'),
  incorrectCommandCode('28'),
  incorrectItemNumber('29'),
  invalidEnquiry('30'),
  tooManyAuditTrailRequests('31'),
  readOnlyMode('32'),
  noIntervalLog('33'),
  eventLogLocked('34'),
  noEventLog('36'),
  noAlarmOrDailyLog('37'),
  noQRLog('38'),
  noDpLog('39'),

  /// AdEM refuses AGA detailed parameters update when low battery.
  agaConfigRefuse('41'),
  unknown('35'); // Note: It may means no alarm log in future.

  final String key;

  const PMessage(this.key);
}

PMessage? getPMessage(String key) {
  return PMessage.values.firstWhereOrNull((e) => e.key == key);
}

enum ControlChar {
  soh(0x01),
  stx(0x02),
  etx(0x03),
  eot(0x04),
  enq(0x05),
  ack(0x06),
  rs(0x1E);

  final int byte;

  const ControlChar(this.byte);

  factory ControlChar.from(int byte) => ControlChar.values.firstWhere(
    (e) => e.byte == byte,
    orElse: () => throw Exception('ControlCharacter not found.'),
  );

  @override
  String toString() => utf8.decode([byte]);
}
