part of 'log.dart';

class FlowDpLog extends Log {
  final double? percentageOfMaxFlowRate;
  final String? diffPress;

  const FlowDpLog(
    super.logNumber,
    super.date,
    super.time,
    this.percentageOfMaxFlowRate,
    this.diffPress,
  );
}
