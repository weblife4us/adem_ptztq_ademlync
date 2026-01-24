part of 'adem_param.dart';

extension ParamLimits on Param {
  AdemParamLimit? limit(Adem adem, {SuperXAlgo? algo}) {
    final superXAlgorithm = algo ?? adem.measureCache.superXAlgorithm;
    final maxFlowrate = adem.maxFlowRate;

    switch (this) {
      // Factor
      case Param.pressFactor:
        return const AdemParamLimit(1.0000, 19.9999);
      case Param.tempFactor:
        return const AdemParamLimit(0.5000, 1.5000);
      case Param.liveSuperXFactor:
      case Param.fixedSuperXFactor:
        return const AdemParamLimit(0.8000, 2.0000);

      // Dp
      case Param.diffPress:
        return switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => const AdemParamLimit(0.000, 24.000),
          DiffPressUnit.kpa => const AdemParamLimit(0.0, 6.0),
        };

      case Param.dpSensorRange:
        return switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => const AdemParamLimit(3.000, 24.000),
          DiffPressUnit.kpa => const AdemParamLimit(0.7, 6.0),
        };

      case Param.lineGaugePress:
        return switch (adem.lineGaugePressureUnit!) {
          LineGaugePressUnit.psig => const AdemParamLimit(0.00, 50.00),
          LineGaugePressUnit.kpag => const AdemParamLimit(0.0, 345.0),
        };

      case Param.atmosphericPress:
        return adem.type == AdemType.ademTq
            ? switch (adem.differentialPressureUnit!) {
                DiffPressUnit.inH2o => const AdemParamLimit(10.00, 16.00),
                DiffPressUnit.kpa => const AdemParamLimit(70.0, 110.0),
              }
            : switch (adem.pressUnit!) {
                PressUnit.psi => const AdemParamLimit(10.00, 16.00),
                PressUnit.kpa => const AdemParamLimit(70.0, 110.0),
                PressUnit.bar => const AdemParamLimit(0.700, 1.100),
              };

      case Param.qCutoffTempLow:
        return switch (adem.tempUnit!) {
          TempUnit.f => const AdemParamLimit(-40.0, 68.0),
          TempUnit.c => const AdemParamLimit(-40.0, 20.0),
        };

      case Param.qCutoffTempHigh:
        return switch (adem.tempUnit!) {
          TempUnit.f => const AdemParamLimit(86.0, 176.0),
          TempUnit.c => const AdemParamLimit(30.0, 80.0),
        };

      case Param.diffUncertainty:
        return switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => const AdemParamLimit(0.050, 0.120),
          DiffPressUnit.kpa => const AdemParamLimit(0.000, 0.040),
        };

      // Press
      case Param.absPress:
      case Param.gaugePress:
      case Param.pressHighLimit:
      case Param.pressLowLimit:
        if (adem.type == AdemType.ademTq) {
          return switch (adem.differentialPressureUnit!) {
            DiffPressUnit.inH2o => const AdemParamLimit(0.00, 2030.53),
            DiffPressUnit.kpa => const AdemParamLimit(0.0, 14000.0),
          };
        } else {
          switch (adem.pressUnit) {
            case PressUnit.psi:
              return const AdemParamLimit(0.00, 2030.53);
            case PressUnit.kpa:
              return const AdemParamLimit(0.0, 14000.0);
            case PressUnit.bar:
              return const AdemParamLimit(0.000, 140.000);
            default:
              return null;
          }
        }

      case Param.basePress:
        switch (adem.pressUnit!) {
          case PressUnit.psi:
            return const AdemParamLimit(10.00, 16.00);
          case PressUnit.kpa:
            return const AdemParamLimit(70.0, 110.0);
          case PressUnit.bar:
            return const AdemParamLimit(0.700, 1.100);
        }

      case Param.pressTransRange:
        if (adem.type == AdemType.ademTq) {
          return switch (adem.differentialPressureUnit!) {
            DiffPressUnit.inH2o => const AdemParamLimit(4.35, 2030.53),
            DiffPressUnit.kpa => const AdemParamLimit(30.0, 14000.0),
          };
        } else {
          switch (adem.pressUnit!) {
            case PressUnit.psi:
              return const AdemParamLimit(4.35, 2030.53);
            case PressUnit.kpa:
              return const AdemParamLimit(30.0, 14000.0);
            case PressUnit.bar:
              return const AdemParamLimit(0.300, 140.000);
          }
        }

      // Temp
      case Param.tempHighLimit:
        switch (adem.tempUnit!) {
          case TempUnit.f:
            return const AdemParamLimit(68.0, 161.6);
          case TempUnit.c:
            return const AdemParamLimit(20.0, 72.0);
        }
      case Param.tempLowLimit:
        switch (adem.tempUnit!) {
          case TempUnit.f:
            return const AdemParamLimit(-40.0, 50.0);
          case TempUnit.c:
            return const AdemParamLimit(-40.0, 10.0);
        }
      case Param.temp:
      case Param.caseTemp:
        switch (adem.tempUnit!) {
          case TempUnit.f:
            return const AdemParamLimit(-40.0, 50.0);
          case TempUnit.c:
            return const AdemParamLimit(-40.0, 10.0);
        }
      case Param.baseTemp:
        switch (adem.tempUnit!) {
          case TempUnit.f:
            return const AdemParamLimit(32.0, 122.0);
          case TempUnit.c:
            return const AdemParamLimit(0.0, 50.0);
        }

      // corVol / uncVol
      case Param.corVol:
      case Param.uncVol:
      case Param.backupIndexCounter:
        return const AdemParamLimit(0, 99999999);

      // Flowrate
      case Param.uncFlowRateHighLimit when !adem.isMeterSizeSupported:
      case Param.uncFlowRateLowLimit when !adem.isMeterSizeSupported:
        return switch (adem.meterSystem) {
          MeterSystem.imperial => AdemParamLimit(0, maxFlowrate),
          MeterSystem.metric => AdemParamLimit(0.00, maxFlowrate),
        };

      case Param.uncFlowRateHighLimit:
        return AdemParamLimit(maxFlowrate * 0.7, maxFlowrate * 1.2);
      case Param.uncFlowRateLowLimit:
        return AdemParamLimit(0, maxFlowrate * 0.3);

      // Found from RometLink source code
      case Param.dpCalib1PtOffset:
        return switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => const AdemParamLimit(0.000, 24.000),
          DiffPressUnit.kpa => const AdemParamLimit(0.000, 6.000),
        };

      // Found from RometLink source code
      case Param.pressCalib1PtOffset:
        switch (adem.pressUnit!) {
          case PressUnit.psi:
            return const AdemParamLimit(-25.00, 25.00);
          case PressUnit.kpa:
            return const AdemParamLimit(-175.0, 175.0);
          case PressUnit.bar:
            return const AdemParamLimit(-1.750, 1.750);
        }
      // Found from RometLink source code
      case Param.tempCalib1PtOffset:
        switch (adem.tempUnit!) {
          case TempUnit.f:
          case TempUnit.c:
            return const AdemParamLimit(-25.0, 25.0);
        }

      case Param.threePtDpCalibParams:
        return switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => const AdemParamLimit(0.000, 24.000),
          DiffPressUnit.kpa => const AdemParamLimit(0.000, 6.000),
        };

      case Param.threePtPressCalibParams:
        switch (adem.pressUnit!) {
          case PressUnit.psi:
            return const AdemParamLimit(0.00, 1300.00);
          case PressUnit.kpa:
            return const AdemParamLimit(0.0, 9000.0);
          case PressUnit.bar:
            return const AdemParamLimit(0.000, 90.000);
        }
      case Param.threePtTempCalibParams:
        switch (adem.tempUnit!) {
          case TempUnit.f:
            return const AdemParamLimit(-40.0, 158.0);
          case TempUnit.c:
            return const AdemParamLimit(-40.0, 70.0);
        }

      // Super X
      case Param.gasSpecificGravity:
        if (adem.type == AdemType.ademTq) {
          return const AdemParamLimit(0.5000, 2.0000);
        } else {
          switch (superXAlgorithm!) {
            case SuperXAlgo.nx19:
              return const AdemParamLimit(0.5500, 0.7500);
            case SuperXAlgo.sgerg88:
            case SuperXAlgo.aga8G1:
            case SuperXAlgo.aga8G2:
              return const AdemParamLimit(0.5500, 0.9000);
            default:
              return null;
          }
        }

      case Param.gasMoleCO2:
        switch (superXAlgorithm!) {
          case SuperXAlgo.nx19:
            return const AdemParamLimit(0.000, 15.000);
          case SuperXAlgo.sgerg88:
          case SuperXAlgo.aga8G1:
          case SuperXAlgo.aga8G2:
            return const AdemParamLimit(0.000, 30.000);
          default:
            return null;
        }
      case Param.gasMoleN2:
        switch (superXAlgorithm!) {
          case SuperXAlgo.nx19:
            return const AdemParamLimit(0.000, 15.000);
          case SuperXAlgo.aga8G2:
            return const AdemParamLimit(0.000, 50.000);
          default:
            return null;
        }
      case Param.gasMoleH2:
        switch (superXAlgorithm!) {
          case SuperXAlgo.sgerg88:
            return const AdemParamLimit(0.000, 10.000);
          default:
            return null;
        }
      case Param.gasMoleHs:
        return switch (adem.meterSystem) {
          MeterSystem.imperial => const AdemParamLimit(400, 1300),
          MeterSystem.metric => const AdemParamLimit(15, 48),
        };
      case Param.gasMoleHsInEventLog:
        return switch (adem.meterSystem) {
          MeterSystem.imperial => const AdemParamLimit(400.00, 1300.00),
          MeterSystem.metric => const AdemParamLimit(15.00, 48.00),
        };

      case Param.provingTimeout:
        return const AdemParamLimit(360, 14400);

      // Unknown
      default:
        return null;
    }
  }
}

extension Aga8ParamLimit on Aga8Param {
  AdemParamLimit get limits => switch (this) {
    Aga8Param.methane => const AdemParamLimit(50.0, 100.0),
    Aga8Param.ethane => const AdemParamLimit(0.0, 20.0),
    Aga8Param.hydrogenSulphide => const AdemParamLimit(0.0, 0.05),
    Aga8Param.oxygen => const AdemParamLimit(0.0, 0.05),
    Aga8Param.isoPentane => const AdemParamLimit(0.0, 1.0),
    Aga8Param.nHeptane => const AdemParamLimit(0.0, 0.2),
    Aga8Param.nDecane => const AdemParamLimit(0.0, 0.05),
    Aga8Param.nitrogen => const AdemParamLimit(0.0, 50.0),
    Aga8Param.propane => const AdemParamLimit(0.0, 10.0),
    Aga8Param.hydrogen => const AdemParamLimit(0.0, 10.0),
    Aga8Param.isoButane => const AdemParamLimit(0.0, 3.0),
    Aga8Param.nPentane => const AdemParamLimit(0.0, 1.0),
    Aga8Param.nOctane => const AdemParamLimit(0.0, 0.05),
    Aga8Param.helium => const AdemParamLimit(0.0, 0.5),
    Aga8Param.carbonDioxide => const AdemParamLimit(0.0, 30.0),
    Aga8Param.water => const AdemParamLimit(0.0, 0.05),
    Aga8Param.carbonMonoxide => const AdemParamLimit(0.0, 3.0),
    Aga8Param.nButane => const AdemParamLimit(0.0, 3.0),
    Aga8Param.nHexane => const AdemParamLimit(0.0, 0.2),
    Aga8Param.nNonane => const AdemParamLimit(0.0, 0.05),
    Aga8Param.argon => const AdemParamLimit(0.0, 0.5),
  };
}

class AdemParamLimit {
  final num min;
  final num max;

  const AdemParamLimit(this.min, this.max);

  AdemParamLimit copyWith({num? min, num? max}) =>
      AdemParamLimit(min ?? this.min, max ?? this.max);

  bool isValid(num value) {
    return value >= min && value <= max;
  }
}
