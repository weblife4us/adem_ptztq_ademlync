import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/digital_data_with_datetime.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_reset.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'check_statistic_page_bloc.dart';
import 'check_statistic_page_model.dart';

class CheckStatisticPage extends StatefulWidget {
  const CheckStatisticPage({super.key});

  @override
  State<CheckStatisticPage> createState() => _CheckStatisticPageState();
}

class _CheckStatisticPageState extends State<CheckStatisticPage> {
  late final _bloc = BlocProvider.of<CheckStatisticPageBloc>(context);

  CheckStatisticPageModel? _info;

  DateTime? get _maxPressDateTime =>
      combineDateTime(_info!.maxPressDate, _info!.maxPressTime);
  DateTime? get _minPressDateTime =>
      combineDateTime(_info!.minPressDate, _info!.minPressTime);
  DateTime? get _maxTempDateTime =>
      combineDateTime(_info!.maxTempDate, _info!.maxTempTime);
  DateTime? get _minTempDateTime =>
      combineDateTime(_info!.minTempDate, _info!.minTempTime);
  DateTime? get _uncPeakFlowRateDateTime =>
      combineDateTime(_info!.uncPeakFlowRateDate, _info!.uncPeakFlowRateTime);
  DateTime? get _lastSaveDateTime =>
      combineDateTime(_info!.lastSaveDate, _info!.lastSaveTime);

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchData());
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
              text: 'Statistic',
              hasAdemInfoAction: _info != null,
              isLoading: _info == null,
            ),
            body: SmartBodyLayout(
              child: _info == null
                  ? const SLoading()
                  : Column(
                      spacing: 24.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SCard(
                          child: SDecoration(
                            header: 'Gas Pressure',
                            spacing: 24.0,
                            child: Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.maxPress,
                                      value: _info!.maxPress,
                                      prefix: 'Max',
                                      dateTime: _maxPressDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _maxPressDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.minPress,
                                      value: _info!.minPress,
                                      prefix: 'Min',
                                      dateTime: _minPressDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _minPressDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Gas Temperature',
                            spacing: 24.0,
                            child: Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.maxTemp,
                                      value: _info!.maxTemp,
                                      prefix: 'Max',
                                      dateTime: _maxTempDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _maxTempDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.minTemp,
                                      value: _info!.minTemp,
                                      prefix: 'Min',
                                      dateTime: _minTempDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _minTempDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Case Temperature',
                            spacing: 24.0,
                            child: Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.maxCaseTemp,
                                      value: _info!.maxCaseTemp,
                                      prefix: 'Max',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.minCaseTemp,
                                      value: _info!.minCaseTemp,
                                      prefix: 'Min',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Peak Unc. Flow Rate',
                            spacing: 24.0,
                            child: SReset(
                              child: DigitDataWithDateTime(
                                param: Param.uncPeakFlowRate,
                                value: _info!.maxCaseTemp,
                                dateTime: _uncPeakFlowRateDateTime == null
                                    ? null
                                    : DateTimeFmtManager.formatDateTime(
                                        _uncPeakFlowRateDateTime!,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Index Rollover',
                            spacing: 24.0,
                            child: Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Corrected',
                                    child: SDataField.string(
                                      value: _info!.correctedIndexRollover
                                          ?.toString(),
                                      param: Param.correctedIndexRollover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Uncorrected',
                                    child: SDataField.string(
                                      value: _info!.uncorrectedIndexRollover
                                          ?.toString(),
                                      param: Param.uncorrectedIndexRollover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Last Saved Volume',
                            spacing: 24.0,
                            child: Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.corLastSavedVol,
                                      value: _info!.corLastSavedVol,
                                      prefix: 'Cor.',
                                      dateTime: _lastSaveDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _lastSaveDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SReset(
                                    child: DigitDataWithDateTime(
                                      param: Param.uncLastSavedVol,
                                      value: _info!.uncLastSavedVol,
                                      prefix: 'Unc.',
                                      dateTime: _lastSaveDateTime == null
                                          ? null
                                          : DateTimeFmtManager.formatDateTime(
                                              _lastSaveDateTime!,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SCard(
                          child: Row(
                            spacing: 24.0,
                            children: [
                              if (_info!.showDot case final showDot?)
                                Expanded(
                                  child: SDecoration(
                                    header: 'Show DOT',
                                    child: SDataField.string(
                                      value: showDot ? 'Enabled' : 'Disabled',
                                      param: Param.showDot,
                                    ),
                                  ),
                                ),

                              Expanded(
                                child: SDecoration(
                                  header: 'Backup Counter',
                                  child: SDataField.digit(
                                    value: _info!.backupIndexCounter,
                                    param: Param.backupIndexCounter,
                                  ),
                                ),
                              ),
                            ],
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
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }
}
