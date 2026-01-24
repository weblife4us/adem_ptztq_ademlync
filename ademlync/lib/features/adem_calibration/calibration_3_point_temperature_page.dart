import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'calibration_3_point_temperature_page_bloc.dart';
import 'calibration_3_point_decoration.dart';

class Calibration3PointTemperaturePage extends StatefulWidget {
  const Calibration3PointTemperaturePage({super.key});

  @override
  State<Calibration3PointTemperaturePage> createState() =>
      _Calibration3PointTemperaturePageState();
}

class _Calibration3PointTemperaturePageState
    extends State<Calibration3PointTemperaturePage>
    with CalibrationManager, AccessCodeHelper {
  late final _bloc = BlocProvider.of<Calibration3PointTemperaturePageBloc>(
    context,
  );

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  TempCalib3Pt? _info;
  int _fetchCount = 0;
  bool _isStabled = false;
  UpdateData? _pendingEvent;

  int? _adCountsLow;
  int? _adCountsMid;
  int? _adCountsHigh;
  double? _offsetLow;
  double? _offsetMid;
  double? _offsetHigh;

  Adem get _adem => AppDelegate().adem;

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchData());
  }

  @override
  void dispose() {
    _controller.dispose();
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
            state is DataFetching ||
            _pendingEvent != null;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: GestureDetector(
            onTap: dismissKeyboard,
            child: Scaffold(
              appBar: SAppBar.withSubmit(
                context,
                text: 'Calibration',
                hasAdemInfoAction: isDataReady,
                isLoading: _info == null,
                isSubmitLoading: isLoading,
                onPressed: isDataReady && _isStabled && _isCaptured()
                    ? _submit
                    : null,
              ),
              body: SmartBodyLayout(
                child: isDataReady
                    ? Form(
                        key: _formKey,
                        child: Calibration3PointDecoration(
                          controller: _controller,
                          type: CalibrationItem.temp3Point,
                          count: _fetchCount,
                          param: Param.temp,
                          limit: Param.threePtTempCalibParams.limit(_adem),
                          adCountsLow: _info!.config.adCountsLow,
                          offsetLow: _info!.config.lowPtOffset,
                          newAdCountsLow: _adCountsLow,
                          newOffsetLow: _offsetLow,
                          onPressedLow: (v1, v2) {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _adCountsLow = v1;
                                _offsetLow = v2;
                              });
                            }
                          },
                          adCountsMid: _info!.config.adCountsMid,
                          offsetMid: _info!.config.midPtOffset,
                          newAdCountsMid: _adCountsMid,
                          newOffsetMid: _offsetMid,
                          onPressedMid: (v1, v2) {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _adCountsMid = v1;
                                _offsetMid = v2;
                              });
                            }
                          },
                          adCountsHigh: _info!.config.adCountsHigh,
                          offsetHigh: _info!.config.highPtOffset,
                          newAdCountsHigh: _adCountsHigh,
                          newOffsetHigh: _offsetHigh,
                          onPressedHigh: (v1, v2) {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _adCountsHigh = v1;
                                _offsetHigh = v2;
                              });
                            }
                          },
                          adCounts: _info!.aDReadCounts,
                          isStabled: _isStabled,
                          isDisabled: isLoading || !_isStabled,
                          onChanged: (_) => setState(() {
                            _formKey.currentState?.validate();
                          }),
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

  bool _isCaptured() {
    return [
      _offsetLow,
      _adCountsLow,
      _offsetMid,
      _adCountsMid,
      _offsetHigh,
      _adCountsHigh,
    ].every((e) => e != null);
  }

  Future<void> _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() => _info = state.info);
      if (_pendingEvent != null) _bloc.cancelCommunication();
    } else if (state is StreamDone) {
      if (_pendingEvent != null) {
        _bloc.add(_pendingEvent!);
        _pendingEvent = null;
      }
    } else if (state is DataFetched) {
      setState(() {
        _fetchCount = state.fetchCount;
        _isStabled = state.isStabled;
      });
    } else if (state is DataUpdated) {
      _bloc.add(FetchData(false));
      showToast(context, text: 'Update succeeded.');
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    } else if (state is UpdateDataFailed) {
      await handleError(context, state.error);
      _bloc.add(FetchData(false));
    }
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final config = Calib3PtConfig(
      _offsetLow!,
      _adCountsLow!,
      _offsetMid!,
      _adCountsMid!,
      _offsetHigh!,
      _adCountsHigh!,
    );

    if (!isValidCalib3PtConfig(config)) {
      await showCalibrationWarning(context);
    } else {
      final accessCode = await getAccessCode(context);
      if (accessCode != null) {
        setState(() {
          _pendingEvent = UpdateData(accessCode, _info!.config, config);
        });
      }
    }
  }
}
