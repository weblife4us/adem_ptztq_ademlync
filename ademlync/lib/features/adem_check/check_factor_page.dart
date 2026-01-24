import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'check_factor_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_factor.dart';
import '../../utils/widgets/s_loading.dart';
import 'check_factor_page_bloc.dart';

class CheckFactorPage extends StatefulWidget {
  const CheckFactorPage({super.key});

  @override
  State<CheckFactorPage> createState() => _CheckFactorPageState();
}

class _CheckFactorPageState extends State<CheckFactorPage> {
  late final _bloc = BlocProvider.of<CheckFactorPageBloc>(context);

  CheckFactorPageModel? _info;

  Adem get _adem => AppDelegate().adem;
  FactorType? get _superXFactorType => _adem.measureCache.superXFactorType;

  Param get superXFactorParam => switch (_superXFactorType) {
    FactorType.live => Param.liveSuperXFactor,
    FactorType.fixed => Param.fixedSuperXFactor,
    null => throw UnimplementedError(),
  };

  bool get _isNx19 => _info?.superXAlgo == SuperXAlgo.nx19;
  bool get _isSgerg => _info?.superXAlgo == SuperXAlgo.sgerg88;
  bool get _isAga8G1 => _info?.superXAlgo == SuperXAlgo.aga8G1;
  bool get _isAga8G2 => _info?.superXAlgo == SuperXAlgo.aga8G2;
  bool get _isAga8 => _info?.superXAlgo == SuperXAlgo.aga8;

  bool get _hasSpecificGravity => _isNx19 || _isSgerg || _isAga8G1 || _isAga8G2;
  bool get _hasN2 => _isNx19 || _isAga8G2;
  bool get _hasH2 => _isSgerg;
  bool get _hasCo2 => _isNx19 || _isSgerg || _isAga8G1 || _isAga8G2;
  bool get _hasHs => _isSgerg || _isAga8G1;

  bool get _hasPressFactor =>
      _info!.pressFactorType != null && _info!.pressFactor != null;
  bool get _hasTempFactor =>
      _info!.tempFactorType != null && _info!.tempFactor != null;
  bool get _hasSuperFactor =>
      _info!.superXFactorType != null && _info!.superXFactor != null;

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
              text: 'Factor',
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
                        if (_info?.superXAlgo != null &&
                            _info?.superXFactorType == FactorType.live)
                          SCard(
                            footer: _isAga8
                                ? locale.aga8DetailDescription
                                : null,
                            child: Column(
                              spacing: 24.0,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SDecoration(
                                  header: 'Super X',
                                  headerSuffix: _info!.superXAlgo?.displayName,
                                ),
                                if (_hasSpecificGravity)
                                  SDecoration(
                                    header: 'Specific Gravity',
                                    child: SDataField.digit(
                                      value: _info!.gasSpecificGravity,
                                      param: Param.gasSpecificGravity,
                                    ),
                                  ),
                                if (_hasN2 || _hasH2 || _hasCo2 || _hasHs)
                                  Builder(
                                    builder: (_) {
                                      final widgets = [
                                        if (_hasN2)
                                          SDecoration(
                                            header: 'N<d>2</d>',
                                            child: SDataField.digit(
                                              value: _info!.gasMoleN2,
                                              param: Param.gasMoleN2,
                                            ),
                                          ),
                                        if (_hasH2)
                                          SDecoration(
                                            header: 'H<d>2</d>',
                                            child: SDataField.digit(
                                              value: _info!.gasMoleH2,
                                              param: Param.gasMoleH2,
                                            ),
                                          ),
                                        if (_hasCo2)
                                          SDecoration(
                                            header: 'CO<d>2</d>',
                                            child: SDataField.digit(
                                              value: _info!.gasMoleCO2,
                                              param: Param.gasMoleCO2,
                                            ),
                                          ),
                                        if (_hasHs)
                                          SDecoration(
                                            header: 'Hs',
                                            child: SDataField.digit(
                                              value: _info!.gasMoleHs,
                                              param: Param.gasMoleHs,
                                            ),
                                          ),
                                      ].map((o) => Expanded(child: o)).toList();

                                      return widgets.length < 2
                                          ? Row(
                                              spacing: 24.0,
                                              children: widgets,
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 24.0,
                                              children: [
                                                Row(
                                                  children: widgets
                                                      .getRange(0, 2)
                                                      .toList(),
                                                ),
                                                Row(
                                                  children: widgets
                                                      .getRange(
                                                        2,
                                                        widgets.length,
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        SCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 24.0,
                                children: [
                                  if (_hasPressFactor)
                                    Expanded(
                                      child: SFactor(
                                        text: 'Pressure',
                                        value: _info!.pressFactor!
                                            .toStringAsFixed(
                                              Param.pressFactor.decimal(_adem),
                                            ),
                                        isLive:
                                            _info!.pressFactorType! ==
                                            FactorType.live,
                                      ),
                                    ),
                                  if (_hasTempFactor)
                                    Expanded(
                                      child: SFactor(
                                        text: 'Temperate',
                                        value: _info!.tempFactor!
                                            .toStringAsFixed(
                                              Param.tempFactor.decimal(_adem),
                                            ),
                                        isLive:
                                            _info!.tempFactorType! ==
                                            FactorType.live,
                                      ),
                                    ),
                                  if (_hasSuperFactor)
                                    Expanded(
                                      child: SFactor(
                                        text: 'Super X',
                                        value: _info!.superXFactor!
                                            .toStringAsFixed(
                                              Param.fixedSuperXFactor.decimal(
                                                _adem,
                                              ),
                                            ),
                                        isLive:
                                            _info!.superXFactorType! ==
                                            FactorType.live,
                                      ),
                                    ),
                                ],
                              ),
                              const Gap(12.0),
                              const Divider(),
                              const Gap(12.0),
                              SDecoration(
                                header: 'Total Corrected Factor',
                                child: SDataField.digit(
                                  value: _info!.corTotalFactor,
                                  param: Param.totalFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Base Pressure',
                                      child: SDataField.digit(
                                        value: _info!.basePress,
                                        param: Param.basePress,
                                      ),
                                    ),
                                  ),
                                  const Gap(24.0),
                                  Expanded(
                                    child: SDecoration(
                                      header: 'Base Temperature',
                                      child: SDataField.digit(
                                        value: _info!.baseTemp,
                                        param: Param.baseTemp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(24.0),
                              SDecoration(
                                header: 'Atmospheric Pressure',
                                child: SDataField.digit(
                                  value: _info!.atmosphericPress,
                                  param: Param.atmosphericPress,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SCard(
                          child: SDecoration(
                            header: 'Display Volume Select',
                            child: SDataField.string(
                              value: _info!.dispVolSelect?.displayName,
                              param: Param.dispVolSelect,
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
