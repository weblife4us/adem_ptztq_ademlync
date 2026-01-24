import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Case 1', () {
    test('Successful case', () {
      const cases = [
        {'D050RS25': true},
        {'D050RT33': true},
        {'-': true},
        {'-': true},
        {'D05XM014': true},
        {'-': true},
      ];

      _checking(cases);
    });

    test('Failure case', () {
      const cases = [
        {'D050RS05': false},
        {'D050RT23': false},
        {'-': true},
        {'-': true},
        {'D05XM004': false},
        {'-': true},
      ];

      _checking(cases);
    });
  });
}

void _checking(List<Map<String, bool>> cases) {
  for (int i = 0; i < cases.length; i++) {
    final map = cases[i];
    final type = AdemType.values[i];
    final res = type.isSerialNumberPart2Supported(map.keys.first);

    expect(res, map.values.first);
  }
}
