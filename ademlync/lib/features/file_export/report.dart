import 'dart:typed_data';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/controllers/excel_manager.dart';
import '../../utils/controllers/pdf_manager.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Report extends Equatable {
  final String title;
  final DateTime dateTime;
  final List<String>? subTitles;
  final List<String> headers;
  final List<List<String>> records;

  const Report({
    required this.title,
    required this.dateTime,
    this.subTitles,
    required this.headers,
    required this.records,
  });

  factory Report.fromLog({
    required LogType type,
    required List<String> headers,
    required List<List<String>> records,
    LogTimeRange? dateTimeRange,
    IntervalLogType? intervalType,
    required DateTime dateTime,
  }) {
    final subTitles = [
      intervalType?.displayName,
      dateTimeRange != null
          ? 'From: ${DateTimeFmtManager.formatDateTime(dateTimeRange.from)}\nTo: ${DateTimeFmtManager.formatDateTime(dateTimeRange.to)}'
          : null,
    ].whereType<String>().toList();

    return Report(
      title: type.displayName,
      dateTime: dateTime,
      subTitles: subTitles,
      headers: headers,
      records: records,
    );
  }

  Future<Uint8List> toBytes(ExportFormat format) async => switch (format) {
    ExportFormat.excel => _toBytesAsExcel(),
    ExportFormat.pdf => await _toBytesAsPdf(),
    ExportFormat.json => throw Exception('Report only support excel or pdf.'),
  };

  Uint8List _toBytesAsExcel() {
    final excel = ExcelManager().build(this);
    final bytes = excel.save();

    if (bytes == null) throw Exception('Bytes is null');

    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> _toBytesAsPdf() async {
    final pdf = PdfManager().build(this);
    final bytes = await pdf.save();

    return bytes;
  }

  @override
  List<Object?> get props => [title, subTitles, headers, records];
}
