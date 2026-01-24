import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../chore/app_init_bloc.dart';
import '../utils/app_delegate.dart';
import '../utils/custom_color_scheme.dart';
import '../utils/widgets/s_image.dart';
import '../utils/widgets/smart_body_layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final _bloc = BlocProvider.of<AppInitBloc>(context);

  @override
  void initState() {
    super.initState();
    _bloc.add(Init());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is Authenticated) {
          await AppDelegate().firstCheckConnectivity();
          if (context.mounted) context.go('/setup');
        } else if (state is Unauthenticated) {
          await AppDelegate().firstCheckConnectivity();
          if (context.mounted) context.go('/signIn', extra: state.isExpired);
        } else if (state is InitializeFailed) {
          _bloc.add(Init());
        }
      },
      child: Scaffold(
        body: SmartBodyLayout(
          scrollEnabled: false,
          horizontalPaddingForMobile: 60.0,
          maxWidth: 380.0,
          heightFactor: null,
          child: SImage.logo(color: colorScheme.logo(context)),
        ),
      ),
    );
  }
}
