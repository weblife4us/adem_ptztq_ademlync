import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/date_time_picker_button.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_basic_page_bloc.dart';
import 'setup_basic_page_model.dart';

class SetupBasicPage extends StatefulWidget {
  const SetupBasicPage({super.key});

  @override
  State<SetupBasicPage> createState() => _SetupBasicPageState();
}

class _SetupBasicPageState extends State<SetupBasicPage> with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupBasicPageBloc>(context);
  final _formKey = GlobalKey<FormState>();

  SetupBasicPageModel? _info;
  final _corVolTEController = TextEditingController();
  final _uncVolTEController = TextEditingController();

  Adem get _adem => AppDelegate().adem;
  bool get _isSealed => _adem.isSealed;

  List<VolumeUnit> get _volumeUnits =>
      VolumeUnit.values.where((e) => e.measSys == _adem.meterSystem).toList();

  List<InputPulseVolumeUnit> get _inputPulseVolumeUnits => InputPulseVolumeUnit
      .values
      .where((e) => e.meterSystem == _adem.meterSystem)
      .toList();

  // MARK: - Meter
  List<MeterSize> get _meterSizes =>
      _info!.meterSerial!.value.filterByFirmwareVersion(_adem.firmwareVersion);

  // NOTE: hpB3Imperial and hpB3Metric only for AdEM PTZ (AdEM25).
  List<MeterSerial> get _meterSeries {
    final series = _info!.meterSystem!.value.series;
    if (_adem.type.isAdemPtz && _adem.isAdem25) return series;

    return series
        .where(
          (o) => o != MeterSerial.hpB3Imperial && o != MeterSerial.hpB3Metric,
        )
        .toList();
  }

  void _updateMeterSerial() {
    if (!_meterSeries.contains(_info!.meterSerial!.value)) {
      _info!.meterSerial!.value = _meterSeries.first;
    }
  }

  void _updateMeterSize() {
    if (!_meterSizes.contains(_info!.meterSize!.value)) {
      _info!.meterSize!.value = _meterSizes.first;
    }
  }

  // MARK: - Output Pulse Volume Unit
  List<VolumeUnit> get _outputPulseVolumeUnits => _adem.isMeterSizeSupported
      ? (_info?.meterSize?.value.optPulseVolUnits ?? [])
      : (_info?.inputPulseVolUnit?.value.optPulseVolUnits ?? []);

  void _updateOutputPulseVolumeUnit() {
    if (_info?.corOutputPulseVolUnit?.value case final unit?
        when !_outputPulseVolumeUnits.contains(unit)) {
      _info?.corOutputPulseVolUnit?.value = _outputPulseVolumeUnits.first;
    }

    if (_info?.uncOutputPulseVolUnit?.value case final unit?
        when !_outputPulseVolumeUnits.contains(unit)) {
      _info?.uncOutputPulseVolUnit?.value = _outputPulseVolumeUnits.first;
    }
  }

  bool isGasDayStartTimeError() => _info?.gasDayStartTime?.value.hour == 0;

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData());
  }

  @override
  void dispose() {
    _corVolTEController.dispose();
    _uncVolTEController.dispose();
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
          child: GestureDetector(
            onTap: dismissKeyboard,
            child: Scaffold(
              appBar: SAppBar.withSubmit(
                context,
                text: locale.basicString,
                hasAdemInfoAction: isDataReady,
                isLoading: _info == null,
                isSubmitLoading: isDataReady && isLoading,
                onPressed: isDataReady ? _submitForm : null,
              ),
              body: SmartBodyLayout(
                child: isDataReady
                    ? Form(
                        key: _formKey,
                        child: Column(
                          spacing: 24.0,
                          children: [
                            if (_info?.gasDayStartTime != null ||
                                _info?.dispVolSelect != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_info?.gasDayStartTime case final time?)
                                      Column(
                                        spacing: 2.0,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SDecoration(
                                            header: 'Gas Day Start Time',
                                            child: DateTimePickerButton.time(
                                              context,
                                              param: Param.gasDayStartTime,
                                              value: time.value,
                                              isEdited: time.isEdited,
                                              enable: !isLoading,
                                              isError: isGasDayStartTimeError(),
                                              showMinute: false,
                                              onChanged: (v) => setState(
                                                () =>
                                                    _info!
                                                            .gasDayStartTime!
                                                            .value =
                                                        v,
                                              ),
                                            ),
                                          ),
                                          if (isGasDayStartTimeError())
                                            SText.bodyMedium(
                                              '${AppDelegate().is24HTimeFmt ? '00:00' : '12:00 AM'} is not supported.',
                                              color: colorScheme.warning(
                                                context,
                                              ),
                                            ),
                                        ],
                                      ),
                                    if (_info!.dispVolSelect != null)
                                      SDecoration(
                                        header: 'Display Volume Select',
                                        child: SDataField.dropdown(
                                          param: Param.dispVolSelect,
                                          value: _info!.dispVolSelect!.value,
                                          list: DispVolSelect.values,
                                          isEdited:
                                              _info!.dispVolSelect!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.dispVolSelect!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (_adem.isMeterSizeSupported &&
                                _info!.meterSystem != null &&
                                _info!.meterSerial != null &&
                                _info!.meterSize != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SText.bodyMedium('Meter'),
                                    SDataField.dropdown(
                                      title: 'System',
                                      value: _info!.meterSystem!.value,
                                      isSealed: _isSealed,
                                      list: MeterSystem.values,
                                      isEdited: _info!.meterSystem!.isEdited,
                                      isDisable: isLoading,
                                      stringBuilder: (v) => v.displayName,
                                      onChanged: (v) {
                                        if (v == null ||
                                            _info!.meterSystem!.value == v) {
                                          return;
                                        }

                                        setState(() {
                                          _info?.meterSystem?.value = v;
                                          _updateMeterSerial();
                                          _updateMeterSize();
                                          _updateOutputPulseVolumeUnit();
                                        });
                                      },
                                    ),
                                    SDataField.dropdown(
                                      title: 'Series',
                                      value: _info!.meterSerial!.value,
                                      isSealed: _isSealed,
                                      list: _meterSeries,
                                      isEdited: _info!.meterSerial!.isEdited,
                                      isDisable: isLoading,
                                      stringBuilder: (v) => v.displayName,
                                      onChanged: (v) {
                                        if (v == null ||
                                            _info!.meterSerial!.value == v) {
                                          return;
                                        }

                                        setState(() {
                                          _info?.meterSerial?.value = v;
                                          _updateMeterSize();
                                          _updateOutputPulseVolumeUnit();
                                        });
                                      },
                                    ),
                                    SDataField.dropdown(
                                      param: Param.meterSize,
                                      value: _info!.meterSize!.value,
                                      isSealed: _isSealed,
                                      list: _meterSizes,
                                      isEdited: _info!.meterSize!.isEdited,
                                      isDisable: isLoading,
                                      stringBuilder: (v) => v.displayName,
                                      onChanged: (v) {
                                        if (v == null ||
                                            _info!.meterSize!.value == v) {
                                          return;
                                        }

                                        setState(() {
                                          _info?.meterSize?.value = v;
                                          _updateOutputPulseVolumeUnit();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                            if (_info!.pressUnit != null ||
                                _info!.tempUnit != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_info!.pressUnit != null)
                                      SDecoration(
                                        header: 'Pressure Unit',
                                        child:
                                            _adem.meterSystem ==
                                                MeterSystem.metric
                                            ? SDataField.dropdown(
                                                param: Param.pressUnit,
                                                value: _info!.pressUnit!.value,
                                                isSealed: _isSealed,
                                                list: const [
                                                  PressUnit.kpa,
                                                  PressUnit.bar,
                                                ],
                                                isEdited:
                                                    _info!.pressUnit!.isEdited,
                                                isDisable: isLoading,
                                                stringBuilder: (v) =>
                                                    v.displayName,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!.pressUnit!.value =
                                                          v;
                                                    });
                                                  }
                                                },
                                              )
                                            : SDataField.string(
                                                param: Param.pressUnit,
                                                value: _info!
                                                    .pressUnit!
                                                    .value
                                                    .displayName,
                                              ),
                                      ),

                                    if (_info!.tempUnit != null)
                                      SDecoration(
                                        header: 'Temperature Unit',
                                        child: SDataField.string(
                                          param: Param.tempUnit,
                                          value: _info!.tempUnit!.displayName,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            if (_info!.corVol != null ||
                                _info!.fullCorVol != null ||
                                _info!.corVolUnit != null ||
                                _info!.corVolDigits != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SDecoration(
                                      header: 'Corrected Volume',
                                      subHeader: _info!.corVol != null
                                          ? Param.corVol
                                                .limit(_adem)
                                                ?.toDisplay(
                                                  Param.corVol.decimal(_adem),
                                                )
                                          : null,
                                      child: _info!.corVol != null
                                          ? SDataField.digitEdit(
                                              controller: _corVolTEController,
                                              param: Param.corVol,
                                              isEnabled: !isLoading,
                                              isEdited: _info!.corVol!.isEdited,
                                              isSealed: _isSealed,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.corVol!.value = v
                                                        .toInt();
                                                  });
                                                }
                                              },
                                            )
                                          : null,
                                    ),
                                    if (_info!.fullCorVol != null)
                                      SDecoration(
                                        header: 'Full',
                                        child: SDataField.digit(
                                          param: Param.corFullVol,
                                          value: _info!.fullCorVol!,
                                        ),
                                      ),
                                    if (_info!.corVolUnit != null)
                                      SDecoration(
                                        header: 'Unit',
                                        child: SDataField.dropdown(
                                          param: Param.corVolUnit,
                                          value: _info!.corVolUnit!.value,
                                          isSealed: _isSealed,
                                          list: _volumeUnits,
                                          isEdited: _info!.corVolUnit!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.corVolUnit!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.corVolDigits != null)
                                      SDecoration(
                                        header: 'Digits',
                                        child: SDataField.dropdown(
                                          param: Param.corVolDigits,
                                          value: _info!.corVolDigits!.value,
                                          list: VolDigits.values,
                                          isEdited:
                                              _info!.corVolDigits!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.corVolDigits!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (_info!.uncVol != null ||
                                _info!.fullUncVol != null ||
                                _info!.uncVolUnit != null ||
                                _info!.uncVolDigits != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SDecoration(
                                      header: 'Uncorrected Volume',
                                      subHeader: _info!.uncVol != null
                                          ? Param.uncVol
                                                .limit(_adem)
                                                ?.toDisplay(
                                                  Param.uncVol.decimal(_adem),
                                                )
                                          : null,
                                      child: _info!.fullUncVol != null
                                          ? SDataField.digitEdit(
                                              controller: _uncVolTEController,
                                              param: Param.uncVol,
                                              isSealed: _isSealed,
                                              isEnabled: !isLoading,
                                              isEdited: _info!.uncVol!.isEdited,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.uncVol!.value = v
                                                        .toInt();
                                                  });
                                                }
                                              },
                                            )
                                          : null,
                                    ),
                                    if (_info!.fullUncVol != null)
                                      SDecoration(
                                        header: 'Full',
                                        child: SDataField.digit(
                                          param: Param.uncFullVol,
                                          value: _info!.fullUncVol!,
                                        ),
                                      ),
                                    if (_info!.uncVolUnit != null)
                                      SDecoration(
                                        header: 'Unit',
                                        child: SDataField.dropdown(
                                          param: Param.uncVolUnit,
                                          value: _info!.uncVolUnit!.value,
                                          isSealed: _isSealed,
                                          list: _volumeUnits,
                                          isEdited: _info!.uncVolUnit!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.uncVolUnit!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.uncVolDigits != null)
                                      SDecoration(
                                        header: 'Digits',
                                        child: SDataField.dropdown(
                                          param: Param.uncVolDigits,
                                          value: _info!.uncVolDigits!.value,
                                          list: VolDigits.values,
                                          isEdited:
                                              _info!.uncVolDigits!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.uncVolDigits!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (_info!.inputPulseVolUnit != null &&
                                !_adem.isMeterSizeSupported)
                              SCard(
                                child: SDecoration(
                                  header: 'Input Pulse Volume Unit',
                                  child: SDataField.dropdown(
                                    param: Param.inputPulseVolUnit,
                                    value: _info!.inputPulseVolUnit!.value,
                                    isSealed: _isSealed,
                                    list: _inputPulseVolumeUnits,
                                    isEdited:
                                        _info!.inputPulseVolUnit!.isEdited,
                                    isDisable: isLoading,
                                    stringBuilder: (v) => v.displayName,
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          _info!.inputPulseVolUnit!.value = v;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            if (_info!.outPulseSpacing != null ||
                                _info!.outPulseWidth != null ||
                                _info!.corOutputPulseVolUnit != null ||
                                _info!.uncOutputPulseVolUnit != null)
                              SCard(
                                child: Column(
                                  spacing: 24.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SText.bodyMedium('Output Pulse'),
                                    if (_info!.outPulseSpacing != null)
                                      SDecoration(
                                        header: 'Spacing',
                                        child: SDataField.dropdown(
                                          param: Param.outPulseSpacing,
                                          value: _info!.outPulseSpacing!.value,
                                          list: OutPulseSpacing.values,
                                          isEdited:
                                              _info!.outPulseSpacing!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.outPulseSpacing!.value =
                                                    v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.outPulseWidth != null)
                                      SDecoration(
                                        header: 'Width',
                                        child: SDataField.dropdown(
                                          param: Param.outPulseWidth,
                                          value: _info!.outPulseWidth!.value,
                                          list: OutPulseWidth.values,
                                          isEdited:
                                              _info!.outPulseWidth!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.outPulseWidth!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.corOutputPulseVolUnit != null)
                                      SDecoration(
                                        header: 'Corrected Unit',
                                        child: SDataField.dropdown(
                                          param: Param.corOutputPulseVolUnit,
                                          value: _info!
                                              .corOutputPulseVolUnit!
                                              .value,
                                          list: _outputPulseVolumeUnits,
                                          isEdited: _info!
                                              .corOutputPulseVolUnit!
                                              .isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!
                                                        .corOutputPulseVolUnit!
                                                        .value =
                                                    v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.uncOutputPulseVolUnit != null)
                                      SDecoration(
                                        header: 'Uncorrected Unit',
                                        child: SDataField.dropdown(
                                          param: Param.uncOutputPulseVolUnit,
                                          value: _info!
                                              .uncOutputPulseVolUnit!
                                              .value,
                                          list: _outputPulseVolumeUnits,
                                          isEdited: _info!
                                              .uncOutputPulseVolUnit!
                                              .isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!
                                                        .uncOutputPulseVolUnit!
                                                        .value =
                                                    v;
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

  void _updateData(DataReady state) {
    _info = state.info;

    if (_info!.corVol != null) {
      _corVolTEController.text = dataToString(
        _info!.corVol!.value,
        Param.corVol,
      );
    }
    if (_info!.uncVol != null) {
      _uncVolTEController.text = dataToString(
        _info!.uncVol!.value,
        Param.uncVol,
      );
    }
  }

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if ((_formKey.currentState?.validate() ?? false) &&
        !isGasDayStartTimeError()) {
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
}
