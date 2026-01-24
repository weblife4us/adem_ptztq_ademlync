import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'chore/main_bloc.dart';
import 'l10n/app_localizations.dart';
import 'chore/route_delegate.dart';
import 'utils/app_delegate.dart';
import 'utils/constants.dart';
import 'utils/functions.dart';
import 'utils/theme.dart';
import 'utils/ui_specification.dart';

void main() {
  // Set up orientations
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (_) => AppStateNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final _bloc = MainBloc();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _app.initConnectivity();

    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) => AppStateNotifier().notifyListener());
  }

  @override
  void dispose() {
    _bloc.close();
    _app.connectivityListener.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _app
          ..checkLoginState()
          ..setMainTimer();

        _app.connectivityListener.resume();

        final appState = AppStateNotifier();
        if (appState.isSysAppearance) appState.applySysAppearance();
        if (appState.isSysTextScale) appState.applySysTextScale();
        appState.notifyListener();
        break;

      case AppLifecycleState.paused:
        _app.cancelMainTimer();

        _app.connectivityListener.pause();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDelegate.rootContext ??= context;

    return Consumer<AppStateNotifier>(
      builder: (_, appState, _) {
        return MaterialApp.router(
          title: 'AdEMLync',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: theme(context, isDark: false),
          darkTheme: theme(context, isDark: true),
          themeMode: appState.isSysAppearance
              ? ThemeMode.system
              : appState.isDark
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            // Update the root context
            AppDelegate.rootContext = context;

            // Update the root navigate context
            AppDelegate.rootNavContext = mainNavKey.currentContext;

            // Init the UI specification
            UISpecification();

            return BlocListener<MainBloc, MainState>(
              bloc: _bloc,
              listener: (_, state) async {
                if (state is MBBtConnectedState) {
                  // Start the BT auto disconnect timer
                  _setTimer();
                } else if (state is MBBtDisconnectedState) {
                  // Clean the BT auto disconnect timer
                  _cleanTimer();

                  if (state.isAutoDisconnected) {
                    while (AppDelegate.rootNavContext?.canPop() ?? false) {
                      AppDelegate.rootNavContext?.pop();
                    }

                    AppDelegate.rootNavContext?.go('/setup');

                    if (AppDelegate.rootNavContext?.mounted ?? false) {
                      await showWarningDialog(
                        AppDelegate.rootNavContext!,
                        title: 'Bluetooth Disconnected',
                        detail: 'Please try to connect again.',
                      );
                    }
                  }
                }
              },
              child: BlocProvider.value(
                value: _bloc,
                child: MediaQuery(
                  data: appState.mediaQuery.copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }

  AppDelegate get _app => AppDelegate();

  void _setTimer() {
    _timer = Timer(
      const Duration(seconds: btConnTimeoutInSec),
      () => _bloc.add(MBBtDiscEvent(isAutoDisconnected: true)),
    );
  }

  void _cleanTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
