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
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/logs_loading_view.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_data_table.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'log_daily_page_bloc.dart';

class LogDailyPage extends StatefulWidget {
  final LogTimeRange? dateTimeRange;

  const LogDailyPage({super.key, required this.dateTimeRange});

  @override
  State<LogDailyPage> createState() => _LogDailyPageState();
}

class _LogDailyPageState extends State<LogDailyPage> {
  late final _bloc = BlocProvider.of<LogDailyPageBloc>(context);
  late final _params = _adem.dailyLogParams;
  final List<DailyLog> _logs = [];
  int _fetchedLogCounts = 0;
  final _headers = <String>[];
  final _data = <List<String>>[];
  String? _filePath;

  Adem get _adem => AppDelegate().adem;

  bool get _isSuperAdmin => AppDelegate().user?.isSuperAdmin ?? false;

  void _buildHeaders() {
    _headers.addAll([
      locale.logNoString,
      locale.dateString,
      locale.timeString,
      Param.corDailyVol.displayName.addUnit(Param.corDailyVol.unit(_adem)!),
      Param.uncDailyVol.displayName.addUnit(Param.uncDailyVol.unit(_adem)!),
      if (_params.hasAvgPress)
        // NOTE: Use Max Press unit for Avg Press.
        locale.avgPressString.addUnit(Param.maxPress.unit(_adem)!),
      if (_params.hasAvgTemp)
        locale.avgTempString.addUnit(Param.temp.unit(_adem)!),
      locale.avgTotalFactorString,
      locale.avgUncFlowrateString.addUnit(Param.uncFlowRate.unit(_adem)!),
      locale.avgCorFlowrateString.addUnit(Param.corFlowRate.unit(_adem)!),
      locale.avgBatteryVoltageString.addUnit(Param.batteryVoltage.unit(_adem)!),
      if (_params.hasQMargin)
        locale.qMarginString.addUnit(_adem.volumeType.displayName),
      if (_params.hasMaxFlowrate && _isSuperAdmin)
        locale.maxFlowrateString.addUnit('%'),
      if (_params.hasDp && _isSuperAdmin)
        locale.diffPressString.addUnit(Param.diffPress.unit(_adem)!),
    ]);
  }

  void _buildData() {
    _data.addAll([
      for (var e in _logs)
        [
          e.logNumber.padLeftZero(logNumberDigital),
          e.date != null ? DateTimeFmtManager.formatDate(e.date!) : 'N/A',
          e.time != null ? DateTimeFmtManager.formatTimestamp(e.time!) : 'N/A',
          e.corDailyVol.toStringAsFixed(Param.corDailyVol.decimal(_adem)),
          e.uncDailyVol.toStringAsFixed(Param.uncDailyVol.decimal(_adem)),
          if (_params.hasAvgPress)
            // NOTE: Use Max Press decimal for Avg Press.
            e.avgPress?.toStringAsFixed(Param.maxPress.decimal(_adem)) ?? 'N/A',
          if (_params.hasAvgTemp)
            e.avgTemp?.toStringAsFixed(Param.temp.decimal(_adem)) ?? 'N/A',
          e.avgTotalFactor.toStringAsFixed(factorDecimal),
          e.avgUncFlow.toStringAsFixed(_adem.flowRateType.decimal),
          e.avgCorFlow.toStringAsFixed(_adem.flowRateType.decimal),
          e.avgBatteryVoltage.toStringAsFixed(
            Param.batteryVoltage.decimal(_adem),
          ),
          if (_params.hasQMargin)
            e.qMargin?.toStringAsFixed(_adem.volumeType.decimal) ?? 'N/A',
          if (_params.hasMaxFlowrate && _isSuperAdmin)
            e.percentageOfMaxFlowRate?.toStringAsFixed(percentDecimal) ?? 'N/A',
          if (_params.hasDp && _isSuperAdmin)
            (double.tryParse(
                  e.diffPress ?? '',
                )?.toStringAsFixed(Param.diffPress.decimal(_adem))) ??
                e.diffPress ??
                'N/A',
        ],
    ]);
  }

  @override
  void initState() {
    _bloc.add(FetchData(widget.dateTimeRange));
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
              text: locale.dailyLogsString,
              hasAdemInfoAction: isDataReady,
              isLoading: !isDataReady,
              actions: isDataReady
                  ? [
                      if (_filePath case final path?)
                        SButton.text(
                          text: 'Upload',
                          foregroundColor: colorScheme.white(context),
                          minimumSize: Size.zero,
                          onPressed: () => context.push(
                            '/cloud/upload/file',
                            extra: {
                              'fileType': LogType.daily.toCloudFileType,
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
                              folderName: LogType.daily.folderName,
                              symbol: 'DAILY',
                              report: Report.fromLog(
                                type: LogType.daily,
                                headers: _headers,
                                records: _data,
                                dateTimeRange: widget.dateTimeRange,
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
                      ? SLogTable(
                          headers: _headers,
                          data: _data,
                          dateTimeRange: widget.dateTimeRange,
                        )
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
