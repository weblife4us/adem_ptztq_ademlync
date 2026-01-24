import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_index_wrap.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'check_display_page_bloc.dart';
import 'check_display_page_model.dart';

class CheckDisplayPage extends StatefulWidget {
  const CheckDisplayPage({super.key});

  @override
  State<CheckDisplayPage> createState() => _CheckDisplayPageState();
}

class _CheckDisplayPageState extends State<CheckDisplayPage> {
  late final _bloc = BlocProvider.of<CheckDisplayPageBloc>(context);

  CheckDisplayPageModel? _info;

  Adem get _adem => AppDelegate().adem;

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
              text: locale.displayString,
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
                        if (AppDelegate().adem.isAdem25)
                          SCard(
                            child: SDecoration(
                              header: 'Product Type',
                              child: SDataField.string(
                                value: _info!.productType,
                              ),
                            ),
                          ),

                        SCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SDecoration(
                                header: 'Interval Log',
                                headerSuffix: _info!.intervalType?.displayName,
                                child: _info!.intervalSetting != null
                                    ? SText.bodyMedium(
                                        _info!.intervalSetting!.displayName,
                                        color: colorScheme.grey,
                                      )
                                    : null,
                              ),
                              if (_info!.intervalType ==
                                      IntervalLogType.selectableFields &&
                                  _info!.intervalFields != null) ...[
                                const Gap(24.0),
                                SIndexWrap(
                                  value: _info!.intervalFields!
                                      .map((o) => o?.displayName ?? 'Not Set')
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_info!.pulseChannels.isNotEmpty)
                          SCard(
                            child: SDecoration(
                              header: 'Output Pulse Channel',
                              spacing: 24.0,
                              child: SIndexWrap(
                                value: _info!.pulseChannels
                                    .map((o) => o?.displayName ?? 'Not Set')
                                    .toList(),
                              ),
                            ),
                          ),
                        if (_info!.cstmDispParams.isNotEmpty)
                          SCard(
                            child: SDecoration(
                              header: 'Custom Display Field',
                              spacing: 24.0,
                              child: SIndexWrap(
                                value: _info!.cstmDispParams.map((o) {
                                  final param = o?.toParam(_adem);
                                  return param != null && param != Param.unknown
                                      ? param.displayName
                                      : 'Not Set';
                                }).toList(),
                              ),
                            ),
                          ),
                        SCard(
                          child: SDecoration(
                            header: 'Displacement',
                            child: SDataField.digit(
                              value: _info!.displacement,
                              param: Param.displacement,
                            ),
                          ),
                        ),
                        if (_info!.isProvingPulsesEnabled case bool isEnabled)
                          SCard(
                            child: Column(
                              spacing: 12.0,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SText.bodyMedium('Push Button'),
                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header:
                                            'Proving and Pulses\nOutput Functions',
                                        child: SText.titleMedium(
                                          isEnabled ? 'Enabled' : 'Disabled',
                                          textAlign: TextAlign.end,
                                          color: isEnabled
                                              ? colorScheme.connected(context)
                                              : colorScheme.grey,
                                        ),
                                      ),
                                    ),
                                    if (_adem.isAdem25)
                                      Expanded(
                                        child: SDecoration(
                                          header:
                                              Param.provingTimeout.displayName,
                                          child: SDataField.digit(
                                            value: _info!.provingTimeout,
                                            param: Param.provingTimeout,
                                          ),
                                        ),
                                      ),
                                  ],
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
