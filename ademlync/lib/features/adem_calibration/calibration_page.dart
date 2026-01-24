import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_list_view.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  late final _bloc = BlocProvider.of<MainBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, state) {
        final isReady = state is MBAdemCachedState;
        Adem? adem;
        bool isSealed = false;
        List<CalibrationItem> items = [];

        if (isReady) {
          adem = AppDelegate().adem;
          isSealed = adem.isSealed;
          items = _getItems(adem);
        }

        return Scaffold(
          appBar: SAppBar.withMenu(
            context,
            text: 'Calibration',
            showBluetoothAction: true,
          ),
          body: SmartBodyLayout(
            child: SListView(
              value: items,
              textBuilder: (o) => o.text,
              iconBuilder: (o) => o.svg,
              onPressed: (o) => context.push(o.location),
              disableChecker: (o) =>
                  _isDisabled(o, adem) || !isReady || isSealed,
              footer:
                  'Calibration is possible only when the seal is disabled and the factor type is \'Live.\'',
            ),
          ),
        );
      },
    );
  }

  bool _isDisabled(CalibrationItem type, Adem? adem) => switch (type) {
    CalibrationItem.dp1Point || CalibrationItem.dp3Point => false,
    CalibrationItem.press1Point ||
    CalibrationItem.press3Point => adem?.pressFactorType == FactorType.fixed,
    CalibrationItem.temp1Point ||
    CalibrationItem.temp3Point => adem?.tempFactorType == FactorType.fixed,
  };

  List<CalibrationItem> _getItems(Adem adem) {
    return switch (adem.type) {
      AdemType.ademS => [],
      AdemType.ademT =>
        adem.isAdem25
            ? [CalibrationItem.temp1Point]
            : [CalibrationItem.temp3Point],
      AdemType.universalT => [CalibrationItem.temp1Point],
      AdemType.ademTq => [
        CalibrationItem.temp1Point,
        CalibrationItem.dp1Point,
        CalibrationItem.dp3Point,
      ],
      AdemType.ademPtz ||
      AdemType.ademPtzR ||
      AdemType.ademR ||
      AdemType.ademMi => [
        CalibrationItem.temp1Point,
        CalibrationItem.press1Point,
        CalibrationItem.press3Point,
      ],
    };
  }
}
