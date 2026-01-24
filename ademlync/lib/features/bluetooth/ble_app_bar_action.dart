import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chore/main_bloc.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/svg_image.dart';
import 'ble_scanning_dialog.dart';

class BleAppBarAction extends StatefulWidget {
  final BuildContext parentContext;

  const BleAppBarAction(this.parentContext, {super.key});

  @override
  State<BleAppBarAction> createState() => _BleAppBarActionState();
}

class _BleAppBarActionState extends State<BleAppBarAction> {
  late final _bloc = BlocProvider.of<MainBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      bloc: _bloc,
      builder: (_, state) {
        final isBtDisconnected =
            state is MBBtDisconnectedState ||
            state is MBBtConnectingState ||
            (state is MBFailedState && state.event is MBBtConnEvent);
        final isAdemReady = state is MBAdemCachedState;

        final color = isBtDisconnected
            ? colorScheme.white(context)
            : isAdemReady
            ? colorScheme.connected(context)
            : colorScheme.accentGold(context);
        final text = isBtDisconnected
            ? locale.tapToConnectString
            : isAdemReady
            ? locale.ademReadyString
            : 'AdEM Key\nConnected';
        final icon = isBtDisconnected
            ? 'bluetooth-square'
            : isAdemReady
            ? 'link'
            : 'unlink';

        return InkWell(
          onTap: () => showBleScanningDialog(widget.parentContext),
          child: Row(
            spacing: 4.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SText.titleSmall(
                  text,
                  color: color,
                  textAlign: TextAlign.center,
                ),
              ),
              SvgImage(icon, color: color),
            ],
          ),
        );
      },
    );
  }
}
