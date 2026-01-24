import 'package:excel/excel.dart';

import '../../features/file_export/report.dart';
import '../functions.dart';
import 'date_time_fmt_manager.dart';

class ExcelManager {
  /// Builds an Excel file based on the provided [Report] data.
  Excel build(Report report) {
    final Report(:title, :subTitles, :headers, :records, :dateTime) = report;
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    int row = 1;

    // Add the report title
    _getCell(sheet, 'A', row++).value = TextCellValue(title);

    // Add any subtitles if they exist
    if (subTitles?.isNotEmpty ?? false) {
      for (final subtitle in subTitles!) {
        if (subtitle.isNotEmpty) {
          _getCell(sheet, 'A', row++).value = TextCellValue(subtitle);
        }
      }
    }

    _getCell(sheet, 'A', row++).value = TextCellValue(
      'Generate Time (${dateTime.timeZoneName}, UTC${dateTime.timeZoneOffset.inHours}): ${DateTimeFmtManager.formatDateTime(dateTime)}',
    );

    // Add the headers
    for (var i = 0, col = 65; i < headers.length; i++, col++) {
      _getCell(sheet, col.toChar, row).value = TextCellValue(
        headers[i].removeTag(),
      );
    }
    row++;

    // Add the records row by row
    for (var record in records) {
      int column = 65;
      for (var entry in record) {
        _getCell(sheet, (column++).toChar, row).value = TextCellValue(
          entry.removeTag(),
        );
      }
      row++;
    }

    return excel;
  }

  /// Utility method to get a cell in the given [sheet] at the specified [column] and [row].
  ///
  /// Returns a [Data] object representing the cell.
  Data _getCell(Sheet sheet, String column, int row) {
    return sheet.cell(CellIndex.indexByString('$column$row'));
  }
}

/// Extension method to convert an integer to its corresponding character.
/// Converts numbers greater than 90 (which corresponds to 'Z') to 'A' followed by the next character.
extension _IntExt on int {
  String get toChar => this > 90
      ? 'A${String.fromCharCode(this - 26)}'
      : String.fromCharCode(this);
}
