import 'dart:developer';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('Case 1', () {
    test('Case 1 | Test 1: AGA8 Detail Testing', () {
      const str =
          '181124,010700,00000000,00000000,      NA,  0022.9,000.9733,00000.00,00000.00,00003.62';
      final bytes = <int>[...utf8.encode(str), ControlChar.etx.byte];
      log(bytes.toString());

      final crc = crcCalculation(bytes);
      log(crc);

      expect(crc, 'F394');
    });
  });
}
