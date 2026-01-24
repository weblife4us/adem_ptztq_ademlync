import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/controllers/date_time_fmt_manager.dart';
import '../file_export/export_bloc.dart';
import '../file_export/export_icon.dart';
import '../file_export/report.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/logs_loading_view.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_data_table.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'log_event_page_bloc.dart';

class LogEventPage extends StatefulWidget {
  final String? accessCode;
  final LogTimeRange? dateTimeRange;

  const LogEventPage({
    super.key,
    required this.accessCode,
    required this.dateTimeRange,
  });

  @override
  State<LogEventPage> createState() => _LogEventPageState();
}

class _LogEventPageState extends State<LogEventPage> {
  late final _bloc = BlocProvider.of<LogEventPageBloc>(context);
  late final _accessCode = widget.accessCode;
  late final _dateTimeRange = widget.dateTimeRange;

  final List<EventLog> _logs = [];
  int _fetchedLogCounts = 0;
  final _data = <List<String>>[];
  String? _filePath;

  void _buildData() {
    _data.addAll([
      for (var e in _logs)
        [
          e.itemName == null ? e.logNumber.padLeftZero(5) : 'N/A',
          e.itemName == null && e.date != null
              ? DateTimeFmtManager.formatDate(e.date!)
              : 'N/A',
          e.itemName == null && e.time != null
              ? DateTimeFmtManager.formatTimestamp(e.time!)
              : 'N/A',
          e.itemName == null ? e.logType.displayName : 'N/A',
          e.itemName == null ? e.userId.padLeftZero(3) : 'N/A',
          e.itemName ??
              (e.param?.key == 845
                  // SKYL-609
                  ? '1 Point Pressure Calibration'
                  : e.param?.displayName) ??
              'N/A',
          e.oldValue,
          e.newValue,
          e.unit,
        ],
    ]);
  }

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData(_accessCode, _dateTimeRange));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isDataReady = state is DataReady || _showWithError;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar(
              text: locale.eventLogsString,
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
                              'fileType': LogType.event.toCloudFileType,
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
                              folderName: LogType.event.folderName,
                              symbol: 'EVENT',
                              report: Report.fromLog(
                                type: LogType.event,
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

  // NOTE: SKYL-598
  bool _showWithError = false;

  void _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(_buildData);
    } else if (state is LogFetched) {
      setState(() {
        _fetchedLogCounts++;
        _logs.addAll(state.logs);
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);

      if (state.error case AdemCommError e
          when e.type == AdemCommErrorType.trashBytes) {
        setState(() {
          _buildData();
          _showWithError = true;
        });
      } else {
        if (context.mounted && context.canPop()) context.pop();
      }
    }
  }
}

List<String> _headers = [
  locale.logNoString,
  locale.dateString,
  locale.timeString,
  locale.typeString,
  locale.userIdString,
  locale.parameterString,
  locale.oldValueString,
  locale.newValueString,
  locale.unitString,
];
