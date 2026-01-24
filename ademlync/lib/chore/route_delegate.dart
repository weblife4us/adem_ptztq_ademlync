import 'dart:async';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_cloud/models/user_created_status.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/adem_calibration/calibration_1_point_dp_page.dart';
import '../features/adem_calibration/calibration_1_point_dp_page_bloc.dart';
import '../features/adem_calibration/calibration_1_point_pressure_page.dart';
import '../features/adem_calibration/calibration_1_point_pressure_page_bloc.dart';
import '../features/adem_calibration/calibration_1_point_temperature_page.dart';
import '../features/adem_calibration/calibration_1_point_temperature_page_bloc.dart';
import '../features/adem_calibration/calibration_3_point_dp_page.dart';
import '../features/adem_calibration/calibration_3_point_dp_page_bloc.dart';
import '../features/adem_calibration/calibration_3_point_pressure_page.dart';
import '../features/adem_calibration/calibration_3_point_pressure_page_bloc.dart';
import '../features/adem_calibration/calibration_3_point_temperature_page.dart';
import '../features/adem_calibration/calibration_3_point_temperature_page_bloc.dart';
import '../features/adem_calibration/calibration_page.dart';
import '../features/adem_check/check_aga8_page.dart';
import '../features/adem_check/check_aga8_page_bloc.dart';
import '../features/adem_check/check_alarm_page.dart';
import '../features/adem_check/check_alarm_page_bloc.dart';
import '../features/adem_check/check_basic_page.dart';
import '../features/adem_check/check_basic_page_bloc.dart';
import '../features/adem_check/check_battery_page.dart';
import '../features/adem_check/check_battery_page_bloc.dart';
import '../features/adem_check/check_display_page.dart';
import '../features/adem_check/check_display_page_bloc.dart';
import '../features/adem_check/check_factor_page.dart';
import '../features/adem_check/check_factor_page_bloc.dart';
import '../features/adem_check/check_page.dart';
import '../features/adem_check/check_q_monitor_group_page.dart';
import '../features/adem_check/check_q_monitor_group_page_bloc.dart';
import '../features/adem_check/check_statistic_page.dart';
import '../features/adem_check/check_statistic_page_bloc.dart';
import '../features/adem_config/adem_config.dart';
import '../features/adem_config/config_detail_page.dart';
import '../features/adem_config/configs_page.dart';
import '../features/adem_config/configs_page_bloc.dart';
import '../features/adem_detail/adem_detail_page.dart';
import '../features/adem_detail/adem_detail_page_bloc.dart';
import '../features/adem_log/log_alarm_page.dart';
import '../features/adem_log/log_alarm_page_bloc.dart';
import '../features/adem_log/log_daily_page.dart';
import '../features/adem_log/log_daily_page_bloc.dart';
import '../features/adem_log/log_event_page.dart';
import '../features/adem_log/log_event_page_bloc.dart';
import '../features/adem_log/log_flow_dp_page.dart';
import '../features/adem_log/log_flow_dp_page_bloc.dart';
import '../features/adem_log/log_interval_page.dart';
import '../features/adem_log/log_interval_page_bloc.dart';
import '../features/adem_log/log_page.dart';
import '../features/adem_log/log_q_page.dart';
import '../features/adem_log/log_q_page_bloc.dart';
import '../features/adem_setup/setup_aga8_detail_page.dart';
import '../features/adem_setup/setup_aga8_detail_page_bloc.dart';
import '../features/adem_setup/setup_basic_page.dart';
import '../features/adem_setup/setup_basic_page_bloc.dart';
import '../features/adem_setup/setup_display_page.dart';
import '../features/adem_setup/setup_display_page_bloc.dart';
import '../features/adem_setup/setup_page.dart';
import '../features/adem_setup/setup_press_and_temp_page.dart';
import '../features/adem_setup/setup_press_and_temp_page_bloc.dart';
import '../features/adem_setup/setup_q_monitor_group_page.dart';
import '../features/adem_setup/setup_q_monitor_group_page_bloc.dart';
import '../features/adem_setup/setup_statistic_page.dart';
import '../features/adem_setup/setup_statistic_page_bloc.dart';
import '../features/app_settings_page.dart';
import '../features/cloud_service/cloud_page.dart';
import '../features/cloud_service/download_file_page.dart';
import '../features/cloud_service/download_file_page_bloc.dart';
import '../features/cloud_service/upload_file_page.dart';
import '../features/cloud_service/upload_file_page_bloc.dart';
import '../features/dashboard.dart';
import '../features/debug/testing_page.dart';
import '../features/dp_calculator/dp_calculator_bloc.dart';
import '../features/dp_calculator/dp_calculator_page.dart';
import '../features/faq_page.dart';
import '../features/file_export/export_bloc.dart';
import '../features/licenses/licenses_page.dart';
import '../features/licenses/licenses_page_bloc.dart';
import '../features/meter_list_page.dart';
import '../features/mfa/mfa_bloc.dart';
import '../features/mfa/mfa_instruction_page.dart';
import '../features/mfa/mfa_setup_page.dart';
import '../features/side_menu/menu.dart';
import '../features/splash_page.dart';
import '../features/user/user_bloc.dart';
import '../features/user/user_page.dart';
import '../features/user/user_page_bloc.dart';
import '../features/user/users_page.dart';
import '../features/user_create/user_create_page.dart';
import '../features/user_create/user_created_detail_page.dart';
import '../features/user_login/forgot_password_page.dart';
import '../features/user_login/login_page.dart';
import '../features/view_as_guest/custom_display_page.dart';
import '../features/view_as_guest/custom_display_page_bloc.dart';
import '../features/view_as_guest/limited_user_dashboard.dart';
import '../utils/app_delegate.dart';
import '../utils/enums.dart';
import 'app_init_bloc.dart';

final mainNavKey = GlobalKey<NavigatorState>();
final _dashboardNavKey = GlobalKey<NavigatorState>();
final _limitedViewDashboardNavKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: mainNavKey,
  routes: [
    // Splash page
    GoRoute(
      path: '/',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) =>
          BlocProvider(create: (_) => AppInitBloc(), child: const SplashPage()),
    ),

    // Sign in page
    GoRoute(
      path: '/signIn',
      parentNavigatorKey: mainNavKey,
      pageBuilder: (_, state) => CustomTransitionPage(
        child: BlocProvider(
          create: (_) => UserBloc(),
          child: LoginPage(isCredExpired: state.extra as bool?),
        ),
        transitionDuration: const Duration(milliseconds: 500),
        fullscreenDialog: true,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
      routes: [
        GoRoute(
          path: 'forgotPassword',
          parentNavigatorKey: mainNavKey,
          builder: (_, _) => BlocProvider(
            create: (_) => UserBloc(),
            child: const ForgotPasswordPage(),
          ),
        ),
      ],
    ),

    GoRoute(
      path: '/cloud/user/register',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => BlocProvider(
        create: (_) => UserBloc(),
        child: const UserCreatePage(),
      ),
    ),

    GoRoute(
      path: '/cloud/user/manage',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) =>
          BlocProvider(create: (_) => UserBloc(), child: const UsersPage()),
    ),

    // Account page
    GoRoute(
      path: '/menu/account',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) =>
          BlocProvider(create: (_) => UserPageBloc(), child: const UserPage()),
      routes: [
        GoRoute(
          path: 'create-detail',
          builder: (_, state) {
            return UserCreatedDetailPage(
              status: state.extra as UserCreatedStatus,
            );
          },
        ),
      ],
    ),

    // AdEM information page
    GoRoute(
      parentNavigatorKey: mainNavKey,
      path: '/menu/ademInfo',
      builder: (_, _) => BlocProvider(
        create: (_) => AdemDetailPageBloc(),
        child: const AdemDetailPage(),
      ),
    ),

    // Meter list page
    GoRoute(
      path: '/menu/meterList',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => const MeterListPage(),
    ),

    // // AGA8 molar list page
    // GoRoute(
    //   path: '/menu/aga8MolarList',
    //   parentNavigatorKey: _mainNavKey,
    //   builder: (_, _) => const AGA8MolarListPage(),
    // ),

    // Test Cmd
    // GoRoute(
    //   path: '/menu/testCmd',
    //   parentNavigatorKey: _mainNavKey,
    //   builder: (_, _) => const TestCmdPage(),
    // ),
    GoRoute(
      path: '/menu/appSettings',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => const AppSettingsPage(),
    ),

    GoRoute(
      path: '/menu/faq',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => const FaqPage(),
    ),

    GoRoute(
      path: '/menu/btCmdTesting',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => const TestingPage(),
    ),

    GoRoute(
      path: '/menu/licenses',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => BlocProvider(
        create: (_) => LicensesBloc(),
        child: const LicensesPage(),
      ),
    ),

    // Dashboard
    ShellRoute(
      navigatorKey: _dashboardNavKey,
      pageBuilder: (_, _, child) =>
          NoTransitionPage(child: Dashboard(child: child)),
      routes: [
        // Set up - section
        GoRoute(
          path: '/setup',
          redirect: _dashboardRedirect,
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, state) {
            return NoTransitionPage(
              child: BlocProvider(
                create: (_) => ExportBloc(),
                child: SetupPage(hasChecking: (state.extra as bool?) ?? false),
              ),
            );
          },
          routes: [
            // Set up - section > Basic page
            GoRoute(
              path: 'basic',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupBasicPageBloc(),
                child: const SetupBasicPage(),
              ),
            ),

            // Set up - section > Press. and temp. page
            GoRoute(
              path: 'pressAndTemp',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupPressAndTempPageBloc(),
                child: const SetupPressAndTempPage(),
              ),
            ),

            // Set up - section > Statistics page
            GoRoute(
              path: 'statistic',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupStatisticPageBloc(),
                child: const SetupStatisticPage(),
              ),
            ),

            // Set up - section > Display page
            GoRoute(
              path: 'display',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupDisplayPageBloc(),
                child: const SetupDisplayPage(),
              ),
            ),

            // Set up - section > Q monitor group page
            GoRoute(
              path: 'aga8',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupAga8PageBloc(),
                child: const SetupAga8Page(),
              ),
            ),
            GoRoute(
              path: 'qMonitor',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => SetupQMonitorGroupPageBloc(),
                child: const SetupQMonitorGroupPage(),
              ),
            ),
            GoRoute(
              path: 'configuration',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => ConfigsPageBloc(),
                child: const ConfigsPage(),
              ),
              routes: [
                GoRoute(
                  path: 'detail',
                  parentNavigatorKey: mainNavKey,
                  builder: (_, state) => BlocProvider(
                    create: (_) => ConfigsPageBloc(),
                    child: ConfigDetailPage(
                      config: state.extra as AdemConfigDetail,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Check - section
        GoRoute(
          path: '/check',
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, _) {
            return NoTransitionPage(
              child: BlocProvider(
                create: (_) => ExportBloc(),
                child: const CheckPage(),
              ),
            );
          },
          routes: [
            // Check - section > Basic page
            GoRoute(
              path: 'basic',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckBasicPageBloc(),
                child: const CheckBasicPage(),
              ),
            ),

            // Check - section > Battery page
            GoRoute(
              path: 'battery',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckBatteryPageBloc(),
                child: const CheckBatteryPage(),
              ),
            ),

            // Check - section > Alarms page
            GoRoute(
              path: 'alarm',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckAlarmPageBloc(),
                child: const CheckAlarmPage(),
              ),
            ),

            // Check - section > Factors page
            GoRoute(
              path: 'factor',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckFactorPageBloc(),
                child: const CheckFactorPage(),
              ),
            ),

            // Check - section > Statistics page
            GoRoute(
              path: 'statistic',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckStatisticPageBloc(),
                child: const CheckStatisticPage(),
              ),
            ),

            // Check - section > Display page
            GoRoute(
              path: 'display',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckDisplayPageBloc(),
                child: const CheckDisplayPage(),
              ),
            ),

            // Check - section > AGA8 page
            GoRoute(
              path: 'aga8',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckAga8PageBloc(),
                child: const CheckAga8Page(),
              ),
            ),

            GoRoute(
              path: 'qMonitor',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CheckQMonitorGroupPageBloc(),
                child: const CheckQMonitorGroupPage(),
              ),
            ),
          ],
        ),

        // Calibration - Section
        GoRoute(
          path: '/calibration',
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, _) {
            return const NoTransitionPage(child: CalibrationPage());
          },
          routes: [
            // Calibration - Section > 1 point gas diff. press. calibration page
            GoRoute(
              path: 'onePoint/dp',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration1PointDpPageBloc(),
                child: const Calibration1PointDpPage(),
              ),
            ),

            // Calibration - Section > 3 point gas diff. press. calibration page
            GoRoute(
              path: 'threePoint/dp',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration3PointDpPageBloc(),
                child: const Calibration3PointDpPage(),
              ),
            ),

            // Calibration - Section > 1 point gas press. calibration page
            GoRoute(
              path: 'onePoint/pressure',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration1PointPressurePageBloc(),
                child: const Calibration1PointPressurePage(),
              ),
            ),

            // Calibration - Section > 3 point gas press. calibration page
            GoRoute(
              path: 'threePoint/pressure',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration3PointPressurePageBloc(),
                child: const Calibration3PointPressurePage(),
              ),
            ),

            // Calibration - Section > 1 point gas temp. calibration page
            GoRoute(
              path: 'onePoint/temperature',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration1PointTemperaturePageBloc(),
                child: const Calibration1PointTemperaturePage(),
              ),
            ),

            // Calibration - Section > 3 point gas temp. calibration page
            GoRoute(
              path: 'threePoint/temperature',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => Calibration3PointTemperaturePageBloc(),
                child: const Calibration3PointTemperaturePage(),
              ),
            ),
          ],
        ),

        GoRoute(
          path: '/dpCalculator',
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, _) {
            return NoTransitionPage(
              child: BlocProvider(
                create: (_) => DpCalculatorBloc(),
                child: const DpCalculatorPage(),
              ),
            );
          },
          routes: [],
        ),

        // Logs - Section
        GoRoute(
          path: '/log',
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, _) {
            return const NoTransitionPage(child: LogPage());
          },
          routes: [
            // Logs - Section > Daily logs page
            GoRoute(
              path: 'daily',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) => BlocProvider(
                create: (_) => LogDailyPageBloc(),
                child: LogDailyPage(
                  dateTimeRange: state.extra as LogTimeRange?,
                ),
              ),
            ),

            // Logs - Section > Event logs page
            GoRoute(
              path: 'event',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) {
                String? accessCode;
                LogTimeRange? period;

                if (state.extra case String? o) accessCode = o;
                if (state.extra case LogTimeRange? o) period = o;

                return BlocProvider(
                  create: (_) => LogEventPageBloc(),
                  child: LogEventPage(
                    accessCode: accessCode,
                    dateTimeRange: period,
                  ),
                );
              },
            ),

            // Logs - Section > Alarm logs page
            GoRoute(
              path: 'alarm',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) {
                return BlocProvider(
                  create: (_) => LogAlarmPageBloc(),
                  child: LogAlarmPage(
                    dateTimeRange: state.extra as LogTimeRange?,
                  ),
                );
              },
            ),

            // Logs - Section > Interval logs page
            GoRoute(
              path: 'interval',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) => BlocProvider(
                create: (_) => LogIntervalPageBloc(),
                child: LogIntervalPage(
                  dateTimeRange: state.extra as LogTimeRange?,
                ),
              ),
            ),

            // Logs - Section > Q logs page
            GoRoute(
              path: 'q',
              parentNavigatorKey: mainNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => LogQPageBloc(),
                child: const LogQPage(),
              ),
            ),

            // Logs - Section > Flow DP. logs page
            GoRoute(
              path: 'dp',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) => BlocProvider(
                create: (_) => LogFlowDpPageBloc(),
                child: const LogFlowDpPage(),
              ),
            ),
          ],
        ),

        // Cloud Section
        GoRoute(
          path: '/cloud',
          redirect: _dashboardRedirect,
          parentNavigatorKey: _dashboardNavKey,
          pageBuilder: (_, _) {
            return const NoTransitionPage(child: CloudPage());
          },
          routes: [
            GoRoute(
              path: 'upload/file',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) {
                final o = state.extra as Map<String, dynamic>;

                return BlocProvider(
                  create: (_) => UploadFilePageBloc(),
                  child: UploadFilePage(
                    fileType: o['fileType'] as CloudFileType,
                    filePath: o['filePath'] as String?,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'download/file',
              parentNavigatorKey: mainNavKey,
              builder: (_, state) {
                final o = state.extra as Map<String, dynamic>;

                return BlocProvider(
                  create: (_) => DownloadFilePageBloc(),
                  child: DownloadLogPage(
                    fileType: o['fileType'],
                    serialNumber: o['serialNumber'],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/mfa',
      parentNavigatorKey: mainNavKey,
      builder: (_, _) => BlocProvider(
        create: (_) => MfaBloc(),
        child: const MfaInstructionPage(),
      ),
      routes: [
        GoRoute(
          path: 'setup',
          parentNavigatorKey: mainNavKey,
          builder: (_, state) => BlocProvider(
            create: (_) => MfaBloc(),
            child: MfaSetupPage(setupKey: state.extra as String),
          ),
        ),
      ],
    ),

    ShellRoute(
      navigatorKey: _limitedViewDashboardNavKey,
      pageBuilder: (_, _, child) => NoTransitionPage(
        child: Scaffold(
          drawer: const SMenu(),
          drawerEnableOpenDragGesture: false,
          body: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/limitedUser',
          parentNavigatorKey: _limitedViewDashboardNavKey,
          builder: (_, _) => const LimitedUserDashboard(),
          routes: [
            GoRoute(
              path: 'customDisplay',
              parentNavigatorKey: _limitedViewDashboardNavKey,
              builder: (_, _) => BlocProvider(
                create: (_) => CustomDisplayPageBloc(),
                child: const CustomDisplayPage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

FutureOr<String?> _dashboardRedirect(
  BuildContext context,
  GoRouterState state,
) {
  final role = AppDelegate().user?.role;
  return switch (role) {
    null => '/signIn',
    UserRole.limitedUser => '/limitedUser',
    UserRole.superAdmin ||
    UserRole.admin ||
    UserRole.technician => state.fullPath,
  };
}
