import 'dart:developer';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../utils/controllers/date_time_fmt_manager.dart';
import 'dp_calculator_const.dart';
import 'dp_calculator_enums.dart';
import 'dp_calculator_models.dart';

class DpCalculatorManager {
  DpCalculatorArgument? _argument;
  DpCalculatorResult? _result;
  DpCalculatorStatus? _status;
  DateTime? _lastCalculationTime;

  DpCalculatorArgument? get argument => _argument;

  DpCalculatorResult? get result => _result;

  DpCalculatorStatus? get status => _status;

  DateTime? get lastCalculationTime => _lastCalculationTime;

  void setArgument({
    required DpCalculatorMeter meter,
    required double atmosphericPressPsia,
    required double lineGaugePress,
    required GasLineGaugePressureUnit lineGaugePressUnit,
    required double dpInWc,
    required double specificGravity,
    required double uncFlowRate,
  }) {
    final arg = DpCalculatorArgument(
      meter,
      atmosphericPressPsia,
      lineGaugePress,
      lineGaugePressUnit,
      dpInWc,
      specificGravity,
      uncFlowRate,
    );

    _argument = arg;
  }

  void setStatus({
    required String badgeSerialNumber,
    required String rometSerialNumber,
    required String customerName,
    required String customerId,
    required String meterType,
    required String snPart2,
    required String installationSite,
    required String indexReading,
    required String testedBy,
    required String comment,
  }) {
    final status = DpCalculatorStatus(
      badgeSerialNumber,
      rometSerialNumber,
      customerName,
      customerId,
      meterType,
      snPart2,
      installationSite,
      indexReading,
      testedBy,
      comment,
    );

    _status = status;
  }

  DpCalculatorResult? calculate() {
    final arg = _argument;
    if (arg == null || arg.percentMaxFlow < dpCalculatorMinPercentMaxFlow) {
      log('Data and argument cannot null. Max flow rate% must > 10.');
      throw DpCalculatorError.percentMaxFlowBelow10;
    }

    final percent = arg.percentMaxFlow.clamp(0.0, 100.0);
    final flowRates = arg.meter.flowRateList;
    final idx = (percent / 10).floor();

    final lowerDp = flowRates[idx];
    final upperDp = flowRates[(idx + 1).clamp(0, flowRates.length - 1)];
    final fraction = (percent % 10) / 10;

    final baseDp = lowerDp + (upperDp - lowerDp) * fraction;

    final sgCorrection = arg.specificGravity / 0.6;
    final pressCorrection =
        (arg.atmosphericPressPsia + arg.linePressurePsia) /
        arg.atmosphericPressPsia;

    final maxAllowableDp =
        baseDp * sgCorrection * pressCorrection * dpAllowableFactor +
        dpUncertainty;

    final result = DpCalculatorResult(
      maxAllowableDp,
      arg.dpInWc <= maxAllowableDp,
    );

    _result = result;
    _lastCalculationTime = DateTime.now();
    return result;
  }

  Future<Uint8List?> buildReport(ExportFormat fmt) async {
    if (fmt == .json) {
      log('JSON is not supported.');
      return null;
    }

    if (_argument == null || _result == null || _lastCalculationTime == null) {
      log('Some data are not ready.');
      return null;
    }

    try {
      final bytes = switch (fmt) {
        ExportFormat.excel => null,
        ExportFormat.pdf => await _buildPdf(),
        ExportFormat.json => null,
      };

      return bytes;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _buildPdf() async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    final logoBytes = await rootBundle
        .load('assets/images/logo_romet.png')
        .then((data) => data.buffer.asUint8List());
    final logoImage = pw.MemoryImage(logoBytes);

    final columnWidths = {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(4),
    };

    final smallTextStyle = const pw.TextStyle(fontSize: 8.0);
    final mediumTextStyle = const pw.TextStyle(fontSize: 12.0);
    final mediumBoldTextStyle = pw.TextStyle(
      fontSize: 12.0,
      fontWeight: pw.FontWeight.bold,
    );
    final largeTextStyle = pw.TextStyle(
      fontSize: 16.0,
      fontWeight: pw.FontWeight.bold,
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24.0),
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 200.0),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '5030 TIMBERLEA BLVD., MISSISSAUGA, ONTARIO, CANADA, L4W 2S5',
                      style: smallTextStyle,
                    ),

                    pw.SizedBox(height: 2.0),
                    pw.Text('TELEPHONE: 905-624-1591', style: smallTextStyle),

                    pw.SizedBox(height: 2.0),
                    pw.Text(
                      'romet@rometlimited.com   www.rometlimited.com',
                      style: smallTextStyle,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20.0),
            pw.Center(
              child: pw.Text(
                'ROTARY METER DIFFERENTIAL ACCEPTANCE CERTIFICATE',
                style: largeTextStyle,
              ),
            ),

            pw.SizedBox(height: 20.0),
          ],
        ),
        build: (context) => [
          pw.Text('Meter Information', style: mediumBoldTextStyle),

          pw.SizedBox(height: 2.0),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: columnWidths,
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Meter Size', style: mediumTextStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.meter.name,
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Badge Serial Number',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _status!.badgeSerialNumber,
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'ROMET Serial Number',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _status!.rometSerialNumber,
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Customer Name', style: mediumTextStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _status!.customerName,
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Customer ID', style: mediumTextStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(_status!.customerId, style: mediumTextStyle),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Meter Manuf. and Model',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(_status!.meterType, style: mediumTextStyle),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('2nd Serial Number', style: mediumTextStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(_status!.snPart2, style: mediumTextStyle),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Installation Site', style: mediumTextStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _status!.installationSite,
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20.0),
          pw.Text('Field Data', style: mediumBoldTextStyle),

          pw.SizedBox(height: 2.0),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: columnWidths,
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Atmospheric Pressure [PSIA]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.atmosphericPressPsia.toStringAsFixed(
                        dpCalculatorAtmosphericPressPsiaDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Gas Line Gauge Pressure [${_argument!.lineGaugePressUnit.name}]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.lineGaugePress.toStringAsFixed(
                        _argument!.lineGaugePressUnit.decimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Differential Pressure [inWC (60°F)]',
                      style: mediumBoldTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.dpInWc.toStringAsFixed(
                        dpCalculatorDpInWcDecimal,
                      ),
                      style: mediumBoldTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Gas Specific Gravity',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.specificGravity.toStringAsFixed(
                        dpCalculatorSpecificGravityDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Uncorrected Flow Rate [Ft3/H]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.uncFlowRate.toStringAsFixed(
                        dpCalculatorUncFlowRateDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Index Reading at Starting',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _status!.indexReading.toString(),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20.0),
          pw.Text('Calculation Result', style: mediumBoldTextStyle),

          pw.SizedBox(height: 2.0),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: columnWidths,
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Uncorrected Flow Rate [Ft3/H]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.uncFlowRate.toStringAsFixed(
                        dpCalculatorUncFlowRateDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Percentage of Max. Flow Rate [%]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _argument!.percentMaxFlow.toStringAsFixed(
                        dpCalculatorPercentMaxFlowDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Max. Allowable Differential [inWC (60°F)]',
                      style: mediumTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _result!.maxAllowableDp.toStringAsFixed(
                        dpCalculatorMaxAllowableDpDecimal,
                      ),
                      style: mediumTextStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Differential Acceptance Result',
                      style: mediumBoldTextStyle,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _result!.isPassed
                          ? reportPassedString
                          : reportFailedString,
                      style: mediumBoldTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20.0),
          pw.Text('Comments:', style: mediumBoldTextStyle),

          pw.SizedBox(height: 2.0),
          pw.Container(
            width: double.maxFinite,
            constraints: const pw.BoxConstraints(minHeight: 60.0),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(_status!.comment, style: mediumTextStyle),
            ),
          ),

          pw.SizedBox(height: 40.0),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Tested Date: ${DateTimeFmtManager.formatDate(_lastCalculationTime!)} | ${DateTimeFmtManager.formatTimestamp(_lastCalculationTime!)}',
                style: mediumTextStyle,
              ),
              pw.Text(
                'Tested By: ${_status!.testedBy}',
                style: mediumTextStyle,
              ),
            ],
          ),
        ],
      ),
    );

    return await pdf.save();
  }
}
