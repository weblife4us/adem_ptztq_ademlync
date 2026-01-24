import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_alarm.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
// import '../file_export/export_bloc.dart';
// import '../file_export/report.dart';
import 'check_alarm_page_bloc.dart';
import 'check_alarm_page_model.dart';

class CheckAlarmPage extends StatefulWidget {
  const CheckAlarmPage({super.key});

  @override
  State<CheckAlarmPage> createState() => _CheckAlarmPageState();
}

class _CheckAlarmPageState extends State<CheckAlarmPage> {
  late final _bloc = BlocProvider.of<CheckAlarmPageBloc>(context);

  CheckAlarmPageModel? _info;
  final _data = <List<String>>[];

  DateTime? get _pressTxdrMalfDateTime =>
      combineDateTime(_info!.pressMalfDate, _info!.pressMalfTime);
  DateTime? get _tempTxdrMalfDateTime =>
      combineDateTime(_info!.tempMalfDate, _info!.tempMalfTime);
  DateTime? get _batteryMalfDateTime =>
      combineDateTime(_info!.batteryMalfDate, _info!.batteryMalfTime);
  DateTime? get _memoryErrorDateTime =>
      combineDateTime(_info!.memoryErrorDate, _info!.memoryErrorTime);

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
        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar(
              text: 'Alarm',
              hasAdemInfoAction: _info != null,
              isLoading: _info == null,
              // TODO: TBC
              // actions: _info != null && AppModeManager().isDebugMode
              //     ? [ExportIcon(onPressed: _onExport)]
              //     : null,
            ),
            body: SmartBodyLayout(
              child: _info == null
                  ? const SLoading()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SCard(
                          child: SDecoration(
                            header: 'Alarm Output',
                            child: SText.titleMedium(
                              _info!.isAlarmOutput!
                                  ? 'Alarms Found'
                                  : 'No Alarms Found',
                              textAlign: TextAlign.end,
                              color: _info!.isAlarmOutput!
                                  ? colorScheme.accentGold(context)
                                  : colorScheme.connected(context),
                            ),
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            12.0,
                            24.0,
                            12.0,
                          ),
                          child: SAlarm(
                            text: 'Pressure',
                            high: _info!.pressHighLimit,
                            highParam: Param.pressHighLimit,
                            low: _info!.pressLowLimit,
                            lowParam: Param.pressLowLimit,
                            isMalfunctioned: _info!.isPressTxdrMalf,
                            malfDateTime: _pressTxdrMalfDateTime,
                            isHigh: _info!.isPressHigh,
                            isLow: _info!.isPressLow,
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            12.0,
                            24.0,
                            12.0,
                          ),
                          child: SAlarm(
                            text: 'Temperature',
                            high: _info!.tempHighLimit,
                            highParam: Param.tempHighLimit,
                            low: _info!.tempLowLimit,
                            lowParam: Param.tempLowLimit,
                            isMalfunctioned: _info!.isTempTxdrMalf,
                            malfDateTime: _tempTxdrMalfDateTime,
                            isHigh: _info!.isTempHigh,
                            isLow: _info!.isTempLow,
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            12.0,
                            24.0,
                            12.0,
                          ),
                          child: SAlarm(
                            text: 'Battery',
                            isMalfunctioned: _info!.isBatteryMalf,
                            malfDateTime: _batteryMalfDateTime,
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            12.0,
                            24.0,
                            12.0,
                          ),
                          child: SAlarm(
                            text: 'Memory',
                            isMalfunctioned: _info!.isMemoryError,
                            malfDateTime: _memoryErrorDateTime,
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            12.0,
                            24.0,
                            12.0,
                          ),
                          child: SAlarm(
                            text: 'Unc. Flow Rate',
                            high: _info!.uncFlowRateHighLimit,
                            highParam: Param.uncFlowRateHighLimit,
                            low: _info!.uncFlowRateLowLimit,
                            lowParam: Param.uncFlowRateLowLimit,
                            isHigh: _info!.isUncFlowRateHigh,
                            isLow: _info!.isUncFlowRateLow,
                          ),
                        ),
                        const Gap(24.0),
                        SCard(
                          child: SDecoration(
                            header: 'Unc. Volume Since Malf.',
                            child: SDataField.digit(
                              value: _info!.uncVolSinceMalf,
                              param: Param.uncVolSinceMalf,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() {
        _info = state.info;
        _mapReportData();
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }

  // void _onExport(void Function(ExportEvent) addEvent) {
  //   final dateTime = DateTime.now();

  //   addEvent(
  //     ReportExportEvent(
  //       exportFormat: AppDelegate().exportFmt,
  //       folderName: alarmsFoldername,
  //       symbol: 'ALARM',
  //       report: Report(
  //         title: 'Alarms',
  //         headers: _headers,
  //         records: _data,
  //         dateTime: dateTime,
  //       ),
  //       dateTime: dateTime,
  //     ),
  //   );
  // }

  void _mapReportData() {
    final data = [
      [locale.pressLowString, _info!.isPressLow],
      [locale.pressHighString, _info!.isPressHigh],
      [locale.pressMalfString, _info!.isPressTxdrMalf],
      [locale.tempLowString, _info!.isTempLow],
      [locale.tempHighString, _info!.isTempHigh],
      [locale.tempMalfString, _info!.isTempTxdrMalf],
      [locale.isUncFlowrateLowString, _info!.isUncFlowRateHigh],
      [locale.isUncFlowrateHighString, _info!.isUncFlowRateLow],
      [locale.batteryMalfString, _info!.isBatteryMalf],
      [locale.memoryErrorString, _info!.isMemoryError],
    ];

    _data.addAll(
      data.map((o) => [o[0] as String, o[1]?.toString() ?? noDataString]),
    );
  }
}

// const _headers = ['Param', 'Value'];
