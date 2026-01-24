import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'check_q_monitor_group_page_bloc.dart';
import 'check_q_monitor_group_page_model.dart';

class CheckQMonitorGroupPage extends StatefulWidget {
  const CheckQMonitorGroupPage({super.key});

  @override
  State<CheckQMonitorGroupPage> createState() => _CheckQMonitorGroupPageState();
}

class _CheckQMonitorGroupPageState extends State<CheckQMonitorGroupPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<CheckQMonitorGroupPageBloc>(context);

  CheckQMonitorGroupPageModel? _info;

  bool get _isDataReady => _info != null;

  DateTime? get _dpTxdrMalfDateTime =>
      combineDateTime(_info!.dpTxdrMalfDate, _info!.dpTxdrMalfTime);

  @override
  void initState() {
    super.initState();

    _bloc.add(InfoFetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: _listener,
      child: SPopScope(
        isCommunicating: _bloc.isCommunicating,
        cancelCommunication: () => _bloc.cancelCommunication(),
        child: Scaffold(
          appBar: SAppBar.withSubmit(
            context,
            text: locale.qMonitorGroupString,
            hasAdemInfoAction: _isDataReady,
            isLoading: _info == null,
          ),
          body: SmartBodyLayout(
            child: _isDataReady
                ? Column(
                    spacing: 24.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SCard(
                        child: SDecoration(
                          header: 'Q Monitor Function',
                          child: SDataField.string(
                            value: _info?.qMonitorFunction ?? false
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
                            SDecoration(
                              header: 'Differential Pressure',
                              child: SDataField.digit(
                                value: _info?.diffPress,
                                param: Param.diffPress,
                              ),
                            ),
                            Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Trans. Malf.',
                                    child:
                                        _info?.isDpTxdrMalf == true &&
                                            _dpTxdrMalfDateTime != null
                                        ? SDataField.dateTime(
                                            param: Param.dpTxdrMalfDate,
                                            value: _info!.dpTxdrMalfDate!,
                                          )
                                        : SDataField.alarm(
                                            param: Param.isDpTxdrMalf,
                                            value: _info?.isDpTxdrMalf ?? false,
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Test Pressure',
                                    child: SDataField.digit(
                                      value: _info?.dpTestPressure,
                                      param: Param.dpTestPressure,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Sensor S/N',
                                    child: SDataField.string(
                                      value: _info?.dpSensorSn,
                                      param: Param.dpSensorSn,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Sensor Range',
                                    child: SDataField.digit(
                                      value: _info?.dpSensorRange,
                                      param: Param.dpSensorRange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SDecoration(
                              header: 'Min. Allow Flow Rate',
                              child: SDataField.digit(
                                value: _info?.minAllowFlowRate,
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
                            Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Q Coefficient A',
                                    child: SDataField.digit(
                                      value: _info?.qCoefficientA!,
                                      param: Param.qCoefficientA,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Q Coefficient C',
                                    child: SDataField.digit(
                                      value: _info?.qCoefficientC!,
                                      param: Param.qCoefficientC,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 24.0,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Q Safety Multiplier',
                                    child: SDataField.digit(
                                      value: _info?.qSafetyMultiplier!,
                                      param: Param.qSafetyMultiplier,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SDecoration(
                                    header: 'Differential Uncertainty',
                                    child: SDataField.digit(
                                      value: _info?.diffUncertainty,
                                      param: Param.diffUncertainty,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SCard(
                        child: SDecoration(
                          header: 'Q Cutoff Temperature',
                          spacing: 24.0,
                          child: Column(
                            spacing: 24.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 24.0,
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Line Gauge Pressure',
                                      child: SDataField.digit(
                                        value: _info?.lineGaugePress,
                                        param: Param.lineGaugePress,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Atmospheric Pressure',
                                      child: SDataField.digit(
                                        value: _info?.atmosphericPress,
                                        param: Param.atmosphericPress,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SDecoration(
                                header: 'Specific Gravity',
                                child: SDataField.digit(
                                  value: _info?.gasSpecificGravity,
                                  param: Param.gasSpecificGravity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SCard(
                        child: SDecoration(
                          header: 'Q Cutoff Temperature',
                          spacing: 24.0,
                          child: Row(
                            spacing: 12.0,
                            children: [
                              Expanded(
                                child: SDecoration(
                                  header: 'High',
                                  child: SDataField.digit(
                                    value: _info!.qCutoffTempHigh,
                                    param: Param.qCutoffTempHigh,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SDecoration(
                                  header: 'Low',
                                  child: SDataField.digit(
                                    value: _info?.qCutoffTempLow,
                                    param: Param.qCutoffTempLow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SLoading(),
          ),
        ),
      ),
    );
  }

  Future<void> _listener(BuildContext context, Object? state) async {
    switch (state) {
      case InfoFetched(:CheckQMonitorGroupPageModel info):
        setState(() => _info = info);

      case Failure(:Object error):
        await handleError(context, error);
        if (context.mounted && context.canPop()) context.pop();
    }
  }
}
