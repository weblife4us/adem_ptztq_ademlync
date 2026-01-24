import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'calibration_1_point_decoration.dart';
import 'calibration_1_point_dp_page_bloc.dart';

class Calibration1PointDpPage extends StatefulWidget {
  const Calibration1PointDpPage({super.key});

  @override
  State<Calibration1PointDpPage> createState() =>
      _Calibration1PointDpPageState();
}

class _Calibration1PointDpPageState extends State<Calibration1PointDpPage>
    with AccessCodeHelper {
  late final _bloc = BlocProvider.of<Calibration1PointDpPageBloc>(context);

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  DpCalib1Pt? _info;
  int _fetchCount = 0;
  bool _isStabled = false;
  UpdateData? _pendingEvent;

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
                text: locale.dpString,
                subText: locale.onePointString,
                hasAdemInfoAction: isDataReady,
                isLoading: _info == null,
                isSubmitLoading: isLoading,
                onPressed: isDataReady && _isStabled ? _submit : null,
              ),
              body: SmartBodyLayout(
                child: isDataReady
                    ? Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Calibration1PointDecoration(
                          type: CalibrationItem.dp1Point,
                          controller: _controller,
                          param: Param.diffPress,
                          limit: Param.dpCalib1PtOffset.limit(
                            AppDelegate().adem,
                          ),
                          count: _fetchCount,
                          reading: _info!.dp,
                          offset: _info!.offset,
                          adCounts: _info!.aDReadCounts,
                          isStabled: _isStabled,
                          isDisabled: isLoading || !_isStabled,
                          hasLimitCalculation: false,
                          onEditingComplete: !isLoading && _isStabled
                              ? _submit
                              : null,
                          onChanged: (_) => setState(() {}),
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

  Future<void> _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() => _info = state.info);
      if (_pendingEvent != null) _bloc.cancelCommunication();
    } else if (state is DataFetched) {
      setState(() {
        _fetchCount = state.fetchCount;
        _isStabled = state.isStabled;
      });
    } else if (state is StreamDone) {
      if (_pendingEvent != null) {
        _bloc.add(_pendingEvent!);
        _pendingEvent = null;
      }
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
    if (_formKey.currentState?.validate() ?? false) {
      final accessCode = await getAccessCode(context);
      if (accessCode != null) {
        setState(() {
          _pendingEvent = UpdateData(
            accessCode,
            double.parse(_controller.text),
            _info!.dp,
            _info!.offset,
          );
        });
      }
    }
  }
}
