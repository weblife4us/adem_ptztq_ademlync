import '../../utils/adem_param.dart';

part 'alarm_log.dart';
part 'daily_log.dart';
part 'event_log.dart';
part 'flow_dp_log.dart';
part 'interval_log.dart';
part 'q_log.dart';

abstract class Log {
  final int logNumber;
  final DateTime? date;
  final DateTime? time;

  const Log(this.logNumber, this.date, this.time);
}
