import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../features/file_export/report.dart';
import '../functions.dart';
import 'date_time_fmt_manager.dart';

class PdfManager {
  /// Builds a PDF document based on the given [Report] data.
  Document build(Report report) {
    final Report(:title, :subTitles, :headers, :records, :dateTime) = report;
    final pdf = Document();

    pdf.addPage(
      MultiPage(
        margin: const EdgeInsets.all(24.0),
        pageFormat: PdfPageFormat.a4.landscape,
        maxPages: 100,
        // Footer to display page numbers
        footer: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              'Page ${context.pageNumber}',
              style: const TextStyle(fontSize: 6.0, height: 1.0),
            ),
          ),
        ),
        // Header to display the report title and optional subtitles
        header: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14.0, height: 1.0)),
              if (subTitles?.isNotEmpty ?? false) ...[
                for (final subtitle in subTitles!)
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 24.0),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12.0, height: 1.0),
                    ),
                  ],
              ],
              SizedBox(height: 24.0),
              Text(
                'Generate Time (${dateTime.timeZoneName}, UTC${dateTime.timeZoneOffset.inHours}):  ${DateTimeFmtManager.formatDateTime(dateTime)}',
                style: const TextStyle(fontSize: 12.0, height: 1.0),
              ),
              SizedBox(height: 24.0),
              // Display column headers
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  for (var header in headers)
                    SizedBox(
                      width: 32.0,
                      child: Text(
                        header.removeTag(),
                        overflow: TextOverflow.span,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 6.0, height: 1.0),
                      ),
                    ),
                ],
              ),
              Divider(),
            ],
          );
        },
        // Main content of the PDF displaying the records
        build: (_) => [
          ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, _) => Divider(),
            itemBuilder: (_, i) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    for (var record in records[i])
                      SizedBox(
                        width: 32.0,
                        child: Text(
                          record.removeTag(),
                          overflow: TextOverflow.span,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 6.0, height: 1.0),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return pdf;
  }
}
