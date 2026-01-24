import 'dart:async';
import 'dart:math';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_dialog_layout.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_press_and_temp_page_bloc.dart';
import 'setup_press_and_temp_page_model.dart';

class SetupPressAndTempPage extends StatefulWidget {
  const SetupPressAndTempPage({super.key});

  @override
  State<SetupPressAndTempPage> createState() => _SetupPressAndTempPageState();
}

class _SetupPressAndTempPageState extends State<SetupPressAndTempPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupPressAndTempPageBloc>(context);
  final _formKey = GlobalKey<FormState>();

  Adem get _adem => AppDelegate().adem;
  bool get _isSealed => _adem.isSealed;

  Param? get superXFactorParam => switch (_adem.measureCache.superXFactorType) {
    FactorType.live => Param.liveSuperXFactor,
    FactorType.fixed => Param.fixedSuperXFactor,
    _ => null,
  };

  SetupPressAndTempPageModel? _info;
  final _pressTxdrSnTEController = TextEditingController();
  final _pressTxdrRangeTEController = TextEditingController();
  final _pressHighLimitTEController = TextEditingController();
  final _pressLowLimitTEController = TextEditingController();
  final _pressFactorTEController = TextEditingController();
  final _tempHighLimitTEController = TextEditingController();
  final _tempLowLimitTEController = TextEditingController();
  final _tempFactorTEController = TextEditingController();
  final _uncFlowrateHighLimitTEController = TextEditingController();
  final _uncFlowrateLowLimitTEController = TextEditingController();
  final _superXFactorTEController = TextEditingController();
  final _gasSpecificGravityTEController = TextEditingController();
  final _gasMoleN2TEController = TextEditingController();
  final _gasMoleH2TEController = TextEditingController();
  final _gasMoleCO2TEController = TextEditingController();
  final _gasMoleHsTEController = TextEditingController();
  final _basePressTEController = TextEditingController();
  final _baseTempTEController = TextEditingController();
  final _atmosphericPressTEController = TextEditingController();

  void _updateData(DataReady state) {
    _info = state.info;

    if (_info?.pressTxdrSn != null) {
      _pressTxdrSnTEController.text = dataToString(
        _info!.pressTxdrSn!.value,
        Param.pressTransSn,
      );
    }

    if (_info?.pressTxdrRange != null) {
      _pressTxdrRangeTEController.text = dataToString(
        _info!.pressTxdrRange!.value,
        Param.pressTransRange,
      );
    }

    if (_info?.pressHighLimit != null) {
      _pressHighLimitTEController.text = dataToString(
        _info!.pressHighLimit!.value,
        Param.pressHighLimit,
      );
    }

    if (_info?.pressLowLimit != null) {
      _pressLowLimitTEController.text = dataToString(
        _info!.pressLowLimit!.value,
        Param.pressLowLimit,
      );
    }

    if (_info?.pressFactor != null) {
      _pressFactorTEController.text = dataToString(
        _info!.pressFactor!.value,
        Param.pressFactor,
      );
    }

    if (_info?.tempHighLimit != null) {
      _tempHighLimitTEController.text = dataToString(
        _info!.tempHighLimit!.value,
        Param.tempHighLimit,
      );
    }

    if (_info?.tempLowLimit != null) {
      _tempLowLimitTEController.text = dataToString(
        _info!.tempLowLimit!.value,
        Param.tempLowLimit,
      );
    }

    if (_info?.tempFactor != null) {
      _tempFactorTEController.text = dataToString(
        _info!.tempFactor!.value,
        Param.tempFactor,
      );
    }

    if (_info?.uncFlowrateHighLimit != null) {
      _uncFlowrateHighLimitTEController.text = dataToString(
        _info!.uncFlowrateHighLimit!.value,
        Param.uncFlowRateHighLimit,
      );
    }

    if (_info?.uncFlowrateLowLimit != null) {
      _uncFlowrateLowLimitTEController.text = dataToString(
        _info!.uncFlowrateLowLimit!.value,
        Param.uncFlowRateLowLimit,
      );
    }

    if (_info?.superXFactor != null && superXFactorParam != null) {
      _superXFactorTEController.text = dataToString(
        _info!.superXFactor!.value,
        superXFactorParam!,
      );
    }

    if (_info?.gasSpecificGravity != null) {
      _gasSpecificGravityTEController.text = dataToString(
        _info!.gasSpecificGravity!.value,
        Param.gasSpecificGravity,
      );
    }

    if (_info?.gasMoleN2 != null) {
      _gasMoleN2TEController.text = dataToString(
        _info!.gasMoleN2!.value,
        Param.gasMoleN2,
      );
    }

    if (_info?.gasMoleH2 != null) {
      _gasMoleH2TEController.text = dataToString(
        _info!.gasMoleH2!.value,
        Param.gasMoleH2,
      );
    }

    if (_info?.gasMoleCO2 != null) {
      _gasMoleCO2TEController.text = dataToString(
        _info!.gasMoleCO2!.value,
        Param.gasMoleCO2,
      );
    }

    if (_info?.gasMoleHs != null) {
      _gasMoleHsTEController.text = dataToString(
        _info!.gasMoleHs!.value,
        Param.gasMoleHs,
      );
    }

    if (_info?.basePress != null) {
      _basePressTEController.text = dataToString(
        _info!.basePress!.value,
        Param.basePress,
      );
    }

    if (_info?.baseTemp != null) {
      _baseTempTEController.text = dataToString(
        _info!.baseTemp!.value,
        Param.baseTemp,
      );
    }

    if (_info?.atmosphericPress != null) {
      _atmosphericPressTEController.text = dataToString(
        _info!.atmosphericPress!.value,
        Param.atmosphericPress,
      );
    }
  }

  // MARK: Pressure

  double maxPressLimit(double range) {
    const double offset = 1.2;
    return range * offset;
  }

  AdemParamLimit? pressHighLimit(double lowLimit, double range) {
    if (Param.pressHighLimit.limit(_adem) case AdemParamLimit limit) {
      lowLimit = lowLimit + 1;

      final minLimit = max(limit.min, lowLimit);
      final maxLimit = min(limit.max, maxPressLimit(range));

      return limit.copyWith(min: min(minLimit, maxLimit), max: maxLimit);
    }

    return null;
  }

  AdemParamLimit? pressLowLimit(double highLimit) {
    if (Param.pressLowLimit.limit(_adem) case AdemParamLimit limit) {
      highLimit = highLimit - 1;

      final maxLimit = min(limit.max, highLimit);

      return limit.copyWith(max: max(limit.min, maxLimit));
    }

    return null;
  }

  // MARK: Temperature

  bool get isTempLimitErr =>
      _info!.tempHighLimit!.value <= _info!.tempLowLimit!.value;

  bool get isUncFlowrateLimitErr =>
      _info!.uncFlowrateHighLimit!.value <= _info!.uncFlowrateLowLimit!.value;

  // MARK: Limit error

  String? limitError(String? err, {required bool isValid}) {
    if (err != null) return err;
    return isValid ? null : 'Value exceeds the limits';
  }

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData());
  }

  @override
  void dispose() {
    _pressTxdrSnTEController.dispose();
    _pressTxdrRangeTEController.dispose();
    _pressHighLimitTEController.dispose();
    _pressLowLimitTEController.dispose();
    _pressFactorTEController.dispose();
    _tempHighLimitTEController.dispose();
    _tempLowLimitTEController.dispose();
    _tempFactorTEController.dispose();
    _uncFlowrateHighLimitTEController.dispose();
    _uncFlowrateLowLimitTEController.dispose();
    _superXFactorTEController.dispose();
    _gasSpecificGravityTEController.dispose();
    _gasMoleN2TEController.dispose();
    _gasMoleH2TEController.dispose();
    _gasMoleCO2TEController.dispose();
    _basePressTEController.dispose();
    _baseTempTEController.dispose();
    _atmosphericPressTEController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isNx19 = _info?.superXAlgo?.value == SuperXAlgo.nx19;
        final isSgerg = _info?.superXAlgo?.value == SuperXAlgo.sgerg88;
        final isAga8G1 = _info?.superXAlgo?.value == SuperXAlgo.aga8G1;
        final isAga8G2 = _info?.superXAlgo?.value == SuperXAlgo.aga8G2;
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
                text: 'Press. & Temp.',
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
                            if (_info!.pressTxdrType != null ||
                                _info!.pressTxdrSn != null ||
                                _info!.pressTxdrRange != null)
                              SCard(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24.0,
                                  children: [
                                    SDecoration(
                                      header: 'Pressure Transducer',
                                      headerSuffix:
                                          _info!.pressTxdrType?.displayName,
                                    ),
                                    Column(
                                      spacing: 24.0,
                                      children: [
                                        // NOTE: Only AdEM 25 can edit.
                                        if (_info!.pressTxdrSn != null)
                                          SDecoration(
                                            header: 'S/N',
                                            child: _adem.isAdem25
                                                ? SDataField.digitEdit(
                                                    controller:
                                                        _pressTxdrSnTEController,
                                                    param: Param.pressTransSn,
                                                    isEnabled: !isLoading,
                                                    isEdited:
                                                        _info!
                                                            .pressTxdrSn
                                                            ?.isEdited ??
                                                        false,
                                                    onChanged: (v) {
                                                      if (v != null) {
                                                        setState(() {
                                                          _info!
                                                              .pressTxdrSn
                                                              ?.value = v
                                                              .toInt();
                                                        });
                                                      }
                                                    },
                                                  )
                                                : SDataField.digit(
                                                    value: _info!
                                                        .pressTxdrSn
                                                        ?.value,
                                                    param: Param.pressTransSn,
                                                  ),
                                          ),

                                        if (_info?.pressTxdrRange?.value
                                            case final pressTxdrRange?)
                                          SDecoration(
                                            header: 'Range',
                                            child: SDataField.digit(
                                              value: pressTxdrRange,
                                              param: Param.pressTransRange,
                                            ),
                                            // NOTE: [SKYL-556]
                                            // subHeader: Param.pressTransRange
                                            //     .limit(_adem)
                                            //     ?.toDisplay(Param.pressTransRange
                                            //         .decimal(_adem)),
                                            // child: SDataField.digitEdit(
                                            //   controller:
                                            //       _pressTxdrRangeTEController,
                                            //   param: Param.pressTransRange,
                                            //   isEnabled: !isLoading,
                                            //   isEdited:
                                            //       _info!.pressTxdrRange?.isEdited ??
                                            //           false,
                                            //   onChanged: (v) {
                                            //     if (v != null) {
                                            //       setState(() {
                                            //         _info!.pressTxdrRange?.value =
                                            //             v.toDouble();
                                            //       });
                                            //     }
                                            //   },
                                            // ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (_info!.gasAbsPress != null ||
                                _info!.gasGaugePress != null ||
                                _info!.pressFactor != null ||
                                _info!.pressFactorType != null ||
                                _info!.pressHighLimit != null ||
                                _info!.pressLowLimit != null ||
                                _info!.atmosphericPress != null ||
                                _info!.basePress != null)
                              SCard(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24.0,
                                  children: [
                                    SDecoration(
                                      header: 'Pressure',
                                      spacing: 24.0,
                                      child:
                                          _info!.gasAbsPress != null ||
                                              _info!.gasGaugePress != null
                                          ? Row(
                                              spacing: 24.0,
                                              children: [
                                                if (_info!.gasAbsPress != null)
                                                  Expanded(
                                                    child: SDecoration(
                                                      header: 'Absolute',
                                                      child: SDataField.digit(
                                                        param: Param.absPress,
                                                        value:
                                                            _info!.gasAbsPress,
                                                      ),
                                                    ),
                                                  ),
                                                if (_info!.gasGaugePress !=
                                                    null)
                                                  Expanded(
                                                    child: SDecoration(
                                                      header: 'Gauge',
                                                      child: SDataField.digit(
                                                        param: Param.gaugePress,
                                                        value: _info!
                                                            .gasGaugePress,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : null,
                                    ),
                                    if (_info!.pressFactor != null)
                                      SDecoration(
                                        header: 'Factor',
                                        subHeader:
                                            _info!.pressFactorType?.value ==
                                                FactorType.fixed
                                            ? Param.pressFactor
                                                  .limit(_adem)
                                                  ?.toDisplay(
                                                    Param.pressFactor.decimal(
                                                      _adem,
                                                    ),
                                                  )
                                            : null,
                                        child:
                                            _info!.pressFactorType?.value ==
                                                FactorType.fixed
                                            ? SDataField.digitEdit(
                                                controller:
                                                    _pressFactorTEController,
                                                param: Param.pressFactor,
                                                isEnabled: !isLoading,
                                                isEdited: _info!
                                                    .pressFactor!
                                                    .isEdited,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!
                                                          .pressFactor!
                                                          .value = v
                                                          .toDouble();
                                                    });
                                                  }
                                                },
                                              )
                                            : SDataField.digit(
                                                param: Param.pressFactor,
                                                value:
                                                    _info!.pressFactor!.value,
                                              ),
                                      ),
                                    if (_info!.pressFactorType != null)
                                      SDecoration(
                                        header: 'Factor Type',
                                        child:
                                            AppDelegate().adem.type ==
                                                    AdemType.ademTq ||
                                                AppDelegate().adem.type ==
                                                    AdemType.ademT ||
                                                AppDelegate().adem.type ==
                                                    AdemType.universalT
                                            ? SDataField.string(
                                                param: Param.pressFactorType,
                                                value: _info!
                                                    .pressFactorType!
                                                    .value
                                                    .displayName,
                                              )
                                            : SDataField.dropdown(
                                                param: Param.pressFactorType,
                                                value: _info!
                                                    .pressFactorType!
                                                    .value,
                                                isSealed: _isSealed,
                                                list: FactorType.values,
                                                isEdited: _info!
                                                    .pressFactorType!
                                                    .isEdited,
                                                isDisable: isLoading,
                                                stringBuilder: (v) =>
                                                    v.displayName,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!
                                                              .pressFactorType!
                                                              .value =
                                                          v;

                                                      if (_info?.pressFactor !=
                                                              null &&
                                                          v ==
                                                              FactorType.live) {
                                                        _info!.pressFactor!
                                                            .reset();
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                      ),

                                    const Divider(),
                                    if ((
                                          _info?.pressHighLimit,
                                          _info?.pressLowLimit?.value,
                                          _info?.pressTxdrRange?.value,
                                        )
                                        case (
                                          ValueTracker<double> highLimit,
                                          double lowLimit,
                                          double range,
                                        ))
                                      SDecoration(
                                        header: 'High Limit',
                                        subHeader:
                                            pressHighLimit(
                                              lowLimit,
                                              range,
                                            )?.toDisplay(
                                              Param.pressHighLimit.decimal(
                                                _adem,
                                              ),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller:
                                              _pressHighLimitTEController,
                                          param: Param.pressHighLimit,
                                          isEnabled: !isLoading,
                                          isEdited: highLimit.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(
                                                () => highLimit.value = v
                                                    .toDouble(),
                                              );
                                            }
                                          },
                                          customValidator: (err) => limitError(
                                            err,
                                            isValid:
                                                pressHighLimit(
                                                  lowLimit,
                                                  range,
                                                )?.isValid(highLimit.value) ??
                                                true,
                                          ),
                                        ),
                                      ),
                                    if ((
                                          _info?.pressLowLimit,
                                          _info?.pressHighLimit?.value,
                                        )
                                        case (
                                          ValueTracker<double> lowLimit,
                                          double highLimit,
                                        ))
                                      SDecoration(
                                        header: 'Low Limit',
                                        subHeader: pressLowLimit(highLimit)
                                            ?.toDisplay(
                                              Param.pressLowLimit.decimal(
                                                _adem,
                                              ),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller:
                                              _pressLowLimitTEController,
                                          param: Param.pressLowLimit,
                                          isEnabled: !isLoading,
                                          isEdited: lowLimit.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(
                                                () => lowLimit.value = v
                                                    .toDouble(),
                                              );
                                            }
                                          },
                                          customValidator: (err) => limitError(
                                            err,
                                            isValid:
                                                pressLowLimit(
                                                  highLimit,
                                                )?.isValid(lowLimit.value) ??
                                                true,
                                          ),
                                        ),
                                      ),
                                    if (_info!.atmosphericPress != null)
                                      SDecoration(
                                        header: 'Atmospheric',
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
                                          isEdited:
                                              _info!.atmosphericPress!.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.atmosphericPress!.value =
                                                    v.toDouble();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.basePress != null)
                                      SDecoration(
                                        header: 'Base',
                                        subHeader: Param.basePress
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.basePress.decimal(_adem),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller: _basePressTEController,
                                          param: Param.basePress,
                                          isSealed: _isSealed,
                                          isEnabled: !isLoading,
                                          isEdited: _info!.basePress!.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.basePress!.value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (_info!.gasTemp != null ||
                                _info!.tempFactor != null ||
                                _info!.tempFactorType != null ||
                                _info!.tempHighLimit != null ||
                                _info!.tempLowLimit != null ||
                                _info!.baseTemp != null)
                              SCard(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24.0,
                                  children: [
                                    SDecoration(
                                      header: 'Temperature',
                                      spacing: 24.0,
                                      child: _info!.gasTemp != null
                                          ? SDataField.digit(
                                              param: Param.temp,
                                              value: _info!.gasTemp,
                                            )
                                          : null,
                                    ),
                                    if (_info!.tempFactor != null)
                                      SDecoration(
                                        header: 'Factor',
                                        subHeader:
                                            _info!.tempFactorType?.value ==
                                                FactorType.fixed
                                            ? Param.tempFactor
                                                  .limit(_adem)
                                                  ?.toDisplay(
                                                    Param.tempFactor.decimal(
                                                      _adem,
                                                    ),
                                                  )
                                            : null,
                                        child:
                                            _info!.tempFactorType?.value ==
                                                FactorType.fixed
                                            ? SDataField.digitEdit(
                                                controller:
                                                    _tempFactorTEController,
                                                param: Param.tempFactor,
                                                isEnabled: !isLoading,
                                                isEdited:
                                                    _info!.tempFactor!.isEdited,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!.tempFactor!.value =
                                                          v.toDouble();
                                                    });
                                                  }
                                                },
                                              )
                                            : SDataField.digit(
                                                param: Param.tempFactor,
                                                value: _info!.tempFactor!.value,
                                              ),
                                      ),
                                    if (_info!.tempFactorType != null)
                                      SDecoration(
                                        header: 'Factor Type',
                                        child: SDataField.dropdown(
                                          param: Param.tempFactorType,
                                          value: _info!.tempFactorType!.value,
                                          isSealed: _isSealed,
                                          list: FactorType.values,
                                          isEdited:
                                              _info!.tempFactorType!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.tempFactorType!.value =
                                                    v;

                                                if (_info?.tempFactor != null &&
                                                    v == FactorType.live) {
                                                  _info!.tempFactor!.reset();
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),

                                    const Divider(),
                                    if (_info!.tempHighLimit != null)
                                      SDecoration(
                                        header: 'High Limit',
                                        subHeader: Param.tempHighLimit
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.tempHighLimit.decimal(
                                                _adem,
                                              ),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller:
                                              _tempHighLimitTEController,
                                          param: Param.tempHighLimit,
                                          isEnabled: !isLoading,
                                          isEdited:
                                              _info!.tempHighLimit!.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.tempHighLimit!.value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                          customValidator: (err) {
                                            return err ??
                                                (isTempLimitErr
                                                    ? 'Should be higher than the low limit'
                                                    : null);
                                          },
                                        ),
                                      ),
                                    if (_info!.tempLowLimit != null)
                                      SDecoration(
                                        header: 'Low Limit',
                                        subHeader: Param.tempLowLimit
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.tempLowLimit.decimal(_adem),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller: _tempLowLimitTEController,
                                          param: Param.tempLowLimit,
                                          isEnabled: !isLoading,
                                          isEdited:
                                              _info!.tempLowLimit!.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.tempLowLimit!.value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                          customValidator: (err) {
                                            return err ??
                                                (isTempLimitErr
                                                    ? 'Should be lower than the high limit'
                                                    : null);
                                          },
                                        ),
                                      ),
                                    if (_info!.baseTemp != null)
                                      SDecoration(
                                        header: 'Base',
                                        subHeader: Param.baseTemp
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.baseTemp.decimal(_adem),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller: _baseTempTEController,
                                          param: Param.baseTemp,
                                          isSealed: _isSealed,
                                          isEnabled: !isLoading,
                                          isEdited: _info!.baseTemp!.isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.baseTemp!.value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (_info!.superXFactor != null &&
                                _info!.superXFactorType != null &&
                                _info!.superXAlgo != null)
                              SCard(
                                footer:
                                    _info!.superXAlgo!.value == SuperXAlgo.aga8
                                    ? locale.aga8DetailDescription
                                    : null,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24.0,
                                  children: [
                                    const SDecoration(header: 'Super X'),
                                    if (_info!.superXFactor != null)
                                      SDecoration(
                                        header: 'Factor',
                                        subHeader:
                                            _info!.superXFactorType?.value ==
                                                    FactorType.fixed &&
                                                superXFactorParam != null
                                            ? superXFactorParam!
                                                  .limit(_adem)
                                                  ?.toDisplay(
                                                    superXFactorParam!.decimal(
                                                      _adem,
                                                    ),
                                                  )
                                            : null,
                                        child:
                                            _info!.superXFactorType!.value ==
                                                FactorType.fixed
                                            ? SDataField.digitEdit(
                                                controller:
                                                    _superXFactorTEController,
                                                param: superXFactorParam,
                                                isEnabled: !isLoading,
                                                isEdited: _info!
                                                    .superXFactor!
                                                    .isEdited,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!
                                                          .superXFactor!
                                                          .value = v
                                                          .toDouble();
                                                    });
                                                  }
                                                },
                                              )
                                            : SDataField.digit(
                                                param: superXFactorParam,
                                                value:
                                                    _info!.superXFactor!.value,
                                              ),
                                      ),
                                    if (_info!.superXFactorType != null)
                                      SDecoration(
                                        child: SDataField.dropdown(
                                          param: Param.superXFactorType,
                                          value: _info!.superXFactorType!.value,
                                          isSealed: _isSealed,
                                          list: FactorType.values,
                                          isEdited:
                                              _info!.superXFactorType!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.superXFactorType!.value =
                                                    v;

                                                if (_info?.superXFactor !=
                                                        null &&
                                                    v == FactorType.live) {
                                                  _info!.superXFactor!.reset();
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    if (_info!.superXAlgo != null &&
                                        _info!.superXFactorType!.value ==
                                            FactorType.live) ...[
                                      SDecoration(
                                        header: 'Algorithm',
                                        child: SDataField.dropdown(
                                          param: Param.superXAlgo,
                                          value: _info!.superXAlgo!.value,
                                          isSealed: _isSealed,
                                          list: SuperXAlgo.values,
                                          isEdited: _info!.superXAlgo!.isEdited,
                                          isDisable: isLoading,
                                          stringBuilder: (v) => v.displayName,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!.superXAlgo!.value = v;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      if (_info!.superXAlgo!.value !=
                                          SuperXAlgo.aga8) ...[
                                        const Divider(),
                                        if ((isNx19 ||
                                                isSgerg ||
                                                isAga8G1 ||
                                                isAga8G2) &&
                                            _info!.gasSpecificGravity != null)
                                          SDecoration(
                                            header: 'Specific Gravity',
                                            subHeader: Param.gasSpecificGravity
                                                .limit(
                                                  _adem,
                                                  algo:
                                                      _info!.superXAlgo?.value,
                                                )
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
                                        if ((isNx19 || isAga8G2) &&
                                            _info!.gasMoleN2 != null)
                                          SDecoration(
                                            header: 'N<d>2</d>',
                                            subHeader: Param.gasMoleN2
                                                .limit(
                                                  _adem,
                                                  algo:
                                                      _info!.superXAlgo?.value,
                                                )
                                                ?.toDisplay(
                                                  Param.gasMoleN2.decimal(
                                                    _adem,
                                                  ),
                                                ),
                                            child: SDataField.digitEdit(
                                              controller:
                                                  _gasMoleN2TEController,
                                              param: Param.gasMoleN2,
                                              isEnabled: !isLoading,
                                              isEdited:
                                                  _info!.gasMoleN2!.isEdited,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.gasMoleN2!.value = v
                                                        .toDouble();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        if (isSgerg && _info!.gasMoleH2 != null)
                                          SDecoration(
                                            header: 'H<d>2</d>',
                                            subHeader: Param.gasMoleH2
                                                .limit(
                                                  _adem,
                                                  algo:
                                                      _info!.superXAlgo?.value,
                                                )
                                                ?.toDisplay(
                                                  Param.gasMoleH2.decimal(
                                                    _adem,
                                                  ),
                                                ),
                                            child: SDataField.digitEdit(
                                              controller:
                                                  _gasMoleH2TEController,
                                              param: Param.gasMoleH2,
                                              isEnabled: !isLoading,
                                              isEdited:
                                                  _info!.gasMoleH2!.isEdited,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.gasMoleH2!.value = v
                                                        .toDouble();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        if ((isNx19 ||
                                                isSgerg ||
                                                isAga8G1 ||
                                                isAga8G2) &&
                                            _info!.gasMoleCO2 != null)
                                          SDecoration(
                                            header: 'CO<d>2</d>',
                                            subHeader: Param.gasMoleCO2
                                                .limit(
                                                  _adem,
                                                  algo:
                                                      _info!.superXAlgo?.value,
                                                )
                                                ?.toDisplay(
                                                  Param.gasMoleCO2.decimal(
                                                    _adem,
                                                  ),
                                                ),
                                            child: SDataField.digitEdit(
                                              controller:
                                                  _gasMoleCO2TEController,
                                              param: Param.gasMoleCO2,
                                              isEnabled: !isLoading,
                                              isEdited:
                                                  _info!.gasMoleCO2!.isEdited,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.gasMoleCO2!.value = v
                                                        .toDouble();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        if ((isSgerg || isAga8G1) &&
                                            _info!.gasMoleHs != null)
                                          SDecoration(
                                            header: 'Hs',
                                            subHeader: Param.gasMoleHs
                                                .limit(_adem)
                                                ?.toDisplay(
                                                  Param.gasMoleHs.decimal(
                                                    _adem,
                                                  ),
                                                ),
                                            child: SDataField.digitEdit(
                                              controller:
                                                  _gasMoleHsTEController,
                                              param: Param.gasMoleHs,
                                              isEnabled: !isLoading,
                                              isEdited:
                                                  _info!.gasMoleHs!.isEdited,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!.gasMoleHs!.value = v
                                                        .toInt();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            if (_info!.uncFlowrateHighLimit != null ||
                                _info!.uncFlowrateLowLimit != null)
                              SCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 24.0,
                                  children: [
                                    const SText.bodyMedium(
                                      'Uncorrected Flow Rate',
                                    ),
                                    if (_info!.uncFlowrateHighLimit != null)
                                      SDecoration(
                                        header: 'High Limit',
                                        subHeader: Param.uncFlowRateHighLimit
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.uncFlowRateHighLimit
                                                  .decimal(_adem),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller:
                                              _uncFlowrateHighLimitTEController,
                                          param: Param.uncFlowRateHighLimit,
                                          isEnabled: !isLoading,
                                          isEdited: _info!
                                              .uncFlowrateHighLimit!
                                              .isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!
                                                    .uncFlowrateHighLimit!
                                                    .value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                          customValidator: (err) {
                                            return err ??
                                                (isUncFlowrateLimitErr
                                                    ? 'Should be higher than the low limit'
                                                    : null);
                                          },
                                        ),
                                      ),
                                    if (_info!.uncFlowrateLowLimit != null)
                                      SDecoration(
                                        header: 'Low Limit',
                                        subHeader: Param.uncFlowRateLowLimit
                                            .limit(_adem)
                                            ?.toDisplay(
                                              Param.uncFlowRateLowLimit.decimal(
                                                _adem,
                                              ),
                                            ),
                                        child: SDataField.digitEdit(
                                          controller:
                                              _uncFlowrateLowLimitTEController,
                                          param: Param.uncFlowRateLowLimit,
                                          isEnabled: !isLoading,
                                          isEdited: _info!
                                              .uncFlowrateLowLimit!
                                              .isEdited,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!
                                                    .uncFlowrateLowLimit!
                                                    .value = v
                                                    .toDouble();
                                              });
                                            }
                                          },
                                          customValidator: (err) {
                                            return err ??
                                                (isUncFlowrateLimitErr
                                                    ? 'Should be lower than the high limit'
                                                    : null);
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

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final context = this.context;
      bool? isConfirmed = true;

      if (_info?.pressFactorType case final type?
          when type.isEdited &&
              type.value == FactorType.fixed &&
              _adem.hasPressureFactorTypeChangeWarning) {
        isConfirmed = await showDialog<bool>(
          context: context,
          builder: (_) => const _PressureFactorTypeChangeWarningDialog(),
        );
      }

      if (isConfirmed == true && context.mounted) {
        final accessCode = await getAccessCode(context);
        if (accessCode != null) {
          _bloc.add(UpdateData(accessCode, _info!));
        }
      }
    } else {
      await showDialog(
        context: context,
        builder: (_) => const ConfigurationAlertDialog(),
      );
    }
  }
}

class _PressureFactorTypeChangeWarningDialog extends StatelessWidget {
  const _PressureFactorTypeChangeWarningDialog();

  @override
  Widget build(BuildContext context) {
    return SDialogLayout(
      title: 'Pressure Factor Type Changing',
      detail:
          'Pressure Factor Type is changed, all Interval Logs will be CLEANED automatically.\n\nDo you want to continue?',
      isShowCloseButton: false,
      child: Row(
        spacing: 12.0,
        children: [
          Expanded(
            child: SButton.outlined(
              text: 'No',
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          Expanded(
            child: SButton.filled(
              text: 'Yes',
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
  }
}
