part of 'log.dart';

class AlarmLog extends Log {
  final int itemNumber;
  final String value;
  final String limit;
  final AlarmLogType type;

  Param? get param => Param.from(itemNumber);

  const AlarmLog(
    super.logNumber,
    super.date,
    super.time,
    this.itemNumber,
    this.value,
    this.limit,
    this.type,
  );
}

enum AlarmLogType {
  rise(0),
  acknowledge(1),
  clear(2);

  final int key;

  const AlarmLogType(this.key);

  factory AlarmLogType.from(int key) =>
      AlarmLogType.values.firstWhere((e) => key == e.key);
}
