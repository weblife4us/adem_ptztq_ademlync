import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/digital_data_with_datetime.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_reset.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_statistic_page_bloc.dart';
import 'setup_statistics_page_model.dart';

class SetupStatisticPage extends StatefulWidget {
  const SetupStatisticPage({super.key});

  @override
  State<SetupStatisticPage> createState() => _SetupStatisticPageState();
}

class _SetupStatisticPageState extends State<SetupStatisticPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupStatisticPageBloc>(context);
  final _formKey = GlobalKey<FormState>();

  SetupStatisticsPageModel? _info;
  final _pressTxdrSnTEController = TextEditingController();

  void _updateData(DataReady state) {
    _info = state.info;

    if (_info?.backupIdxCtr != null) {
      _pressTxdrSnTEController.text = dataToString(
        _info!.backupIdxCtr!.value,
        Param.backupIndexCounter,
      );
    }
  }

  Future<void> submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final accessCode = await getAccessCode(context);
      if (accessCode != null) {
        _bloc.add(UpdateData(accessCode, _info!));
      }
    } else {
      await showDialog(
        context: context,
        builder: (_) => const ConfigurationAlertDialog(),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData());
  }

  @override
  void dispose() {
    _pressTxdrSnTEController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isDataReady = _info != null;
        final isLoading =
            state is DataUpdating ||
            state is DataUpdated ||
            state is DataFetching;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar.withSubmit(
              context,
              text: 'Statistic',
              hasAdemInfoAction: isDataReady,
              isLoading: _info == null,
              isSubmitLoading: isDataReady && isLoading,
              onPressed: isDataReady ? submitForm : null,
            ),
            body: SmartBodyLayout(
              child: isDataReady
                  ? Form(
                      key: _formKey,
                      child: Column(
                        spacing: 24.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_info!.maxGasPress != null ||
                              _info!.minGasPress != null)
                            SCard(
                              child: SDecoration(
                                header: 'Gas Pressure',
                                spacing: 24.0,
                                child: Row(
                                  spacing: 24.0,
                                  children: [
                                    if (_info!.maxGasPress != null)
                                      Expanded(
                                        child: SReset(
                                          isActive:
                                              _info!.maxGasPress?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.maxGasPress?.isEdited ??
                                                      false
                                                  ? _info!.maxGasPress?.reset()
                                                  : _info!.maxGasPress?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.maxPress,
                                            value: _info!.maxGasPress?.value,
                                            prefix: 'Max',
                                            dateTime:
                                                _info!.maxPressDateTime == null
                                                ? null
                                                : DateTimeFmtManager.formatDateTime(
                                                    _info!.maxPressDateTime!,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    if (_info!.minGasPress != null)
                                      Expanded(
                                        child: SReset(
                                          isActive:
                                              _info!.minGasPress?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.minGasPress?.isEdited ??
                                                      false
                                                  ? _info!.minGasPress?.reset()
                                                  : _info!.minGasPress?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.minPress,
                                            value: _info!.minGasPress?.value,
                                            prefix: 'Min',
                                            dateTime:
                                                _info!.minPressDateTime == null
                                                ? null
                                                : DateTimeFmtManager.formatDateTime(
                                                    _info!.minPressDateTime!,
                                                  ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (_info!.maxGasTemp != null ||
                              _info!.minGasTemp != null)
                            SCard(
                              child: SDecoration(
                                header: 'Gas Temperature',
                                spacing: 24.0,
                                child: Row(
                                  spacing: 24.0,
                                  children: [
                                    if (_info!.maxGasTemp != null)
                                      Expanded(
                                        child: SReset(
                                          isActive: _info!.maxGasTemp?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.maxGasTemp?.isEdited ??
                                                      false
                                                  ? _info!.maxGasTemp?.reset()
                                                  : _info!.maxGasTemp?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.maxTemp,
                                            value: _info!.maxGasTemp?.value,
                                            prefix: 'Max',
                                            dateTime:
                                                _info!.maxTempDateTime == null
                                                ? null
                                                : DateTimeFmtManager.formatDateTime(
                                                    _info!.maxTempDateTime!,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    if (_info!.minGasTemp != null)
                                      Expanded(
                                        child: SReset(
                                          isActive: _info!.minGasTemp?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.minGasTemp?.isEdited ??
                                                      false
                                                  ? _info!.minGasTemp?.reset()
                                                  : _info!.minGasTemp?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.minTemp,
                                            value: _info!.minGasTemp?.value,
                                            prefix: 'Min',
                                            dateTime:
                                                _info!.minTempDateTime == null
                                                ? null
                                                : DateTimeFmtManager.formatDateTime(
                                                    _info!.minTempDateTime!,
                                                  ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (_info!.maxCaseTemp != null ||
                              _info!.minCaseTemp != null)
                            SCard(
                              child: SDecoration(
                                header: 'Case Temperature',
                                spacing: 24.0,
                                child: Row(
                                  spacing: 24.0,
                                  children: [
                                    if (_info!.maxCaseTemp != null)
                                      Expanded(
                                        child: SReset(
                                          isActive:
                                              _info!.maxCaseTemp?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.maxCaseTemp?.isEdited ??
                                                      false
                                                  ? _info!.maxCaseTemp?.reset()
                                                  : _info!.maxCaseTemp?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.maxCaseTemp,
                                            value: _info!.maxCaseTemp?.value,
                                            prefix: 'Max',
                                          ),
                                        ),
                                      ),
                                    if (_info!.minCaseTemp != null)
                                      Expanded(
                                        child: SReset(
                                          isActive:
                                              _info!.minCaseTemp?.isEdited,
                                          isDisable: isLoading,
                                          onPressed: (_) {
                                            setState(() {
                                              _info!.minCaseTemp?.isEdited ??
                                                      false
                                                  ? _info!.minCaseTemp?.reset()
                                                  : _info!.minCaseTemp?.value =
                                                        0;
                                            });
                                          },
                                          child: DigitDataWithDateTime(
                                            param: Param.minCaseTemp,
                                            value: _info!.minCaseTemp?.value,
                                            prefix: 'Min',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (_info!.peakUncFlowRate != null)
                            SCard(
                              child: SDecoration(
                                header: 'Peak Unc. Flow Rate',
                                spacing: 24.0,
                                child: SReset(
                                  isActive: _info!.peakUncFlowRate?.isEdited,
                                  isDisable: isLoading,
                                  onPressed: (_) {
                                    setState(() {
                                      _info!.peakUncFlowRate?.isEdited ?? false
                                          ? _info!.peakUncFlowRate?.reset()
                                          : _info!.peakUncFlowRate?.value = 0;
                                    });
                                  },
                                  child: DigitDataWithDateTime(
                                    param: Param.uncPeakFlowRate,
                                    value: _info!.peakUncFlowRate?.value,
                                    dateTime:
                                        _info!.peakUncFlowrateDateTime == null
                                        ? null
                                        : DateTimeFmtManager.formatDateTime(
                                            _info!.peakUncFlowrateDateTime!,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          if (_info!.provingVol != null)
                            SCard(
                              child: SDecoration(
                                header: 'Proving Volume',
                                child: SReset(
                                  isActive: _info!.provingVol?.isEdited,
                                  isDisable: isLoading,
                                  onPressed: (_) {
                                    setState(() {
                                      _info!.provingVol?.isEdited ?? false
                                          ? _info!.provingVol?.reset()
                                          : _info!.provingVol?.value = 0;
                                    });
                                  },
                                  child: DigitDataWithDateTime(
                                    param: Param.provingVol,
                                    value: _info!.provingVol?.value,
                                  ),
                                ),
                              ),
                            ),
                          if (_info!.backupIdxCtr != null ||
                              _info!.isDotShowed != null)
                            SCard(
                              child: Column(
                                children: [
                                  if (_info!.isDotShowed
                                      case final isDotShowed?)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SText.bodyMedium('Show DOT'),

                                        Opacity(
                                          opacity: isLoading ? 0.5 : 1.0,
                                          child: Switch(
                                            value: isDotShowed.value,
                                            onChanged: !isLoading
                                                ? (_) => setState(
                                                    () =>
                                                        _info!
                                                                .isDotShowed!
                                                                .value =
                                                            !isDotShowed.value,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),

                                  if (_info!.backupIdxCtr != null)
                                    SDecoration(
                                      header: 'Backup Counter',
                                      child: SDataField.digitEdit(
                                        controller: _pressTxdrSnTEController,
                                        param: Param.backupIndexCounter,
                                        isEnabled: !isLoading,
                                        isEdited: _info!.backupIdxCtr!.isEdited,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() {
                                              _info!.backupIdxCtr!.value = v
                                                  .toInt();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SLoading(),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() => _updateData(state));
    } else if (state is DataUpdated) {
      showToast(context, text: 'Update succeeded.');
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    } else if (state is UpdateDataFailed) {
      await handleError(context, state.error);
    }
  }
}
