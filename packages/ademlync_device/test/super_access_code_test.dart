import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Case 1', () {
    test('Successful case', () {
      const cases = [
        {'D020RT03': true},
        {'D020RT03': true},
        {'-': true},
        {'-': true},
        {'D00XM004': true},
        {'-': true},
      ];

      _checking(cases);
    });

    test('Failure case', () {
      const cases = [
        {'C050RT05': false},
        {'C060RT03': false},
        {'-': true},
        {'-': true},
        {'C07XM004': false},
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
    final res = type.isSuperAccessCodeSupported(map.keys.first);

    expect(res, map.values.first);
  }
}
