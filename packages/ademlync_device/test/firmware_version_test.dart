import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Case 1', () {
    test('Check firmware version', () {
      const cases = [
        {'D050RS25': AdemType.ademS},
        {'D050RT33': AdemType.ademT},
        {'D050MT33': AdemType.universalT},
        {'D050MQ17': AdemType.ademTq},
        {'D05NM014': AdemType.ademPtz},
        {'D05NM016': AdemType.ademPtzR},
        {'D050RQ17': AdemType.ademTq}, // AdEM 25
        {'D05NR014': AdemType.ademPtz}, // AdEM 25
        {'D05NR016': AdemType.ademPtzR}, // AdEM 25
      ];

      _checking(cases);
    });
  });
}

void _checking(List<Map<String, AdemType>> cases) {
  for (int i = 0; i < cases.length; i++) {
    final map = cases[i];
    final res = AdemType.from(map.keys.first, null);

    expect(res, map.values.first);
  }
}
