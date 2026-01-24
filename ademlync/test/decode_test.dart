import 'dart:developer';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:skylab/utils/controllers/param_format_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Decode/Encode Test', () {
    group('Decode Test', () {
      final pList = <String>[];

      pList.add('Decode Test --- Start');

      for (final testCase in _decodeTestCases.entries) {
        final MapEntry(key: param, value: testCases) = testCase;
        test('Decode Test --- $param', () {
          pList.add('Decode Test --- $param');
          for (final testCase in testCases.entries) {
            final MapEntry(key: value, value: expected) = testCase;
            final actual = ParamFormatManager().decode(param, value);

            pList.add('''-----------------------------
| Actual: $actual <${actual.runtimeType}>
| Expect: $expected <(${expected.runtimeType}>
-----------------------------''');

            expect(actual.runtimeType, expected.runtimeType);
            expect(actual, expected);
          }
        });
      }

      pList.add('Decode Test --- End');

      pList.forEach(log);
    });

    group('Encode Test', () {
      final pList = <String>[];

      pList.add('Encode Test --- Start');

      for (final testCase in _encodeTestCases.entries) {
        final MapEntry(key: param, value: testCases) = testCase;
        test('Encode Test --- $param', () {
          pList.add('Encode Test --- $param');
          for (final testCase in testCases.entries) {
            final MapEntry(key: value, value: expected) = testCase;
            final actual = ParamFormatManager().encodeFromDisplayValue(
              param,
              value,
            );

            pList.add('''-----------------------------
| Actual: $actual <${actual.runtimeType}>
| Expect: $expected <(${expected.runtimeType}>
-----------------------------''');

            expect(actual.runtimeType, expected.runtimeType);
            expect(actual, expected);
          }
        });
      }

      pList.add('Encode Test --- End');

      pList.forEach(log);
    });
  });
}

final _decodeTestCases = {
  Param.meterSize: {for (var o in MeterSize.values) o.receiveKey: o},
  Param.cstmDispParam1: {
    for (var o in CustDispItem.values) o.receiveKey.toAdemStringFmt(): o,
  },
  Param.corOutputPulseVolUnit: {
    for (var o in VolumeUnit.values) o.key.toAdemStringFmt(): o,
  },
  Param.dateFormat: {
    for (var o in UnitDateFmt.values) o.key.toAdemStringFmt(): o,
  },
  Param.dispVolSelect: {
    for (var o in DispVolSelect.values) o.key.toAdemStringFmt(): o,
  },
  Param.corVolDigits: {
    for (var o in VolDigits.values) o.key.toAdemStringFmt(): o,
  },
  Param.outPulseSpacing: {
    for (var o in OutPulseSpacing.values) o.key.toAdemStringFmt(): o,
  },
  Param.outPulseWidth: {
    for (var o in OutPulseWidth.values) o.key.toAdemStringFmt(): o,
  },
  Param.pressTransType: {
    for (var o in PressTransType.values) o.key.toAdemStringFmt(): o,
  },
  Param.pressFactorType: {
    for (var o in FactorType.values) o.key.toAdemStringFmt(): o,
  },
  Param.superXAlgo: {
    for (var o in SuperXAlgo.values) o.key.toAdemStringFmt(): o,
  },
  Param.outputPulseChannel3: {
    for (var o in PulseChannel.values) o.key.toAdemStringFmt(): o,
  },
  Param.intervalLogInterval: {
    for (var o in IntervalLogInterval.values) o.key.toAdemStringFmt(): o,
  },
  Param.intervalLogType: {
    for (var o in IntervalLogType.values) o.key.toAdemStringFmt(): o,
  },
  Param.provingVol: {'00000123': 123},
  Param.pressTransRange: {'000100.0': 100.0},
  Param.tempLowLimit: {' -0020.0': -20.0},
  Param.baseTemp: {'00012.00': 12.0},
  Param.basePress: {'0071.123': 71.123},
  Param.gasDayStartTime: {'12 30 45': unitTimeFmt.parse('12 30 45')},
};

final _encodeTestCases = {
  Param.meterSize: {for (var o in MeterSize.values) o: o.sendKey},
  Param.cstmDispParam1: {
    for (var o in CustDispItem.values) o: o.sendKey.toAdemStringFmt(),
  },
  Param.corOutputPulseVolUnit: {for (var o in VolumeUnit.values) o: o.sendKey},
  Param.dateFormat: {for (var o in UnitDateFmt.values) o: o.sendKey},
  Param.dispVolSelect: {for (var o in DispVolSelect.values) o: o.sendKey},
  Param.corVolDigits: {for (var o in VolDigits.values) o: o.sendKey},
  Param.outPulseSpacing: {for (var o in OutPulseSpacing.values) o: o.sendKey},
  Param.outPulseWidth: {for (var o in OutPulseWidth.values) o: o.sendKey},
  Param.pressTransType: {for (var o in PressTransType.values) o: o.sendKey},
  Param.pressFactorType: {for (var o in FactorType.values) o: o.sendKey},
  Param.superXAlgo: {for (var o in SuperXAlgo.values) o: o.sendKey},
  Param.outputPulseChannel3: {for (var o in PulseChannel.values) o: o.sendKey},
  Param.intervalLogInterval: {
    for (var o in IntervalLogInterval.values) o: o.sendKey,
  },
  Param.intervalLogType: {for (var o in IntervalLogType.values) o: o.sendKey},
  Param.provingVol: {123: '00000123'},
  Param.minTemp: {10.0: '000010.0'},
  Param.pressTransRange: {100.0: '000100.0'},
  Param.tempLowLimit: {-20.0: '-00020.0'},
  Param.baseTemp: {12.0: '   12.00'},
  Param.basePress: {71.123: '  71.123'},
  Param.gasDayStartTime: {unitTimeFmt.parse('12 30 45'): '12 30 45'},
};
