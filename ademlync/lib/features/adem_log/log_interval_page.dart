import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../file_export/export_bloc.dart';
import '../file_export/export_icon.dart';
import 'interval_log_fields_model.dart';
import '../file_export/report.dart';
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
import 'log_interval_page_bloc.dart';

class LogIntervalPage extends StatefulWidget {
  final LogTimeRange? dateTimeRange;

  const LogIntervalPage({super.key, required this.dateTimeRange});

  @override
  State<LogIntervalPage> createState() => _LogIntervalPageState();
}

class _LogIntervalPageState extends State<LogIntervalPage> {
  late final _bloc = BlocProvider.of<LogIntervalPageBloc>(context);
  IntervalLogFields? get _fields => _bloc.fields;
  List<IntervalLog>? get _logs => _bloc.logs;
  int _fetchedLogCounts = 0;
  final _headers = <String>[];
  final _data = <List<String>>[];
  String? _filePath;

  Adem get _adem => AppDelegate().adem;

  bool _isShown(bool? hasSelected, [bool isParamAvailable = true]) {
    return isParamAvailable &&
        (_adem.isFFIntervalLog ||
            (_adem.isSFIntervalLog && (hasSelected ?? false)));
  }

  void _buildHeaders() {
    final params = _adem.intervalLogParams;
    final alarms = params.alarms;
    final volumeUnit = _adem.volumeType.displayName;
    final flowRateUnit = _adem.flowRateType.displayName;

    _headers.addAll([
      locale.logNoString,
      locale.dateString,
      locale.timeString,
      locale.incrementCorVolString.addUnit(volumeUnit),
      locale.incrementUncVolString.addUnit(volumeUnit),
      // NOTE: Use Max Press unit for Avg Press.
      if (params.hasAvgPress) locale.avgPressString.addUnitP(Param.maxPress),
      if (params.hasAvgTemp) locale.avgTempString.addUnitP(Param.temp),
      if (_isShown(_fields?.hasTotalCorVol, params.hasTotalCorVol))
        locale.totalCorVolString.addUnit(volumeUnit),
      if (_isShown(_fields?.hasTotalUncVol, params.hasTotalUncVol))
        locale.totalUncVolString.addUnit(volumeUnit),
      if (_isShown(_fields?.hasAvgBatteryVoltage)) locale.avgTotalFactorString,
      if (_isShown(_fields?.hasAvgUncFlowRate))
        locale.avgUncFlowrateString.addUnit(flowRateUnit),
      if (_isShown(_fields?.hasMaxPressTime, params.hasMaxPressTime))
        locale.maxPressTimeString,
      if (_isShown(_fields?.hasMaxPress, params.hasMaxPress))
        locale.maxPressString.addUnitP(Param.maxPress),
      if (_isShown(_fields?.hasMinPressTime, params.hasMinPressTime))
        locale.minPressTimeString,
      if (_isShown(_fields?.hasMinPress, params.hasMinPress))
        locale.minPressString.addUnitP(Param.minPress),
      if (_isShown(_fields?.hasMaxTempTime, params.hasMaxTempTime))
        locale.maxTempTimeString,
      if (_isShown(_fields?.hasMaxTemp, params.hasMaxTemp))
        locale.maxTempString.addUnitP(Param.maxTemp),
      if (_isShown(_fields?.hasMinTempTime, params.hasMinTempTime))
        locale.minTempTimeString,
      if (_isShown(_fields?.hasMinTemp, params.hasMinTemp))
        locale.minTempString.addUnitP(Param.minTemp),
      if (_isShown(
        _fields?.hasMaxUncFlowrateTime,
        params.hasMaxUncFlowrateTime,
      ))
        locale.maxUncFlowrateTimeString,
      if (_isShown(_fields?.hasMaxUncFlowrate, params.hasMaxUncFlowrate))
        locale.maxUncFlowrateString.addUnit(flowRateUnit),
      if (_isShown(
        _fields?.hasMinUncFlowrateTime,
        params.hasMinUncFlowrateTime,
      ))
        locale.minUncFlowrateTimeString,
      if (_isShown(_fields?.hasMinUncFlowrate, params.hasMinUncFlowrate))
        locale.minUncFlowrateString.addUnit(flowRateUnit),
      if (_isShown(_fields?.hasAvgBatteryVoltage))
        locale.avgBatteryVoltageString.addUnit('V'),
      locale.memoryErrorString,
      locale.flowrateHighString,
      locale.flowrateLowString,
      if (alarms.hasPressHigh) locale.pressHighString,
      if (alarms.hasPressLow) locale.pressLowString,
      if (alarms.hasTempHigh) locale.tempHighString,
      if (alarms.hasTempLow) locale.tempLowString,
      if (alarms.hasTmr1) 'TMR 1 Malf.',
      if (alarms.hasTmr2) 'TMR 2 Malf.',
      locale.batteryMalfString,
      if (alarms.hasPressMalf) locale.pressMalfString,
      if (alarms.hasTempMalf) locale.tempMalfString,
    ]);
  }

  void _buildData() {
    final params = _adem.intervalLogParams;
    final alarms = params.alarms;
    final volumeDecimal = _adem.volumeType.decimal;
    final flowRateDecimal = _adem.flowRateType.decimal;

    _data.addAll([
      for (var e in _logs!)
        [
          e.logNumber.padLeftZero(logNumberDigital),
          e.date != null ? DateTimeFmtManager.formatDate(e.date!) : 'N/A',
          e.time != null ? DateTimeFmtManager.formatTimestamp(e.time!) : 'N/A',
          e.corIncrementVol.toStringAsFixed(volumeDecimal),
          e.uncIncrementVol.toStringAsFixed(volumeDecimal),
          // NOTE: Use Max Press decimal for Avg Press.
          if (params.hasAvgPress) e.avgPress?.toStr(Param.maxPress) ?? 'N/A',
          if (params.hasAvgTemp) e.avgTemp?.toStr(Param.temp) ?? 'N/A',
          if (_isShown(_fields?.hasTotalCorVol, params.hasTotalCorVol))
            e.corTotalVol?.toStringAsFixed(volumeDecimal) ?? 'N/A',
          if (_isShown(_fields?.hasTotalUncVol, params.hasTotalUncVol))
            e.uncTotalVol?.toStringAsFixed(volumeDecimal) ?? 'N/A',
          if (_isShown(_fields?.hasAvgBatteryVoltage))
            e.avgTotalFactor?.toStringAsFixed(factorDecimal) ?? 'N/A',
          if (_isShown(_fields?.hasAvgUncFlowRate))
            e.uncAvgFlowRate?.toStringAsFixed(flowRateDecimal) ?? 'N/A',
          if (_isShown(_fields?.hasMaxPressTime, params.hasMaxPressTime))
            e.maxPressTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.maxPressTime!),
          if (_isShown(_fields?.hasMaxPress, params.hasMaxPress))
            e.maxPress?.toStr(Param.maxPress) ?? 'N/A',
          if (_isShown(_fields?.hasMinPressTime, params.hasMinPressTime))
            e.minPressTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.minPressTime!),
          if (_isShown(_fields?.hasMinPress, params.hasMinPress))
            e.minPress?.toStr(Param.minPress) ?? 'N/A',
          if (_isShown(_fields?.hasMaxTempTime, params.hasMaxTempTime))
            e.maxTempTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.maxTempTime!),
          if (_isShown(_fields?.hasMaxTemp, params.hasMaxTemp))
            e.maxTemp?.toStr(Param.maxTemp) ?? 'N/A',
          if (_isShown(_fields?.hasMinTempTime, params.hasMinTempTime))
            e.minTempTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.minTempTime!),
          if (_isShown(_fields?.hasMinTemp, params.hasMinTemp))
            e.minTemp?.toStr(Param.minTemp) ?? 'N/A',
          if (_isShown(
            _fields?.hasMaxUncFlowrateTime,
            params.hasMaxUncFlowrateTime,
          ))
            e.uncMaxFlowRateTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.uncMaxFlowRateTime!),
          if (_isShown(_fields?.hasMaxUncFlowrate, params.hasMaxUncFlowrate))
            e.uncMaxFlowRate?.toStringAsFixed(flowRateDecimal) ?? 'N/A',
          if (_isShown(
            _fields?.hasMinUncFlowrateTime,
            params.hasMinUncFlowrateTime,
          ))
            e.uncMinFlowRateTime == null
                ? 'N/A'
                : DateTimeFmtManager.formatTime(e.uncMinFlowRateTime!),
          if (_isShown(_fields?.hasMinUncFlowrate, params.hasMinUncFlowrate))
            e.uncMinFlowRate?.toStringAsFixed(flowRateDecimal) ?? 'N/A',
          if (_isShown(_fields?.hasAvgBatteryVoltage))
            e.avgBatteryVoltage.toStr(Param.batteryVoltage) ?? 'N/A',
          e.alarms.isMemoryError.asString,
          e.alarms.isFlowrateHigh.asString,
          e.alarms.isFlowrateLow.asString,
          if (alarms.hasPressHigh) e.alarms.isPressHigh?.asString ?? 'N/A',
          if (alarms.hasPressLow) e.alarms.isPressLow?.asString ?? 'N/A',
          if (alarms.hasTempHigh) e.alarms.isTempHigh?.asString ?? 'N/A',
          if (alarms.hasTempLow) e.alarms.isTempLow?.asString ?? 'N/A',
          if (alarms.hasTmr1) e.alarms.isTmr1Malf?.asString ?? 'N/A',
          if (alarms.hasTmr2) e.alarms.isTmr2Malf?.asString ?? 'N/A',
          e.alarms.isBatteryMalf.asString,
          if (alarms.hasPressMalf) e.alarms.isPressMalf?.asString ?? 'N/A',
          if (alarms.hasTempMalf) e.alarms.isTempMalf?.asString ?? 'N/A',
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
              text: locale.intervalLogsString,
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
                              'fileType': LogType.interval.toCloudFileType,
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
                              folderName: LogType.interval.folderName,
                              symbol: 'INTERVAL',
                              report: Report.fromLog(
                                type: LogType.interval,
                                headers: _headers,
                                records: _data,
                                dateTimeRange: widget.dateTimeRange,
                                intervalType: _adem.measureCache.intervalType,
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
                ? _logs!.isNotEmpty
                      ? SLogTable(
                          intervalType: _adem.measureCache.intervalType,
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
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }
}

extension _DoubleExt on double? {
  String? toStr(Param param) =>
      this?.toStringAsFixed(param.decimal(AppDelegate().adem));
}
