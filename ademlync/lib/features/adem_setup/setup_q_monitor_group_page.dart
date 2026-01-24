import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_q_monitor_group_page_bloc.dart';
import 'setup_q_monitor_group_page_model.dart';

class SetupQMonitorGroupPage extends StatefulWidget {
  const SetupQMonitorGroupPage({super.key});

  @override
  State<SetupQMonitorGroupPage> createState() => _SetupQMonitorGroupPageState();
}

class _SetupQMonitorGroupPageState extends State<SetupQMonitorGroupPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupQMonitorGroupPageBloc>(context);
  final _formKey = GlobalKey<FormState>();
  final _adem = AppDelegate().adem;

  SetupQMonitorGroupPageModel? _info;
  final _lineGaugePressTEController = TextEditingController();
  final _atmosphericPressTEController = TextEditingController();
  final _gasSpecificGravityTEController = TextEditingController();
  final _qCutoffTempHighTEController = TextEditingController();
  final _qCutoffTempLowTEController = TextEditingController();
  final _diffUncertaintyTEController = TextEditingController();

  DateTime? get _dpTxdrMalfDateTime =>
      combineDateTime(_info!.dpTxdrMalfDate, _info!.dpTxdrMalfTime);

  void _updateData(SQMGPBReadyState state) {
    _info = state.info;

    if (_info?.lineGaugePress != null) {
      _lineGaugePressTEController.text = dataToString(
        _info!.lineGaugePress!.value,
        Param.lineGaugePress,
      );
    }
    if (_info?.atmosphericPress != null) {
      _atmosphericPressTEController.text = dataToString(
        _info!.atmosphericPress!.value,
        Param.atmosphericPress,
      );
    }
    if (_info?.gasSpecificGravity != null) {
      _gasSpecificGravityTEController.text = dataToString(
        _info!.gasSpecificGravity!.value,
        Param.gasSpecificGravity,
      );
    }
    if (_info?.qCutoffTempHigh != null) {
      _qCutoffTempHighTEController.text = dataToString(
        _info!.qCutoffTempHigh!.value,
        Param.qCutoffTempHigh,
      );
    }
    if (_info?.qCutoffTempLow != null) {
      _qCutoffTempLowTEController.text = dataToString(
        _info!.qCutoffTempLow!.value,
        Param.qCutoffTempLow,
      );
    }
    if (_info?.diffUncertainty != null) {
      _diffUncertaintyTEController.text = dataToString(
        _info!.diffUncertainty!.value,
        Param.diffUncertainty,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _bloc.add(SQMGPBFetchEvent());
  }

  @override
  void dispose() {
    _lineGaugePressTEController.dispose();
    _atmosphericPressTEController.dispose();
    _gasSpecificGravityTEController.dispose();
    _qCutoffTempHighTEController.dispose();
    _qCutoffTempLowTEController.dispose();
    _diffUncertaintyTEController.dispose();

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
            state is SQMGPBUpdatingState ||
            state is SQMGPBUpdatedState ||
            state is SQMGPBFetchingState;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: GestureDetector(
            onTap: dismissKeyboard,
            child: Scaffold(
              appBar: SAppBar.withSubmit(
                context,
                text: locale.qMonitorGroupString,
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
                            if (_info!.qMonitorFunction != null)
                              SCard(
                                child: SDecoration(
                                  header: 'Q Monitor Function',
                                  child: SDataField.string(
                                    value: _info!.qMonitorFunction!
                                        ? 'Enabled'
                                        : 'Disabled',
                                  ),
                                ),
                              ),
                            SCard(
                              child: Column(
                                spacing: 24.0,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_info!.diffPress != null)
                                    SDecoration(
                                      header: 'Differential Pressure',
                                      child: SDataField.digit(
                                        value: _info!.diffPress,
                                        param: Param.diffPress,
                                      ),
                                    ),
                                  if (_info!.dpTxdrMalfDate != null ||
                                      _info!.isDpTxdrMalf != null ||
                                      _info!.dpTestPressure != null)
                                    Row(
                                      spacing: 24.0,
                                      children: [
                                        if (_info!.dpTxdrMalfDate != null ||
                                            _info!.isDpTxdrMalf != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Trans. Malf.',
                                              child:
                                                  _info?.isDpTxdrMalf == true &&
                                                      _dpTxdrMalfDateTime !=
                                                          null
                                                  ? SDataField.dateTime(
                                                      param:
                                                          Param.dpTxdrMalfDate,
                                                      value: _info!
                                                          .dpTxdrMalfDate!,
                                                    )
                                                  : SDataField.alarm(
                                                      param: Param.isDpTxdrMalf,
                                                      value:
                                                          _info!.isDpTxdrMalf!,
                                                    ),
                                            ),
                                          ),
                                        if (_info!.dpTestPressure != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Test Pressure',
                                              child: SDataField.digit(
                                                value: _info!.dpTestPressure!,
                                                param: Param.dpTestPressure,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  if (_info!.dpSensorSn != null ||
                                      _info!.dpSensorRange != null)
                                    Row(
                                      spacing: 24.0,
                                      children: [
                                        if (_info!.dpSensorSn != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Sensor S/N',
                                              child: SDataField.string(
                                                value: _info!.dpSensorSn!,
                                                param: Param.dpSensorSn,
                                              ),
                                            ),
                                          ),
                                        if (_info!.dpSensorRange != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Sensor Range',
                                              child: SDataField.digit(
                                                value: _info!.dpSensorRange!,
                                                param: Param.dpSensorRange,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  if (_info!.minAllowFlowRate != null)
                                    SDecoration(
                                      header: 'Min. Allow Flow Rate',
                                      child: SDataField.digit(
                                        value: _info!.minAllowFlowRate!,
                                        param: Param.minAllowFlowRate,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SCard(
                              child: Column(
                                spacing: 24.0,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_info!.qCoefficientA != null ||
                                      _info!.qCoefficientC != null)
                                    Row(
                                      spacing: 24.0,
                                      children: [
                                        if (_info!.qCoefficientA != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Q Coefficient A',
                                              child: SDataField.digit(
                                                value: _info!.qCoefficientA!,
                                                param: Param.qCoefficientA,
                                              ),
                                            ),
                                          ),
                                        if (_info!.qCoefficientC != null)
                                          Expanded(
                                            child: SDecoration(
                                              header: 'Q Coefficient C',
                                              child: SDataField.digit(
                                                value: _info!.qCoefficientC!,
                                                param: Param.qCoefficientC,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  if (_info!.qSafetyMultiplier != null)
                                    SDecoration(
                                      header: 'Q Safety Multiplier',
                                      child: SDataField.digit(
                                        value: _info!.qSafetyMultiplier!,
                                        param: Param.qSafetyMultiplier,
                                      ),
                                    ),
                                  if (_info!.diffUncertainty != null)
                                    SDecoration(
                                      header: 'Differential Uncertainty',
                                      subHeader: Param.diffUncertainty
                                          .limit(_adem)
                                          ?.toDisplay(
                                            Param.diffUncertainty.decimal(
                                              _adem,
                                            ),
                                          ),
                                      child: SDataField.digitEdit(
                                        controller:
                                            _diffUncertaintyTEController,
                                        param: Param.diffUncertainty,
                                        isEnabled: !isLoading,
                                        isEdited:
                                            _info!.diffUncertainty!.isEdited,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() {
                                              _info!.diffUncertainty!.value = v
                                                  .toDouble();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_info!.lineGaugePress != null ||
                                _info!.atmosphericPress != null ||
                                _info!.gasSpecificGravity != null)
                              SCard(
                                child: SDecoration(
                                  header: 'Q Cutoff Temperature',
                                  spacing: 24.0,
                                  child: Column(
                                    spacing: 24.0,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_info!.lineGaugePress != null)
                                        SDecoration(
                                          header: 'Line Gauge Pressure',
                                          subHeader: Param.lineGaugePress
                                              .limit(_adem)
                                              ?.toDisplay(
                                                Param.lineGaugePress.decimal(
                                                  _adem,
                                                ),
                                              ),
                                          child: SDataField.digitEdit(
                                            controller:
                                                _lineGaugePressTEController,
                                            param: Param.lineGaugePress,
                                            isEnabled: !isLoading,
                                            isEdited:
                                                _info!.lineGaugePress!.isEdited,
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _info!.lineGaugePress!.value =
                                                      v.toDouble();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      if (_info!.atmosphericPress != null)
                                        SDecoration(
                                          header: 'Atmospheric Pressure',
                                          subHeader: Param.atmosphericPress
                                              .limit(_adem)
                                              ?.toDisplay(
                                                Param.atmosphericPress.decimal(
                                                  _adem,
                                                ),
                                              ),
                                          child: SDataField.digitEdit(
                                            controller:
                                                _atmosphericPressTEController,
                                            param: Param.atmosphericPress,
                                            isEnabled: !isLoading,
                                            isEdited: _info!
                                                .atmosphericPress!
                                                .isEdited,
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _info!
                                                      .atmosphericPress!
                                                      .value = v
                                                      .toDouble();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      if (_info!.gasSpecificGravity != null)
                                        SDecoration(
                                          header: 'Specific Gravity',
                                          subHeader: Param.gasSpecificGravity
                                              .limit(_adem)
                                              ?.toDisplay(
                                                Param.gasSpecificGravity
                                                    .decimal(_adem),
                                              ),
                                          child: SDataField.digitEdit(
                                            controller:
                                                _gasSpecificGravityTEController,
                                            param: Param.gasSpecificGravity,
                                            isEnabled: !isLoading,
                                            isEdited: _info!
                                                .gasSpecificGravity!
                                                .isEdited,
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _info!
                                                      .gasSpecificGravity!
                                                      .value = v
                                                      .toDouble();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_info!.qCutoffTempHigh != null ||
                                _info!.qCutoffTempLow != null)
                              SCard(
                                child: SDecoration(
                                  header: 'Q Cutoff Temperature',
                                  spacing: 24.0,
                                  child: Column(
                                    spacing: 24.0,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_info!.qCutoffTempHigh != null)
                                        SDecoration(
                                          header: 'High',
                                          subHeader: Param.qCutoffTempHigh
                                              .limit(_adem)
                                              ?.toDisplay(
                                                Param.qCutoffTempHigh.decimal(
                                                  _adem,
                                                ),
                                              ),
                                          child: SDataField.digitEdit(
                                            controller:
                                                _qCutoffTempHighTEController,
                                            param: Param.qCutoffTempHigh,
                                            isEnabled: !isLoading,
                                            isEdited: _info!
                                                .qCutoffTempHigh!
                                                .isEdited,
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _info!
                                                      .qCutoffTempHigh!
                                                      .value = v
                                                      .toDouble();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      if (_info!.qCutoffTempLow != null)
                                        SDecoration(
                                          header: 'Low',
                                          subHeader: Param.qCutoffTempLow
                                              .limit(_adem)
                                              ?.toDisplay(
                                                Param.qCutoffTempLow.decimal(
                                                  _adem,
                                                ),
                                              ),
                                          child: SDataField.digitEdit(
                                            controller:
                                                _qCutoffTempLowTEController,
                                            param: Param.qCutoffTempLow,
                                            isEnabled: !isLoading,
                                            isEdited:
                                                _info!.qCutoffTempLow!.isEdited,
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _info!.qCutoffTempLow!.value =
                                                      v.toDouble();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SLoading(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is SQMGPBReadyState) {
      setState(() => _updateData(state));
    } else if (state is SQMGPBUpdatedState) {
      showToast(context, text: 'Update succeeded.');
    } else if (state is SQMGPBFailedState) {
      await handleError(context, state.error);

      if (state.event is SQMGPBFetchEvent) {
        if (context.mounted && context.canPop()) context.pop();
      }
    }
  }

  Future<void> submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final accessCode = await getAccessCode(context);
      if (accessCode != null) {
        _bloc.add(SQMGPBUpdateEvent(accessCode, _info!));
      }
    } else {
      await showDialog(
        context: context,
        builder: (_) => const ConfigurationAlertDialog(),
      );
    }
  }
}
