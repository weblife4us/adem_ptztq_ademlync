import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_display_page_bloc.dart';
import 'setup_display_page_model.dart';

class SetupDisplayPage extends StatefulWidget {
  const SetupDisplayPage({super.key});

  @override
  State<SetupDisplayPage> createState() => _SetupDisplayPageState();
}

class _SetupDisplayPageState extends State<SetupDisplayPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupDisplayPageBloc>(context);
  final _formKey = GlobalKey<FormState>();

  SetupDisplayPageModel? _info;

  final _provingTimeoutTEController = TextEditingController();
  final _displacementTEController = TextEditingController();

  Adem get _adem => AppDelegate().adem;

  bool get _isSelectableFields =>
      _info?.intervalLogType?.value == IntervalLogType.selectableFields;

  @override
  void initState() {
    _bloc.add(FetchData());
    super.initState();
  }

  @override
  void dispose() {
    _provingTimeoutTEController.dispose();
    _displacementTEController.dispose();
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
                text: locale.displayString,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (AppDelegate().adem.isAdem25)
                              SCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Product Type',
                                        child: SDataField.string(
                                          value: _info!.productType,
                                        ),
                                      ),
                                    ),

                                    if (_info!.isAdemR?.value
                                        case final isAdemR?)
                                      Opacity(
                                        opacity: isLoading ? 0.5 : 1.0,
                                        child: RadioGroup(
                                          groupValue: isAdemR,
                                          onChanged: (v) {
                                            if (isLoading || v == null) return;
                                            setState(
                                              () => _info!.isAdemR?.value = v,
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: true,
                                                activeColor: colorScheme
                                                    .accentGold(context),
                                              ),
                                              const SText.titleMedium('R'),

                                              const Gap(4.0),

                                              Radio(
                                                value: false,
                                                activeColor: colorScheme
                                                    .accentGold(context),
                                              ),
                                              const SText.titleMedium('Mi'),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            SCard(
                              footer:
                                  _adem.type != AdemType.ademS &&
                                      _adem.type != AdemType.ademT
                                  ? 'Updating type/fields will clear all logs'
                                  : null,
                              child: SDecoration(
                                header: 'Interval Log',
                                spacing: 24.0,
                                child: Column(
                                  spacing: 12.0,
                                  children: [
                                    if (_info!.intervalLogInterval != null) ...[
                                      SDataField.dropdown(
                                        param: Param.intervalLogInterval,
                                        value:
                                            _info!.intervalLogInterval!.value,
                                        list: IntervalLogInterval.values,
                                        isEdited: _info!
                                            .intervalLogInterval!
                                            .isEdited,
                                        isDisable: isLoading,
                                        stringBuilder: (v) => v.displayName,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() {
                                              _info!
                                                      .intervalLogInterval!
                                                      .value =
                                                  v;
                                            });
                                          }
                                        },
                                      ),
                                      const Gap(0.0),
                                    ],
                                    if (_info!.intervalLogType != null)
                                      _adem.type != AdemType.ademS &&
                                              _adem.type != AdemType.ademT
                                          ? SDataField.dropdown(
                                              title: 'Type',
                                              param: Param.intervalLogType,
                                              value:
                                                  _info!.intervalLogType!.value,
                                              list: IntervalLogType.values,
                                              isEdited: _info!
                                                  .intervalLogType!
                                                  .isEdited,
                                              isDisable: isLoading,
                                              stringBuilder: (v) =>
                                                  v.displayName,
                                              onChanged: (v) {
                                                if (v != null) {
                                                  setState(() {
                                                    _info!
                                                            .intervalLogType!
                                                            .value =
                                                        v;
                                                  });
                                                }
                                              },
                                            )
                                          : SDataField.string(
                                              param: Param.intervalLogType,
                                              value: _info!
                                                  .intervalLogType!
                                                  .value
                                                  .displayName,
                                            ),
                                    if (_isSelectableFields) ...[
                                      const Divider(),
                                      Column(
                                        spacing: 12.0,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (
                                            var i = 0;
                                            i < _info!.intervalLogField.length;
                                            i++
                                          )
                                            if (_info!.intervalLogField[i] !=
                                                null)
                                              SDataField.dropdown(
                                                title: i == 0
                                                    ? 'Field ${i + 5} (Required)'
                                                    : 'Field ${i + 5}',
                                                value: _info!
                                                    .intervalLogField[i]!
                                                    .value,
                                                index: i + 1,
                                                list: List.of(
                                                  IntervalLogField.values,
                                                ),
                                                isEdited: _info!
                                                    .intervalLogField[i]!
                                                    .isEdited,
                                                footer: i == 0
                                                    ? 'Required'
                                                    : null,
                                                isDisable: isLoading,
                                                stringBuilder: (v) =>
                                                    v.displayName,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _info!
                                                              .intervalLogField[i]!
                                                              .value =
                                                          v;
                                                    });
                                                  }
                                                },
                                              ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (_info!.pulseChannel3 != null)
                              SCard(
                                child: SDecoration(
                                  header: 'Output Pulse Channel 3',
                                  child: SDataField.dropdown(
                                    value: _info!.pulseChannel3!.value,
                                    list: PulseChannel.values,
                                    isEdited: _info!.pulseChannel3!.isEdited,
                                    stringBuilder: (v) => v.displayName,
                                    isDisable: isLoading,
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          _info!.pulseChannel3!.value = v;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            SCard(
                              child: SDecoration(
                                header: 'Custom Display Fields',
                                spacing: 24.0,
                                child: Column(
                                  spacing: 12.0,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < _info!.cstmDispParams.length;
                                      i++
                                    )
                                      if (_info?.cstmDispParams[i] != null)
                                        SDataField.dropdown(
                                          title: 'Field ${i + 1}',
                                          value:
                                              _adem.customDisplayParams
                                                  .contains(
                                                    _info!
                                                        .cstmDispParams[i]!
                                                        .value,
                                                  )
                                              ? _info!.cstmDispParams[i]!.value
                                              : CustDispItem.notSet,
                                          index: i + 1,
                                          list: [
                                            ..._adem.customDisplayParams
                                                .toList()
                                              ..sort(
                                                (a, b) => a
                                                    .toParam(_adem)
                                                    .displayName
                                                    .compareTo(
                                                      b
                                                          .toParam(_adem)
                                                          .displayName,
                                                    ),
                                              ),
                                            CustDispItem.notSet,
                                          ],
                                          isEdited: _info!
                                              .cstmDispParams[i]!
                                              .isEdited,
                                          stringBuilder: (v) {
                                            final param = v.toParam(_adem);
                                            return param == Param.unknown
                                                ? 'Not Set'
                                                : param.displayName;
                                          },
                                          isDisable: isLoading,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _info!
                                                        .cstmDispParams[i]!
                                                        .value =
                                                    v;
                                              });
                                            }
                                          },
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            if (_info!.isProvingPulsesEnabled
                                case ValueTracker<bool> tracker)
                              SCard(
                                child: Column(
                                  spacing: 12.0,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SText.bodyMedium('Push Button'),
                                    SDecoration(
                                      header:
                                          'Proving and Pulses\nOutput Functions',
                                      child: SDataField.dropdown(
                                        value: tracker.value,
                                        list: const [true, false],
                                        isEdited: tracker.isEdited,
                                        stringBuilder: (v) =>
                                            v ? 'Enabled' : 'Disabled',
                                        isDisable: isLoading,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => tracker.value = v);
                                          }
                                        },
                                      ),
                                    ),
                                    if (_info!.provingTimeout?.isEdited
                                        case final isEdited?
                                        when _adem.isAdem25)
                                      SDecoration(
                                        header:
                                            Param.provingTimeout.displayName,
                                        child: SDataField.digitEdit(
                                          controller:
                                              _provingTimeoutTEController,
                                          param: Param.provingTimeout,
                                          isEnabled: !isLoading,
                                          isEdited: isEdited,
                                          onChanged: (v) {
                                            if (v == null) return;

                                            setState(
                                              () =>
                                                  _info!.provingTimeout!.value =
                                                      v.toInt(),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            if (_info!.displacement case final tracker?
                                when AppDelegate().user?.isSuperAdmin ?? false)
                              SCard(
                                child: SDecoration(
                                  header: 'Displacement',
                                  child: SDataField.digitEdit(
                                    controller: _displacementTEController,
                                    param: Param.displacement,
                                    isEnabled: !isLoading,
                                    isEdited: tracker.isEdited,
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          tracker.value = v.toDouble();
                                        });
                                      }
                                    },
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
    if (state is DataReady) {
      setState(() => _info = state.info);

      if (_info!.provingTimeout?.value case final value? when _adem.isAdem25) {
        _provingTimeoutTEController.text = value.toString();
      }
      if (_info!.displacement?.value case final value?) {
        _displacementTEController.text = dataToString(
          value,
          Param.displacement,
        );
      }
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

    if (_isValid()) {
      if ((_formKey.currentState?.validate() ?? false)) {
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
    } else {
      await showDialog(
        context: context,
        builder: (_) => const ConfigurationAlertDialog(
          message: 'The first interval log field cannot be not set.',
        ),
      );
    }
  }

  bool _isValid() {
    return !_isSelectableFields ||
        (_info?.intervalLogField.first != null &&
            _info?.intervalLogField.first?.value != IntervalLogField.notSet);
  }
}
