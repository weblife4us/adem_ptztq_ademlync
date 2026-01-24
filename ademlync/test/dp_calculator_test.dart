import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skylab/features/dp_calculator/dp_calculator_enums.dart';
import 'package:skylab/features/dp_calculator/dp_calculator_manager.dart';

void main() {
  final manager = DpCalculatorManager();
  Uint8List? excelBytes;
  Uint8List? pdfBytes;

  group('Dp Calculator', () {
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();

      manager
        ..setStatus(
          badgeSerialNumber: 'fake',
          rometSerialNumber: 'fake',
          customerName: 'fake',
          customerId: 'fake',
          meterType: 'fake',
          snPart2: 'fake',
          installationSite: 'fake',
          indexReading: '22',
          testedBy: '11',
          comment: '33',
        )
        ..setArgument(
          meter: DpCalculatorMeter.rmt600Flange,
          atmosphericPressPsia: 5.00,
          lineGaugePress: 1.00,
          lineGaugePressUnit: GasLineGaugePressureUnit.psig,
          dpInWc: 0.300,
          specificGravity: 1.000,
          uncFlowRate: 300.00,
        )
        ..calculate();

      excelBytes = await manager.buildReport(.excel);
      pdfBytes = await manager.buildReport(.pdf);
    });

    test('Dp Calculator - Result', () {
      final result = manager.result;
      if (result == null) return;
      debugPrint('maxAllowableDp: ${result.maxAllowableDp}');
      debugPrint('pass: ${result.isPassed}');
    });

    test('Dp Calculator - Report', () {
      debugPrint('Excel: ${excelBytes?.length}');
      debugPrint('Pdf: ${pdfBytes?.length}');
    });
  });
}
