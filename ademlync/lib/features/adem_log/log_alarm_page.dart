import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
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
import '../file_export/export_bloc.dart';
import '../file_export/export_icon.dart';
import '../file_export/report.dart';
import 'log_alarm_page_bloc.dart';

class LogAlarmPage extends StatefulWidget {
  final LogTimeRange? dateTimeRange;

  const LogAlarmPage({super.key, required this.dateTimeRange});

  @override
  State<LogAlarmPage> createState() => _LogAlarmPageState();
}

class _LogAlarmPageState extends State<LogAlarmPage> {
  late final _bloc = BlocProvider.of<LogAlarmPageBloc>(context);
  final List<AlarmLog> _logs = [];
  int _fetchedLogCounts = 0;
  final _data = <List<String>>[];
  String? _filePath;

  void _buildData() {
    final adem = AppDelegate().adem;

    _data.addAll([
      for (final o in _logs)
        [
          o.logNumber.padLeftZero(logNumberDigital),
          o.date != null ? DateTimeFmtManager.formatDate(o.date!) : 'N/A',
          o.time != null ? DateTimeFmtManager.formatTimestamp(o.time!) : 'N/A',
          o.type.displayName,
          o.param?.displayName ?? '-',
          _mapValue(o.value, o.param, adem),
          _mapValue(o.limit, o.param, adem),
          o.param?.unit(adem) ?? '-',
        ],
    ]);
  }

  String _mapValue(String value, Param? param, Adem adem) {
    final manager = ParamFormatManager();

    switch (param) {
      case Param.isUncIndexRolledOver:
      case Param.isCorIndexRolledOver:
        return manager.decodeToDisplayValue(param!, value, adem) ?? value;
      default:
        final decimal = param?.decimal(adem) ?? 0;
        final res = num.tryParse(value)?.toStringAsFixed(decimal);
        return res ?? value;
    }
  }

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData(widget.dateTimeRange));
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
              text: locale.alarmLogsString,
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
                              'fileType': LogType.alarm.toCloudFileType,
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
                              folderName: LogType.alarm.folderName,
                              symbol: 'ALARM',
                              report: Report.fromLog(
                                type: LogType.alarm,
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
      setState(_buildData);
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

List<String> _headers = [
  locale.logNoString,
  locale.dateString,
  locale.timeString,
  locale.typeString,
  locale.parameterString,
  locale.valueString,
  locale.limitString,
  locale.unitString,
];
