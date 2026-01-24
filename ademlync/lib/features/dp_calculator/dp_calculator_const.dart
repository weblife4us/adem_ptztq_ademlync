import 'package:ademlync_device/utils/adem_param.dart';

const resultPassedString = 'PASS - ΔP is within limit.';
const resultFailedString = 'Fail - ΔP is out of limit.';
const reportPassedString = 'PASS - Differential is within limit.';
const reportFailedString = 'Fail - Differential is out of limit.';

const psiInWc = 27.7072583644238;
const dpUncertainty = 0.05;
const dpAllowableFactor = 1.5;

const dpCalculatorAtmosphericPressPsiaLimit = AdemParamLimit(5.00, 16.00);
const dpCalculatorLineGaugePressPsigLimit = AdemParamLimit(0.00, 200.00);
const dpCalculatorLineGaugePressInWcLimit = AdemParamLimit(0.000, 5535.000);
const dpCalculatorSpecificGravityLimit = AdemParamLimit(0.050, 5.000);
const dpCalculatorDpInWcLimit = AdemParamLimit(0.000, 5535.000);
const dpCalculatorMinPercentMaxFlow = 10;

const dpCalculatorAtmosphericPressPsiaDecimal = 2;
const dpCalculatorLineGaugePressPsigDecimal = 2;
const dpCalculatorLineGaugePressInWcDecimal = 3;
const dpCalculatorDpInWcDecimal = 3;
const dpCalculatorSpecificGravityDecimal = 3;
const dpCalculatorUncFlowRateDecimal = 2;
const dpCalculatorPercentMaxFlowDecimal = 2;
const dpCalculatorMaxAllowableDpDecimal = 3;
