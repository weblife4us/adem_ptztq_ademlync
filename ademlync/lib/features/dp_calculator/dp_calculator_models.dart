import 'dp_calculator_const.dart';
import 'dp_calculator_enums.dart';

class DpCalculatorArgument {
  final DpCalculatorMeter meter;
  final double atmosphericPressPsia;
  final double lineGaugePress;
  final GasLineGaugePressureUnit lineGaugePressUnit;
  final double dpInWc;
  final double specificGravity;
  final double uncFlowRate;

  DpCalculatorArgument(
    this.meter,
    this.atmosphericPressPsia,
    this.lineGaugePress,
    this.lineGaugePressUnit,
    this.dpInWc,
    this.specificGravity,
    this.uncFlowRate,
  );

  double get linePressurePsia => switch (lineGaugePressUnit) {
    .psig => lineGaugePress,
    .inWc => lineGaugePress / psiInWc,
  };

  double get percentMaxFlow => (uncFlowRate / meter.maxFlowRate) * 100;
}

class DpCalculatorData {
  final double uncFlowRate;
  final double percentMaxFlow;

  DpCalculatorData(this.uncFlowRate, this.percentMaxFlow);
}

class DpCalculatorResult {
  final double maxAllowableDp;
  final bool isPassed;

  DpCalculatorResult(this.maxAllowableDp, this.isPassed);
}

class DpCalculatorStatus {
  final String badgeSerialNumber;
  final String rometSerialNumber;
  final String customerName;
  final String customerId;
  final String meterType;
  final String snPart2;
  final String installationSite;
  final String indexReading;
  final String testedBy;
  final String comment;

  const DpCalculatorStatus(
    this.badgeSerialNumber,
    this.rometSerialNumber,
    this.customerName,
    this.customerId,
    this.meterType,
    this.snPart2,
    this.installationSite,
    this.indexReading,
    this.testedBy,
    this.comment,
  );
}
