import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../file_export/export_bloc.dart';
import '../file_export/export_icon.dart';
import '../file_export/report.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/logs_loading_view.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_data_table.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'log_q_page_bloc.dart';

class LogQPage extends StatefulWidget {
  const LogQPage({super.key});

  @override
  State<LogQPage> createState() => _LogQPageState();
}

class _LogQPageState extends State<LogQPage> {
  late final _bloc = BlocProvider.of<LogQPageBloc>(context);
  final List<QLog> _logs = [];
  int _fetchedLogCounts = 0;
  final _headers = <String>[];
  final _data = <List<String>>[];
  String? _filePath;

  String get unit => AppDelegate().adem.flowRateType.displayName;

  void _buildHeaders() {
    _headers.addAll([
      locale.logNoString,
      locale.dateString,
      locale.statusString,
      locale.flowrateString.addUnit(unit),
      locale.qMarginPercentString,
      locale.qMarginString.addUnit(unit),
      locale.maxQMarginString.addUnit(unit),
    ]);
  }

  void _buildData() {
    _data.addAll([
      for (var e in _logs)
        [
          e.logNumber.padLeftZero(logNumberDigital),
          e.date != null ? DateTimeFmtManager.formatMonthYear(e.date!) : 'N/A',
          e.qStatus.displayName,
          e.flowRate?.toString() ?? 'N/A',
          e.qMarginPercent?.toString() ?? 'N/A',
          e.qMargin?.toString() ?? 'N/A',
          e.maxQMargin?.toString() ?? 'N/A',
        ],
    ]);
  }

  @override
  void initState() {
    _bloc.add(FetchData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isDataReady = state is DataReady;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar(
              text: locale.qLogsString,
              hasAdemInfoAction: isDataReady,
              isLoading: !isDataReady,
              actions: isDataReady
                  ? [
                      if (_filePath case final path?)
                        SButton.text(
                          text: 'Upload',
                          minimumSize: Size.zero,
                          foregroundColor: colorScheme.white(context),
                          onPressed: () => context.push(
                            '/cloud/upload/file',
                            extra: {
                              'fileType': LogType.q.toCloudFileType,
                              'filePath': path,
                            },
                          ),
                        ),
                      ExportIcon(
                        onPressed: (addEvent) {
                          final dateTime = DateTime.now();

                          addEvent(
                            ReportExportEvent(
                              exportFormat: AppDelegate().exportFmt,
                              folderName: LogType.q.folderName,
                              symbol: 'QLOG',
                              report: Report.fromLog(
                                type: LogType.q,
                                headers: _headers,
                                records: _data,
                                dateTime: dateTime,
                              ),
                              dateTime: dateTime,
                            ),
                          );
                        },
                        onSaved: (path, _) => setState(() => _filePath = path),
                      ),
                    ]
                  : null,
            ),
            body: isDataReady
                ? _logs.isNotEmpty
                      ? SLogTable(headers: _headers, data: _data)
                      : SmartBodyLayout(
                          child: SText.titleMedium(locale.noLogDescription),
                        )
                : LogsLoadingView(
                    logCounts: _fetchedLogCounts,
                    onCanceled: () => _bloc.cancelCommunication(),
                  ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() {
        _buildHeaders();
        _buildData();
      });
    } else if (state is LogFetched) {
      setState(() {
        _fetchedLogCounts++;
        _logs.add(state.log);
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }
}
