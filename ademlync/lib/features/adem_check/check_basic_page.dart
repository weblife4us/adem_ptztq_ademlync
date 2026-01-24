import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'check_basic_page_bloc.dart';
import 'check_basic_page_model.dart';

class CheckBasicPage extends StatefulWidget {
  const CheckBasicPage({super.key});

  @override
  State<CheckBasicPage> createState() => _CheckBasicPageState();
}

class _CheckBasicPageState extends State<CheckBasicPage> {
  late final _bloc = BlocProvider.of<CheckBasicPageBloc>(context);
  CheckBasicPageModel? _info;

  Adem get _adem => AppDelegate().adem;

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
              text: locale.basicString,
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
                            spacing: 24.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 24.0,
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Firmware',
                                      child: SDataField.string(
                                        value: _info!.firmwareVersion,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Checksum',
                                      child: SDataField.string(
                                        value: _info!.firmwareChecksum,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_info?.sealStatus case final status?)
                                SDecoration(
                                  header: 'Seal Status',
                                  child: SText.titleMedium(
                                    status ? 'Sealed' : 'Not Sealed',
                                    color: status
                                        ? colorScheme.connected(context)
                                        : colorScheme.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Gas day start time',
                            child: SDataField.time(
                              value: _info!.gasDayStartTime,
                            ),
                          ),
                        ),
                        if (_adem.isMeterSizeSupported)
                          SCard(
                            child: SDecoration(
                              header: 'Meter Size',
                              child: SText.titleMedium(
                                _info!.meterSize == null
                                    ? noDataString
                                    : '${_info!.meterSize!.serial.displayName} — ${_info!.meterSize!.displayName}',
                              ),
                            ),
                          ),

                        if (_info!.pressUnit != null || _info!.tempUnit != null)
                          SCard(
                            child: Row(
                              spacing: 24.0,
                              children: [
                                if (_info!.pressUnit case final unit?)
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Pressure Unit',
                                      child: SDataField.string(
                                        value: unit.displayName,
                                      ),
                                    ),
                                  ),

                                if (_info!.tempUnit case final unit?)
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Temperature Unit',
                                      child: SDataField.string(
                                        value: unit.displayName,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        SCard(
                          child: SDecoration(
                            child: Column(
                              spacing: 24.0,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SDecoration(
                                  header: 'Corrected Volume',
                                  child: SDataField.digit(
                                    value: _info!.corVol,
                                    param: Param.corVol,
                                  ),
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Full',
                                        child: SDataField.digit(
                                          value: _info!.corFullVol,
                                          param: Param.corFullVol,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'High Resolution',
                                        child: SDataField.digit(
                                          value: _info!.corHighResVol,
                                          param: Param.corHighResVol,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Daily',
                                        child: SDataField.digit(
                                          value: _info!.corDailyVol,
                                          param: Param.corDailyVol,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'Previous Day ',
                                        child: SDataField.digit(
                                          value: _info!.corPrevDayVol,
                                          param: Param.corPrevDayVol,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Unit',
                                        child: SDataField.string(
                                          value: _info!.corVolUnit?.displayName,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'Digits Display',
                                        child: SDataField.string(
                                          value:
                                              _info!.corVolDigits?.displayName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SCard(
                          child: SDecoration(
                            child: Column(
                              spacing: 24.0,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SDecoration(
                                  header: 'Uncorrected Volume',
                                  child: SDataField.digit(
                                    value: _info!.uncVol,
                                    param: Param.uncVol,
                                  ),
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Full',
                                        child: SDataField.digit(
                                          value: _info!.uncFullVol,
                                          param: Param.uncFullVol,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'High Resolution',
                                        child: SDataField.digit(
                                          value: _info!.uncHighResVol,
                                          param: Param.uncHighResVol,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Daily',
                                        child: SDataField.digit(
                                          value: _info!.uncDailyVol,
                                          param: Param.uncDailyVol,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'Previous Day ',
                                        child: SDataField.digit(
                                          value: _info!.uncPrevDayVol,
                                          param: Param.uncPrevDayVol,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  spacing: 24.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Unit',
                                        child: SDataField.string(
                                          value: _info!.uncVolUnit?.displayName,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: SDecoration(
                                        header: 'Digits Display',
                                        child: SDataField.string(
                                          value:
                                              _info!.uncVolDigits?.displayName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_adem.isMeterSizeSupported)
                          SCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Input Pulse Volume Unit',
                                    child: SDataField.string(
                                      value:
                                          _info!.inputPulseVolUnit?.displayName,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!_adem.type.isAdemTq &&
                            (_info!.pressTransType != null ||
                                _info!.pressTransSn != null ||
                                _info!.pressTransRange != null))
                          SCard(
                            child: SDecoration(
                              header: 'Pressure Transducer',
                              headerSuffix: _info!.pressTransType?.displayName,
                              spacing: 24.0,
                              child: Row(
                                spacing: 24.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_info!.pressTransSn case final sn?)
                                    Expanded(
                                      child: SDecoration(
                                        header: 'S/N',
                                        child: SDataField.digit(value: sn),
                                      ),
                                    ),

                                  if (_info!.pressTransRange case final range?)
                                    Expanded(
                                      child: SDecoration(
                                        header: 'Range',
                                        child: SDataField.digit(
                                          value: range,
                                          param: Param.pressTransRange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                        if (!_adem.type.isAdemTq &&
                            (_info!.absPress != null ||
                                _info!.gaugePress != null))
                          SCard(
                            child: Row(
                              spacing: 24.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_info!.absPress case final press?)
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Absolute Pressure',
                                      child: SDataField.digit(
                                        value: press,
                                        param: Param.absPress,
                                      ),
                                    ),
                                  ),

                                if (_info!.gaugePress case final press?)
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Gauge Pressure',
                                      child: SDataField.digit(
                                        value: press,
                                        param: Param.gaugePress,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        SCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SDecoration(
                                  header: 'Gas Temperature',
                                  child: SDataField.digit(
                                    value: _info!.temp,
                                    param: Param.temp,
                                  ),
                                ),
                              ),
                              const Gap(24.0),
                              Expanded(
                                child: SDecoration(
                                  header: 'Case Temperature',
                                  child: SDataField.digit(
                                    value: _info!.caseTemp,
                                    param: Param.caseTemp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Flow Rate',
                            spacing: 24.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Corrected',
                                    child: SDataField.digit(
                                      value: _info!.corFlowRate,
                                      param: Param.corFlowRate,
                                    ),
                                  ),
                                ),
                                const Gap(24.0),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Uncorrected',
                                    child: SDataField.digit(
                                      value: _info!.uncFlowRate,
                                      param: Param.uncFlowRate,
                                    ),
                                  ),
                                ),
                              ],
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
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }
}
