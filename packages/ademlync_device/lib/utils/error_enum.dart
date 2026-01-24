import 'communication_enums.dart';

class AdemCommError implements Exception {
  final AdemCommErrorType type;
  final String? message;

  const AdemCommError(this.type, [this.message]);
}

enum AdemCommErrorType {
  communicationTimeout('AdEM Disconnected after 1 hour'),
  unsupportedAdemType('Unsupported AdEM Type'),
  unsupportedFirmware('Unsupported or Unknown Firmware'),
  checkProductType('Check product type for firmware E'),
  firmwareNotFound('AdEM Firmware Not Found'),
  productTypeNotFound('AdEM product type Not Found'),
  serialNumberNotFound('Serial Number Not Found'),
  receiveCrcError('Incorrect Received CRC'),
  receiveTimeout('No data or error data received'),
  ademSwitched('AdEM Switched'),
  formatError('PM01 - Format Error'),
  timeOutError('PM23 - Time Out Error'),
  frameError('PM22 - Frame Error'),
  crcError('PM23 - CRC Error'),
  incorrectInstrumentAccessCode('PM27 - Incorrect Instrument Access Code'),
  incorrectCommandCode('PM28 - Incorrect Command Code'),
  incorrectItemNumber('PM29 - Incorrect Item Number'),
  invalidEnquiry('PM30 - Invalid Enquiry'),
  tooManyAuditTrailRequests('PM31 - Too Many Audit Trail Requests'),
  readOnlyMode('PM32 - Read Only Mode'),
  eventLogLocked('PM34 - Event Log Locked'),
  dongleBatteryFail('Failed to fetch Battery'),
  connectionBroken('Check AdEM Key Connection'),
  trashBytes('Trash Bytes Detected'),
  calibrationNullParam('Calibration Error'),
  paramUpdateNotAllowed('Parameter update not allowed'),
  unknown('PM35 - Unknown');

  final String message;

  const AdemCommErrorType(this.message);
}

extension PMessageErrorType on PMessage {
  AdemCommErrorType? get ademCommunicationErrorType => switch (this) {
    PMessage.formatError => AdemCommErrorType.formatError,
    PMessage.timeOutError => AdemCommErrorType.timeOutError,
    PMessage.frameError => AdemCommErrorType.frameError,
    PMessage.crcError => AdemCommErrorType.crcError,
    PMessage.incorrectInstrumentAccessCode =>
      AdemCommErrorType.incorrectInstrumentAccessCode,
    PMessage.incorrectCommandCode => AdemCommErrorType.incorrectCommandCode,
    PMessage.incorrectItemNumber => AdemCommErrorType.incorrectItemNumber,
    PMessage.invalidEnquiry => AdemCommErrorType.invalidEnquiry,
    PMessage.tooManyAuditTrailRequests =>
      AdemCommErrorType.tooManyAuditTrailRequests,
    PMessage.readOnlyMode => AdemCommErrorType.readOnlyMode,
    PMessage.eventLogLocked => AdemCommErrorType.eventLogLocked,
    PMessage.agaConfigRefuse => AdemCommErrorType.paramUpdateNotAllowed,
    PMessage.unknown => AdemCommErrorType.unknown,
    _ => null,
  };
}
