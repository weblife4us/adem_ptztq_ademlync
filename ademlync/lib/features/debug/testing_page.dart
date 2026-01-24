import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chore/main_bloc.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../bluetooth/ble_app_bar_action.dart';
// import 'stress_test.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({super.key});

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> with AdemActionHelper {
  late final _bloc = BlocProvider.of<MainBloc>(context);

  // final _stressTest = StressTest();
  String? _return;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      bloc: _bloc,
      builder: (_, state) {
        return SPopScope(
          isCommunicating: isCommunicating,
          cancelCommunication: () => cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar(
              text: 'Testing Tools',
              actions: [BleAppBarAction(context)],
            ),
            body: SmartBodyLayout(
              child: Column(
                spacing: 8.0,
                children: [
                  // NOTE: For developer dynamic test
                  // SButton.filled(
                  //   text: 'combine',
                  //   onPressed: () async {},
                  // ),
                  // SButton.filled(
                  //   text: 'Read All Params',
                  //   onPressed: _stressTest.readAllParams,
                  // ),
                  // SButton.filled(
                  //   text: 'Start Stress Test',
                  //   onPressed: _stressTest.isStarted
                  //       ? null
                  //       : () => setState(_stressTest.startTimer),
                  // ),
                  // SButton.filled(
                  //   text: 'Stop Stress Test',
                  //   onPressed: _stressTest.isStarted
                  //       ? () => setState(_stressTest.stopTimer)
                  //       : null,
                  // ),
                  // SButton.filled(
                  //   text: 'Force Disconnection',
                  //   onPressed: () async =>
                  //       await AdemManager().disconnect(isForced: true),
                  // ),
                  Column(
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Item Number (3 Digits)',
                        ),
                        textInputAction: TextInputAction.send,
                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                        onSubmitted: (v) async {
                          final res = await fetchByItemNumber(v);
                          setState(() => _return = res);
                        },
                      ),

                      Text('Return: ${_return ?? 'No Return'}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
