import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/configuration_alert_dialog.dart';
import '../../utils/widgets/s_aga8.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'setup_aga8_detail_page_bloc.dart';
import 'setup_aga8_detail_page_model.dart';

class SetupAga8Page extends StatefulWidget {
  const SetupAga8Page({super.key});

  @override
  State<SetupAga8Page> createState() => _SetupAga8PageState();
}

class _SetupAga8PageState extends State<SetupAga8Page> with AccessCodeHelper {
  late final _bloc = BlocProvider.of<SetupAga8PageBloc>(context);

  SetupAga8DetailPageModel? _info;
  SetupAga8DetailPageModel? _cInfo;
  final Map<Aga8Param, TextEditingController> _textEditingControllers = {};

  double get _total => double.parse(
    _cInfo!.percentiles.values
        .fold<double>(0, (prev, cur) => prev + cur)
        .toStringAsFixed(2),
  );

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData());

    for (var e in Aga8Param.values) {
      _textEditingControllers[e] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var e in _textEditingControllers.entries) {
      e.value.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isDataReady = _info != null && _cInfo != null;
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
                text: locale.aga8DetailString,
                hasAdemInfoAction: isDataReady,
                isLoading: _info == null,
                isSubmitLoading: isDataReady && isLoading,
                onPressed: isDataReady ? _submitForm : null,
              ),
              body: SmartBodyLayout(
                child: isDataReady
                    ? SCard(
                        child: Column(
                          children: [
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (_, i) {
                                final o = Aga8Param.values[i];

                                return SDecoration(
                                  header: o.displayName,
                                  // headerSuffix: o.formula,
                                  subHeader: o.limits.toDisplay(2),
                                  child: SDataField.digitEdit(
                                    param: Param.aga8GasComponentMolar,
                                    controller: _textEditingControllers[o],
                                    isEnabled: !isLoading,
                                    limit: o.limits,
                                    isEdited:
                                        _cInfo!.percentiles[o] !=
                                        _info!.percentiles[o],
                                    textInputAction: o != Aga8Param.values.last
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    onChanged: (val) => setState(() {
                                      if (val != null) {
                                        _cInfo!.percentiles[o] = val.toDouble();
                                      }
                                    }),
                                  ),
                                );
                              },
                              separatorBuilder: (_, _) => const Gap(12.0),
                              itemCount: Aga8Param.values.length,
                            ),
                            const Divider(height: 24.0),
                            SAga8(
                              text: 'Total',
                              value: _total.toStringAsFixed(2),
                              formula: '',
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
    _cInfo = _info!.copyWith(percentiles: Map.of(_info!.percentiles));

    for (var e in _textEditingControllers.entries) {
      e.value.text = _cInfo!.percentiles[e.key]!.toStringAsFixed(2);
    }
  }

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_total == 100) {
      final accessCode = await getAccessCode(context);
      if (accessCode != null) {
        _bloc.add(UpdateData(accessCode, _cInfo!));
      }
    } else {
      await showDialog(
        context: context,
        builder: (_) =>
            const ConfigurationAlertDialog(message: 'Total value must be 100.'),
      );
    }
  }
}
