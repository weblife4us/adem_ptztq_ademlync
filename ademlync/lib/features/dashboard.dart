import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../chore/main_bloc.dart';
import '../utils/app_delegate.dart';
import '../utils/widgets/s_bottom_navigation_bar.dart';
import 'side_menu/menu.dart';

class Dashboard extends StatefulWidget {
  final Widget child;

  const Dashboard({super.key, required this.child});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<MainBloc>(context),
      builder: (_, state) {
        final items = [
          NavBarItem.setup,
          NavBarItem.check,
          if (state is MBAdemCachedState && !AppDelegate().adem.type.isAdemS)
            NavBarItem.calibration,
          NavBarItem.dpCalculator,
          NavBarItem.logs,
          NavBarItem.cloud,
        ];

        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: const SMenu(),
          drawerEnableOpenDragGesture: false,

          body: Stack(
            alignment: AlignmentGeometry.bottomCenter,
            children: [
              widget.child,

              SBottomNavigationBar(
                items: items,
                active: NavBarItem.setup,
                onChanged: context.go,
              ),
            ],
          ),
        );
      },
    );
  }
}
