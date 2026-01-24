import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../utils/enums.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_list_view.dart';

class LimitedUserDashboard extends StatefulWidget {
  const LimitedUserDashboard({super.key});

  @override
  State<LimitedUserDashboard> createState() => _LimitedUserDashboardState();
}

class _LimitedUserDashboardState extends State<LimitedUserDashboard> {
  late final _bloc = BlocProvider.of<MainBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, state) {
        final isAdemReady = state is MBAdemCachedState;

        return Scaffold(
          appBar: SAppBar.withMenu(
            context,
            text: 'Limited',
            showBluetoothAction: true,
          ),
          body: SmartBodyLayout(
            child: SListView(
              value: LimitedItem.values,
              textBuilder: (o) => o.text,
              iconBuilder: (o) => o.svg,
              onPressed: isAdemReady
                  ? (o) async => await context.push((o as LimitedItem).location)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
