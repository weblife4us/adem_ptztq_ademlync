import 'dart:math';

import '../utils/adem_param.dart';

const _bLen = 18;
const _cLen = 58;
const _cOffset = 12;

/// This manager contains two main methods:
///
/// 1. AGA8 Calculation Method:
///    - Implements an algorithm to calculate AGA8 details.
///    - The algorithm is directly copied from Rometlink's VB source code and converted to Dart.
///    - The code has been revamped and restructured, with unused methods and properties removed.
///    - Due to its origins, some variable names used in the calculations may be unclear.
///
/// 2. Configuration Mapping Method:
///    - Maps the configuration string.
///
/// It is recommended to run unit tests to ensure that any code changes do not affect accuracy.
class Aga8Manger {
  final double _basePress;
  final double _baseTemp;
  final PressUnit _pressUnit;
  final List<double> _aga8;

  Aga8Manger(this._basePress, this._baseTemp, this._pressUnit, this._aga8);

  // ---- Detail ----

  List<String> mapDetail() {
    // ---- Factors ----

    final b = List<double>.filled(_bLen, 0);
    final c = List<double>.filled(_cLen, 0);
    double k = 0;
    double z = 0;

    // ---- Init ----

    final (basePress, baseTemp, aga8) = _init();
    final e2DList = _get2DList(_e2DListDefVal);
    final u2DList = _get2DList(u2DListDefVal);
    final k2DList = _get2DList(k2DListDefVal);
    final g2DList = _get2DList(g2DListDefVal);
    double u1 = 0, g1 = 0, q1 = 0, fS = 0;
    final aga8Len = aga8.length;

    for (var i = 0; i < aga8Len; i++) {
      final val = aga8[i];
      k += val * _expLogAlgo(_listK[i], 2.5);
      u1 += val * _expLogAlgo(_listE[i], 2.5);
      g1 += val * _listG[i];
      q1 += val * _listQ[i];
      fS += pow(val, 2) * _listF[i];
    }

    k *= k;
    u1 *= u1;

    for (int i = 0; i < aga8Len - 1; i++) {
      for (int j = i + 1; j < aga8Len; j++) {
        final val = aga8[i] * aga8[j];

        if (val != 0) {
          k += _algo1(
            2 * val,
            _expLogAlgo(k2DList[i][j], 5),
            _expLogAlgo(_listK[i] * _listK[j], 2.5),
          );
          u1 += _algo1(
            2 * val,
            _expLogAlgo(u2DList[i][j], 5),
            _expLogAlgo(_listE[i] * _listE[j], 2.5),
          );
          g1 += _algo1(val, g2DList[i][j], _listG[i] + _listG[j]);
        }
      }
    }

    // ---- Calculates Factor B ----

    for (var i = 0; i < aga8Len; i++) {
      for (var j = i; j < aga8Len; j++) {
        double val = aga8[i] * aga8[j];

        if (val != 0) {
          final factorA = e2DList[i][j] * sqrt(_listE[i] * _listE[j]);
          final factorB = g2DList[i][j] * (_listG[i] + _listG[j]) / 2;

          if (i != j) {
            val *= 2;
          }

          for (var k = 0; k < _bLen; k++) {
            final valG = _listGn[k];
            final valQ = _listQn[k];
            final valF = _listFn[k];
            final valS = _listSn[k];
            final valW = _listWn[k];
            final factorG = _algo2(factorB, valG);
            final factorQ = _algo2(_listQ[i] * _listQ[j], valQ);
            final factorF = _algo2(sqrt(_listF[i] * _listF[j]), valF);
            final factorS = _algo2(_listS[i] * _listS[j], valS);
            final factorW = _algo2(_listW[i] * _listW[j], valW);

            if (factorG != 0 &&
                factorQ != 0 &&
                factorF != 0 &&
                factorS != 0 &&
                factorW != 0) {
              b[k] +=
                  _listAn[k] *
                  val *
                  _expLogAlgo(factorA, _listUn[k]) *
                  _expLogAlgo(_listK[i] * _listK[j], 1.5) *
                  _expLogAlgo(factorG, valG) *
                  _expLogAlgo(factorQ, valQ) *
                  _expLogAlgo(factorF, valF) *
                  _expLogAlgo(factorS, valS) *
                  _expLogAlgo(factorW, valW);
            }
          }
        }
      }
    }

    // ---- Calculates Factor C ----

    k = _expLogAlgo(k, 0.2);
    u1 = _expLogAlgo(u1, 0.2);

    for (var i = _cOffset; i < _cLen; i++) {
      final valG = _listGn[i];
      final valQ = _listQn[i];
      final valF = _listFn[i];
      final valA = _listAn[i];
      final valU = _listUn[i];
      final factorG = _algo2(g1, valG);
      final factorQ = _algo2(pow(q1, 2).toDouble(), valQ);
      final factorF = _algo2(fS, valF);

      c[i] = factorG != 0 && factorQ != 0 && factorF != 0
          ? _expLogAlgo(factorG, valG) *
                _expLogAlgo(factorQ, valQ) *
                _expLogAlgo(factorF, valF) *
                valA *
                _expLogAlgo(u1, valU)
          : 0;
    }

    // ---- Calculates Factor K ----

    k = pow(k, 3).toDouble();

    // ---- Calculates Factor Z ----

    double bMIX = 0;
    double guessA = 0.001;
    double guessB = 7;

    // Calculating bMIX
    for (var i = 0; i < b.length; i++) {
      bMIX += b[i] / _expLogAlgo(baseTemp, _listUn[i]);
    }

    // Initial values for the first two guesses
    z = _calculateZ(guessA, baseTemp, bMIX, c, k);
    double valueA = _algo3(guessA, z, basePress, baseTemp);

    z = _calculateZ(guessB, baseTemp, bMIX, c, k);
    double valueB = _algo3(guessB, z, basePress, baseTemp);

    // Check if the product of the function values at the initial guesses is negative,
    // indicating that there's a root between them
    if (valueA * valueB < 0) {
      for (var i = 0; i < 2; i++) {
        // Secant method to refine the guess
        final guessC = guessA - valueA * (guessB - guessA) / (valueB - valueA);

        z = _calculateZ(guessC, baseTemp, bMIX, c, k);
        final valueC = _algo3(guessC, z, basePress, baseTemp);

        double guessD =
            guessA * valueB * valueC / ((valueA - valueB) * (valueA - valueC)) +
            guessB * valueA * valueC / ((valueB - valueA) * (valueB - valueC)) +
            guessC * valueA * valueB / ((valueC - valueA) * (valueC - valueB));

        // Check if the new guess is within the interval [guessA, guessB]
        if ((guessD - guessA) * (guessD - guessB) >= 0) {
          guessD = (guessA + guessB) / 2;
        }

        z = _calculateZ(guessD, baseTemp, bMIX, c, k);
        final valueD = _algo3(guessD, z, basePress, baseTemp);

        // Check if the value is close enough to zero
        if ((valueD).abs() <= 0.0000000005) break;

        if (valueC.abs() < valueD.abs() && valueD * valueC > 0) {
          if (valueC * valueA > 0) {
            guessA = guessC;
            valueA = valueC;
          } else {
            guessB = guessC;
            valueB = valueC;
          }
        } else if (valueD * valueC < 0) {
          guessA = guessD;
          valueA = valueD;
          guessB = guessC;
          valueB = valueC;
        } else if (valueC * valueA > 0) {
          guessA = guessD;
          valueA = valueD;
        } else {
          guessB = guessD;
          valueB = valueD;
        }
      }
    }

    return _mapFactors(b, c, k, z);
  }

  (double, double, List<double>) _init() {
    final press = switch (_pressUnit) {
      PressUnit.kpa => _basePress / 1000,
      PressUnit.bar => _basePress / 10,
      PressUnit.psi => _basePress / 145.038,
    };

    final temp = switch (_pressUnit) {
      PressUnit.kpa || PressUnit.bar => _baseTemp + 273.15,
      PressUnit.psi => (_baseTemp - 32) / 1.8 + 273.15,
    };

    final sum = _aga8.reduce((v, o) => v + o);
    final aga8 = _aga8.map((o) => o / sum).toList();

    return (press, temp, aga8);
  }

  List<List<double>> _get2DList(Map<List<int>, double> values) {
    final res = List.generate(21, (_) => List<double>.filled(21, 1.0));
    values.forEach((k, v) => res[k[0]][k[1]] = v);
    return res;
  }

  double _expLogAlgo(double value, double exponent) {
    return exp(exponent * log(value));
  }

  double _algo1(double f1, double f2, double f3) {
    return f1 * (f2 - 1) * f3;
  }

  double _algo2(double f1, double f2) {
    return f1 + 1 - f2;
  }

  double _algo3(double d, double z, double press, double temp) {
    return 0.00831451 * d * temp * z - press;
  }

  double _calculateZ(
    double factor,
    double temp,
    double bMIX,
    List<double> c,
    double k,
  ) {
    final factorTimesK = factor * k;
    double z = 1 + bMIX * factor;

    for (var i = _cOffset; i < _bLen; i++) {
      z -= factorTimesK * c[i] / _expLogAlgo(temp, _listUn[i]);
    }

    if (factorTimesK != 0) {
      for (var i = _cOffset; i < _cLen; i++) {
        final bValue = _listBn[i];
        final kValue = _listKn[i];
        final cValue = _listCn[i];

        z +=
            c[i] /
            _expLogAlgo(temp, _listUn[i]) *
            (bValue - kValue * cValue * _expLogAlgo(factorTimesK, kValue)) *
            _expLogAlgo(factorTimesK, bValue) *
            exp(-cValue * _expLogAlgo(factorTimesK, kValue));
      }
    }

    return z;
  }

  List<String> _mapFactors(List<double> b, List<double> c, double k, double z) {
    return [
      ...b.asMap().entries.map(
        (o) =>
            _mapFactorString(o.value, 'B${o.key.toString().padLeft(2, '0')}'),
      ),
      ...c
          .skip(_cOffset)
          .toList()
          .asMap()
          .entries
          .map(
            (o) => _mapFactorString(
              o.value,
              'C${o.key.toString().padLeft(2, '0')}',
            ),
          ),
      _mapFactorString(k, 'K00'),
      _mapFactorString(z, 'Z00'),
    ];
  }

  String _mapFactorString(double value, String prefix) {
    const max = 99999999;
    const min = 10000000;

    num absValue;
    int exp = 0;

    if (value == 0) {
      return '$prefix+00000000+00';
    } else {
      absValue = value.abs().toInt();

      while (absValue > max) {
        value /= 10;
        exp++;
        absValue = value.abs().toInt();
      }

      while (absValue < min) {
        value *= 10;
        exp--;
        absValue = value.abs().toInt();
      }

      final valueString = absValue.toString().padLeft(8, '0');
      final suffix = exp.abs().toString().padLeft(2, '0');

      return '$prefix${value < 0 ? '-' : '+'}$valueString${exp < 0 ? '-' : '+'}$suffix';
    }
  }

  // ---- Config ----

  /// Map the AGA8 config string.
  String mapConfig() {
    final strList = _aga8.map((o) {
      return o
          .toStringAsFixed(2)
          .replaceAll('.', '')
          .padLeft(o == _aga8.first ? 5 : 4, '0');
    });
    return 'M${strList.join()}';
  }
}

// ---- Constance ----

// Energy parameters
const _listE = [
  151.3183,
  99.73778,
  241.9606,
  244.1667,
  298.1183,
  514.0156,
  296.355,
  26.95794,
  105.5348,
  122.7667,
  324.0689,
  337.6389,
  365.5999,
  370.6823,
  402.636293,
  427.72263,
  450.325022,
  470.840891,
  489.558373,
  2.610111,
  119.6299,
];

// Size parameters
const _listK = [
  0.4619255,
  0.4479153,
  0.4557489,
  0.5279209,
  0.583749,
  0.3825868,
  0.4618263,
  0.3514916,
  0.4533894,
  0.4186954,
  0.6406937,
  0.6341423,
  0.6738577,
  0.6798307,
  0.7175118,
  0.7525189,
  0.784955,
  0.8152731,
  0.8437826,
  0.3589888,
  0.4216551,
];

// Orientation parameters
const _listG = [
  0.0,
  0.027815,
  0.189065,
  0.0793,
  0.141239,
  0.3325,
  0.0885,
  0.034369,
  0.038953,
  0.021,
  0.256692,
  0.281835,
  0.332267,
  0.366911,
  0.289731,
  0.337542,
  0.383381,
  0.427354,
  0.469659,
  0.0,
  0.0,
];

// Quadrupole parameters
const _listQ = [
  0.0,
  0.0,
  0.69,
  0.0,
  0.0,
  1.06775,
  0.633276,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

// High temperature parameter
const _listF = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

// Dipole parameter
const _listS = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.5822,
  0.39,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

// Association parameter
const _listW = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

// Coefficients of the equation of state
const _listAn = [
  0.1538326,
  1.341953,
  -2.998583,
  -0.04831228,
  0.3757965,
  -1.589575,
  -0.05358847,
  0.88659463,
  -0.71023704,
  -1.471722,
  1.32185035,
  -0.78665925,
  0.00000000229129,
  0.1576724,
  -0.4363864,
  -0.04408159,
  -0.003433888,
  0.03205905,
  0.02487355,
  0.07332279,
  -0.001600573,
  0.6424706,
  -0.4162601,
  -0.06689957,
  0.2791795,
  -0.6966051,
  -0.002860589,
  -0.008098836,
  3.150547,
  0.007224479,
  -0.7057529,
  0.5349792,
  -0.07931491,
  -1.418465,
  -5.99905E-17,
  0.1058402,
  0.03431729,
  -0.007022847,
  0.02495587,
  0.04296818,
  0.7465453,
  -0.2919613,
  7.294616,
  -9.936757,
  -0.005399808,
  -0.2432567,
  0.04987016,
  0.003733797,
  1.874951,
  0.002168144,
  -0.6587164,
  0.000205518,
  0.009776195,
  -0.02048708,
  0.01557322,
  0.006862415,
  -0.001226752,
  0.002850908,
];

// Density exponents
const _listBn = [
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  2.0,
  2.0,
  2.0,
  2.0,
  2.0,
  2.0,
  2.0,
  2.0,
  2.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  3.0,
  4.0,
  4.0,
  4.0,
  4.0,
  4.0,
  4.0,
  4.0,
  5.0,
  5.0,
  5.0,
  5.0,
  5.0,
  6.0,
  6.0,
  7.0,
  7.0,
  8.0,
  8.0,
  8.0,
  9.0,
  9.0,
];

const _listCn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  0.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  0.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  0.0,
  1.0,
  0.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
  1.0,
];

const _listKn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  3.0,
  2.0,
  2.0,
  2.0,
  4.0,
  4.0,
  0.0,
  0.0,
  2.0,
  2.0,
  2.0,
  4.0,
  4.0,
  4.0,
  4.0,
  0.0,
  1.0,
  1.0,
  2.0,
  2.0,
  3.0,
  3.0,
  4.0,
  4.0,
  4.0,
  0.0,
  0.0,
  2.0,
  2.0,
  2.0,
  4.0,
  4.0,
  0.0,
  2.0,
  2.0,
  4.0,
  4.0,
  0.0,
  2.0,
  0.0,
  2.0,
  1.0,
  2.0,
  2.0,
  2.0,
  2.0,
];

// Temperature exponents
const _listUn = [
  0.0,
  0.5,
  1.0,
  3.5,
  -0.5,
  4.5,
  0.5,
  7.5,
  9.5,
  6.0,
  12.0,
  12.5,
  -6.0,
  2.0,
  3.0,
  2.0,
  2.0,
  11.0,
  -0.5,
  0.5,
  0.0,
  4.0,
  6.0,
  21.0,
  23.0,
  22.0,
  -1.0,
  -0.5,
  7.0,
  -1.0,
  6.0,
  4.0,
  1.0,
  9.0,
  -13.0,
  21.0,
  8.0,
  -0.5,
  0.0,
  2.0,
  7.0,
  9.0,
  22.0,
  23.0,
  1.0,
  9.0,
  3.0,
  8.0,
  23.0,
  1.5,
  5.0,
  -0.5,
  4.0,
  7.0,
  3.0,
  0.0,
  1.0,
  0.0,
];

const _listGn = [
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  1.0,
  1.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  1.0,
  0.0,
  1.0,
  0.0,
  0.0,
];

const _listQn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  1.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
];

// Flags
const _listFn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

const _listSn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

const _listWn = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  1.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

const _e2DListDefVal = {
  [0, 1]: 0.97164,
  [0, 2]: 0.960644,
  [0, 4]: 0.994635,
  [0, 5]: 0.708218,
  [0, 6]: 0.931484,
  [0, 7]: 1.17052,
  [0, 8]: 0.990126,
  [0, 10]: 1.01953,
  [0, 11]: 0.989844,
  [0, 12]: 1.00235,
  [0, 13]: 0.999268,
  [0, 14]: 1.107274,
  [0, 15]: 0.88088,
  [0, 16]: 0.880973,
  [0, 17]: 0.881067,
  [0, 18]: 0.881161,
  [1, 2]: 1.02274,
  [1, 3]: 0.97012,
  [1, 4]: 0.945939,
  [1, 5]: 0.746954,
  [1, 6]: 0.902271,
  [1, 7]: 1.08632,
  [1, 8]: 1.00571,
  [1, 9]: 1.021,
  [1, 10]: 0.946914,
  [1, 11]: 0.973384,
  [1, 12]: 0.95934,
  [1, 13]: 0.94552,
  [2, 3]: 0.925053,
  [2, 4]: 0.960237,
  [2, 5]: 0.849408,
  [2, 6]: 0.955052,
  [2, 7]: 1.28179,
  [2, 8]: 1.5,
  [2, 10]: 0.906849,
  [2, 11]: 0.897362,
  [2, 12]: 0.726255,
  [2, 13]: 0.859764,
  [2, 14]: 0.855134,
  [2, 15]: 0.831229,
  [2, 16]: 0.80831,
  [2, 17]: 0.786323,
  [2, 18]: 0.765171,
  [3, 4]: 1.02256,
  [3, 5]: 0.693168,
  [3, 6]: 0.946871,
  [3, 7]: 1.16446,
  [3, 11]: 1.01306,
  [3, 13]: 1.00532,
  [4, 7]: 1.034787,
  [4, 11]: 1.0049,
  [6, 14]: 1.008692,
  [6, 15]: 1.010126,
  [6, 16]: 1.011501,
  [6, 17]: 1.012821,
  [6, 18]: 1.014089,
  [7, 8]: 1.1,
  [7, 10]: 1.3,
  [7, 11]: 1.3,
};

const u2DListDefVal = {
  [0, 1]: 0.886106,
  [0, 2]: 0.963827,
  [0, 4]: 0.990877,
  [0, 6]: 0.736833,
  [0, 7]: 1.15639,
  [0, 11]: 0.992291,
  [0, 13]: 1.00367,
  [0, 14]: 1.302576,
  [0, 15]: 1.191904,
  [0, 16]: 1.205769,
  [0, 17]: 1.219634,
  [0, 18]: 1.233498,
  [1, 2]: 0.835058,
  [1, 3]: 0.816431,
  [1, 4]: 0.915502,
  [1, 6]: 0.993476,
  [1, 7]: 0.408838,
  [1, 11]: 0.993556,
  [2, 3]: 0.96987,
  [2, 6]: 1.04529,
  [2, 8]: 0.9,
  [2, 14]: 1.066638,
  [2, 15]: 1.077634,
  [2, 16]: 1.088178,
  [2, 17]: 1.098291,
  [2, 18]: 1.108021,
  [3, 4]: 1.065173,
  [3, 6]: 0.971926,
  [3, 7]: 1.61666,
  [3, 10]: 1.25,
  [3, 11]: 1.25,
  [3, 12]: 1.25,
  [3, 13]: 1.25,
  [6, 14]: 1.028973,
  [6, 15]: 1.033754,
  [6, 16]: 1.038338,
  [6, 17]: 1.042735,
  [6, 18]: 1.046966,
};

const k2DListDefVal = {
  [0, 1]: 1.00363,
  [0, 2]: 0.995933,
  [0, 4]: 1.007619,
  [0, 6]: 1.00008,
  [0, 7]: 1.02326,
  [0, 11]: 0.997596,
  [0, 13]: 1.002529,
  [0, 14]: 0.982962,
  [0, 15]: 0.983565,
  [0, 16]: 0.982707,
  [0, 17]: 0.981849,
  [0, 18]: 0.980991,
  [1, 2]: 0.982361,
  [1, 3]: 1.00796,
  [1, 6]: 0.942596,
  [1, 7]: 1.03227,
  [2, 3]: 1.00851,
  [2, 6]: 1.00779,
  [2, 14]: 0.910183,
  [2, 15]: 0.895362,
  [2, 16]: 0.881152,
  [2, 17]: 0.86752,
  [2, 18]: 0.854406,
  [3, 4]: 0.986893,
  [3, 6]: 0.999969,
  [3, 7]: 1.02034,
  [6, 14]: 0.96813,
  [6, 15]: 0.96287,
  [6, 16]: 0.957828,
  [6, 17]: 0.952441,
  [6, 18]: 0.948338,
};

const g2DListDefVal = {
  [0, 2]: 0.807653,
  [0, 7]: 1.95731,
  [1, 2]: 0.982746,
  [2, 3]: 0.370296,
  [2, 5]: 1.67309,
};
