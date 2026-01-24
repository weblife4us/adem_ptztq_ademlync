import 'package:ademlync_device/utils/adem_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'check_battery_page_bloc.dart';
import 'check_battery_page_model.dart';

class CheckBatteryPage extends StatefulWidget {
  const CheckBatteryPage({super.key});

  @override
  State<CheckBatteryPage> createState() => _CheckBatteryPageState();
}

class _CheckBatteryPageState extends State<CheckBatteryPage> {
  late final _bloc = BlocProvider.of<CheckBatteryPageBloc>(context);
  CheckBatteryPageModel? _info;

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
              text: locale.batteryString,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SDecoration(
                                header:
                                    '${_info!.batteryType?.displayName ?? 'Unknown'} Battery (${_info!.batteryVoltage == null ? 'Unknown' : '${_info!.batteryVoltage} V'})',
                                child: _info!.batteryRemaining == null
                                    ? null
                                    : SText.titleMedium(
                                        '${_info!.batteryRemaining} %',
                                      ),
                              ),
                              const Gap(24.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Install Date',
                                      child: SDataField.date(
                                        value: _info!.batteryInstallDate,
                                        param: Param.batteryInstallDate,
                                      ),
                                    ),
                                  ),
                                  const Gap(24.0),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Life',
                                      child: SText.titleMedium(
                                        '${_info!.batteryLife} Months',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SText.bodyMedium('Output Pulse'),
                              const Gap(24.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Spacing',
                                      child: SDataField.string(
                                        value: _info!
                                            .outputPulseSpacing
                                            ?.displayName,
                                      ),
                                    ),
                                  ),
                                  const Gap(24.0),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Width',
                                      child: SDataField.string(
                                        value: _info!
                                            .outputPulseWidth
                                            ?.displayName,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(24.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Corrected Unit',
                                      child: SDataField.string(
                                        value: _info!
                                            .corOutputPulseVolUnit
                                            ?.displayName,
                                      ),
                                    ),
                                  ),
                                  const Gap(24.0),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Uncorrected Unit',
                                      child: SDataField.string(
                                        value: _info!
                                            .uncOutputPulseVolUnit
                                            ?.displayName,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: SDecoration(
                                  header: 'Pressure Display Resolution',
                                  child: SDataField.string(
                                    value: _info!.pressDispRes?.displayName,
                                  ),
                                ),
                              ),
                              const Gap(24.0),
                              Expanded(
                                child: SDecoration(
                                  header: 'Display Test Pattern',
                                  child: SDataField.string(
                                    value: _info!.dispTestPattern,
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
