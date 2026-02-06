import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../chore/managers/app_mode_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/debug_config.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_image.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/svg_image.dart';
import 'menu_bloc.dart';

class SMenu extends StatefulWidget {
  const SMenu({super.key});

  @override
  State<SMenu> createState() => _SMenuState();
}

class _SMenuState extends State<SMenu> {
  late final _mBloc = BlocProvider.of<MainBloc>(context);
  late final _bloc = MenuBloc.init();
  late final _user = _bloc.user;

  @override
  void initState() {
    if (_bloc.state is DataNotReady) _bloc.add(FetchData());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) {
        if (state is FetchDataFailed) {
          _bloc.add(FetchData());
        }
      },
      builder: (_, state) {
        return Drawer(
          width: 240.0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12.0,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _navTo('/menu/account'),
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: Column(
                        spacing: 4.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SText.titleLarge(
                            _user?.role.displayName ?? '-',
                            color: colorScheme.white(context),
                          ),
                          if (_user?.company.isNotEmpty ?? false)
                            SText.titleSmall(
                              (_user?.company ?? '-').toUpperCase(),
                              color: colorScheme
                                  .white(context)
                                  .withValues(alpha: 0.7),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(32.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    width: double.maxFinite,
                    child: Column(
                      spacing: 12.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_mBloc.state is MBAdemCachedState)
                          _MenuItem(
                            icon: 'detail',
                            text: locale.ademDetailString,
                            onPressed: () => _navTo('/menu/ademInfo'),
                          ),
                        _MenuItem(
                          icon: 'setup',
                          text: locale.settingsString,
                          onPressed: () => _navTo('/menu/appSettings'),
                        ),
                        _MenuItem(
                          icon: 'faq',
                          text: locale.faqString,
                          onPressed: () => _navTo('/menu/faq'),
                        ),
                        if (AppModeManager().isDebugMode)
                          _MenuItem(
                            icon: 'setup',
                            text: 'Testing Tools',
                            onPressed: () => _navTo('/menu/btCmdTesting'),
                          ),
                        if (kSLGDebugEnabled)
                          _MenuItem(
                            icon: 'setup',
                            text: 'SLG47011 Debug',
                            onPressed: () => _navTo('/menu/slgDebug'),
                          ),
                        _MenuItem(
                          icon: 'license',
                          text: 'Licenses',
                          onPressed: () => _navTo('/menu/licenses'),
                        ),
                        _MenuItem(
                          icon: 'logout',
                          text: _user?.isLimitedUser ?? false
                              ? locale.switchAccountString
                              : 'Logout',
                          onPressed: _user != null ? signOut : null,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      if (await AppModeManager().showDeveloperMenu() == true) {
                        setState(() {});
                      }
                    },
                    child: const SImage(filename: 'logo_adem', height: 38),
                  ),
                  SText.titleSmall(
                    locale.nVersionString(
                      AppDelegate().version,
                      AppDelegate().buildNumber,
                    ),
                    color: colorScheme.white(context),
                  ),
                  // _MenuItem(
                  //   text: locale.meterListString,
                  //   // onPressed: _pushToMeterPage,
                  //   onPressed: null,
                  // ),
                  // _MenuItem(
                  //   text: locale.aga8MolarListString,
                  //   // onPressed: _pushToAga8MolarListPage,
                  //   onPressed: null,
                  // ), _TitleWithDivide(title: locale.bluetoothString),
                  //     _MenuItem(
                  //       text: locale.dongleSelectionString,
                  //       // onPressed: _pushToBluetoothDongleSelectionPage,
                  //       onPressed: null,
                  //     ),
                  //     _MenuItem(
                  //       text: 'Test CMD',
                  //       onPressed: () {
                  //         context
                  //           ..pop()
                  //           ..push('/menu/testCmd');
                  //       },
                  //     ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navTo(String path) {
    context
      ..pop()
      ..push(path);
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String text;
  final void Function()? onPressed;

  const _MenuItem({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          spacing: 12.0,
          children: [
            SvgImage(icon, width: 24.0, color: colorScheme.white(context)),
            Expanded(
              child: SText(
                text,
                type: STextStyle.titleMedium,
                color: colorScheme.white(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
