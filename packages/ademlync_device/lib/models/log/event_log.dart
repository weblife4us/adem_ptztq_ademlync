part of 'log.dart';

class EventLog extends Log {
  final int userId;
  final int? itemNumber;
  final String? itemName;
  final String oldValue;
  final String newValue;
  final String unit;
  final EventLogActionType logType;

  Param? get param => itemNumber != null ? Param.from(itemNumber!) : null;

  const EventLog(
    super.logNumber,
    super.date,
    super.time,
    this.userId,
    this.itemNumber,
    this.itemName,
    this.oldValue,
    this.newValue,
    this.unit,
    this.logType,
  );
}

enum EventLogActionType {
  itemChange(0),
  calibration(1),
  download(2),
  shutDown(3),
  aga8Download(4),
  slaveFirmwareUpdate(5),
  masterFirmwareUpdate(6),
  firmwareUpdate(7);

  final int key;

  const EventLogActionType(this.key);

  factory EventLogActionType.from(int key) =>
      EventLogActionType.values.firstWhere((e) => key == e.key);
}

enum EventLogType {
  download('000'),
  oldEventRecords('001'),
  read('002');

  final String key;

  const EventLogType(this.key);
}
