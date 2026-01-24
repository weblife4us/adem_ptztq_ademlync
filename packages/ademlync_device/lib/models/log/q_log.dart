part of 'log.dart';

class QLog extends Log {
  final num? flowRate;
  final double? qMarginPercent;
  final num? qMargin;
  final num? maxQMargin;

  QStatus get qStatus {
    if (qMargin == null) {
      return QStatus.noData;
    } else if (qMargin! <= 0) {
      return QStatus.check;
    } else {
      return QStatus.pass;
    }
  }

  const QLog(
    super.logNumber,
    super.date,
    super.time,
    this.flowRate,
    this.qMarginPercent,
    this.qMargin,
    this.maxQMargin,
  );
}

enum QStatus { noData, check, pass }
