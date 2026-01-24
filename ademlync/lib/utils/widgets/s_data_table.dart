import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/date_time_fmt_manager.dart';
import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../enums.dart';
import '../ui_specification.dart';
import 's_style_text.dart';
import 's_text.dart';

class SLogTable<T> extends StatelessWidget {
  final IntervalLogType? intervalType;
  final List<String> headers;
  final List<List<String>> data;
  final LogTimeRange? dateTimeRange;

  const SLogTable({
    super.key,
    this.intervalType,
    required this.headers,
    required this.data,
    this.dateTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateNotifier>(context).isDark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 96.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrientationBuilder(
              builder: (_, _) {
                final height = UISpecification.screenHeight;
                final rowsPerPage = !UISpecification.isTablet
                    ? 10
                    : (height < 800.0 ? 10 : (height < 1300.0 ? 15 : 20));

                return Theme(
                  data: ThemeData().copyWith(
                    cardTheme: CardThemeData(
                      color: colorScheme.appBackground(context),
                      elevation: 0.0,
                      surfaceTintColor: Colors.transparent,
                    ),
                    textTheme: TextTheme(
                      bodySmall: TextStyle(
                        fontFamily: 'MinionPro',
                        fontSize: 14.0,
                        height: 1.0,
                        color: colorScheme.text(context),
                      ),
                    ),
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(
                      color: Colors.transparent,
                      space: 0,
                      thickness: 0,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ),
                  child: PaginatedDataTable(
                    rowsPerPage: rowsPerPage,
                    arrowHeadColor: colorScheme.text(context),
                    columns: [
                      for (var e in headers)
                        DataColumn(
                          label: _DecoratedBox.header(text: e, isDark: isDark),
                        ),
                    ],
                    source: _DataSource(context, data, isDark),
                    header: dateTimeRange != null || intervalType != null
                        ? Text(
                            dateTimeRange == null
                                ? ''
                                : 'From: ${DateTimeFmtManager.formatDateTime(dateTimeRange!.from)}\nTo: ${DateTimeFmtManager.formatDateTime(dateTimeRange!.to)}',
                            style: STextStyle.titleLarge.style,
                          )
                        : null,
                    actions: intervalType != null
                        ? [
                            Text(
                              intervalType!.displayName,
                              style: STextStyle.titleLarge.style,
                            ),
                          ]
                        : null,
                    columnSpacing: 24.0,
                    showCheckboxColumn: false,
                    showFirstLastButtons: true,
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (_) => colorScheme.appBackground(context),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<List<String>> data;
  final bool isDark;

  _DataSource(this.context, this.data, this.isDark);

  late final _mappedData = [
    for (var i = 0; i < data.length; i++)
      DataRow(
        color: WidgetStateProperty.resolveWith(
          (_) => i % 2 == 0
              ? colorScheme.cardBackground(context)
              : colorScheme.appBackground(context),
        ),
        cells: [
          for (var e in data[i])
            DataCell(_DecoratedBox.data(text: e, isDark: isDark)),
        ],
      ),
  ];

  @override
  int get rowCount => _mappedData.length;

  @override
  DataRow? getRow(int index) {
    return _mappedData[index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _DecoratedBox extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Alignment alignment;

  _DecoratedBox.header({required this.text, required bool isDark})
    : textStyle = STextStyle.titleSmall.style.copyWith(color: colorScheme.grey),
      alignment = Alignment.bottomCenter;

  _DecoratedBox.data({required this.text, required bool isDark})
    : textStyle = STextStyle.titleMedium.style,
      alignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      height: 60.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SStyleText(
        text,
        textStyle: textStyle,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
