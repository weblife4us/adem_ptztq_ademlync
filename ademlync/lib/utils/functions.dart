import 'dart:async';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../chore/main_bloc.dart';
import '../features/user/user_bloc.dart';
import 'app_delegate.dart';
import 'controllers/date_time_fmt_manager.dart';
import 'controllers/storage_manager.dart';
import 'enums.dart';
import 'widgets/loading_dislog.dart';
import 'widgets/s_card.dart';
import 'widgets/s_dialog_layout.dart';
import 'widgets/s_text.dart';

/// Signs out the `user`.
Future<void> signOut([bool isExpired = false]) async {
  final context = AppDelegate.rootNavContext;

  if (context != null) {
    BuildContext? dialogContext;

    // Shows a `loading dialog` while signing out.
    showLoadingDialog(
      context,
      text: locale.signingOutString,
      onBuild: (o) => dialogContext = o,
    );

    final mainBloc = BlocProvider.of<MainBloc>(context);
    mainBloc.add(MBBtDiscEvent(isSignOut: true));

    // Wait for the Bluetooth disconnect state.
    await for (var state in mainBloc.stream) {
      if (state is MBBtDisconnectedState) break;
    }

    final userBloc = UserBloc();
    userBloc.add(UserLoggedOut());

    // Wait for the logout state.
    await for (var state in userBloc.stream) {
      if (state is UserLogoutSuccess) {
        await AppDelegate().removeUserCredential();
        if (context.mounted) {
          context.go('/signIn', extra: isExpired);
          if (dialogContext != null) Navigator.pop(dialogContext!);
        }
        break;
      }
    }
  }
}

extension BooleanExt on bool {
  /// Returns a localized string representation based on the boolean value.
  /// If the boolean value is `true`, it returns the "yes" string from the locale.
  /// If the boolean value is `false`, it returns the "no" string from the locale.
  String get asString => this == true ? locale.yesString : locale.noString;
}

extension IntExt on int {
  /// Adds leading zeros to a string representation of a number.
  String padLeftZero(int digit) => toString().padLeft(digit, '0');
}

extension IterableExtension<T> on Iterable<T> {
  /// Returns the first element that satisfies the given [test] function
  /// or `null` if no elements satisfy it.
  T? firstWhereOrNull(bool Function(T e) test) {
    for (var e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

/// Combines the date from [date] with the time from [time] to create a new DateTime object.
/// Returns `null` if either [date] or [time] is `null`.
DateTime? combineDateTime(DateTime? date, DateTime? time) {
  return date != null && time != null
      ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
      : null;
}

extension StringUnit on String {
  /// Adds a unit to the end of a string.
  String addUnit(String unit) {
    return '$this\n[$unit]';
  }

  /// Adds the unit of the provided [param] to the end of the string.
  String addUnitP(Param param) {
    return '$this\n[${param.unit(AppDelegate().adem)}]';
  }
}

/// Calculates the calibrated value within the valid range.
double calib1PtLimitCalculate(num val, double reading, double offset) {
  return val + reading - offset;
}

/// Builds a list of widgets representing a form layout.
List<Widget> formBuilder({
  List<String?>? titles,
  required List<List<Widget>> contents,
  double spacing = 8.0,
}) {
  return [
    for (var i = 0; i < contents.length; i++)
      if (contents[i].isNotEmpty)
        SCard.column(
          title: titles?[i],
          spacing: spacing,
          children: contents[i],
        ),
  ];
}

/// Handle error here.
Future<void> handleError(BuildContext context, Object error) async {
  String? title;
  String? detail;

  switch (error) {
    case FlutterBluePlusException _:
      title = 'Bluetooth Connection Failed';
      break;

    case CancelAdemCommunication _:
      break;

    case AdemCommError(:final type, :final message):
      title = type.message;
      detail = switch (type) {
        AdemCommErrorType.unsupportedFirmware => '$message is not supported',
        _ => message,
      };
      break;

    default:
      title = 'Unknown Error';
      break;
  }

  if (title != null) {
    await showWarningDialog(context, title: title, detail: detail);
  }
}

class CancelAdemCommunication implements Exception {}

extension UserRoleDisplayName on UserRole {
  String get displayName => switch (this) {
    UserRole.superAdmin => locale.superAdminString,
    UserRole.admin => locale.adminString,
    UserRole.technician => locale.technicianString,
    UserRole.limitedUser => locale.limitedUserString,
  };
}

extension UserAccessDisplayName on UserAccess {
  String get displayName => switch (this) {
    UserAccess.readAdem => 'Read AdEM',
    UserAccess.writeAdem => 'Write AdEM',
    UserAccess.calibrateAdem => 'Calibrate AdEM',
    UserAccess.changeAdemAccessCode => 'Change AdEM Access Code',
    UserAccess.changeAdemSuperAccessCode => 'Change AdEM Super Access Code',
    UserAccess.crossCompanyManagement => 'Cross Company Management',
    UserAccess.pullLogFromCloud => 'Pull Log from Cloud',
    UserAccess.pushLogToCloud => 'Push Log to Cloud',
    UserAccess.createUserInCloud => 'Create User in Cloud',
    UserAccess.editUserInCloud => 'Edit User in Cloud',
    UserAccess.deleteUserFromCloud => 'Delete User from Cloud',
  };
}

/// Converts generic data to a string representation based on the provided parameter.
String dataToString<T>(T data, Param param) {
  final decimal = param.decimal(AppDelegate().adem);
  return switch (data) {
    int o => o.toStringAsFixed(decimal),
    double o => o.toStringAsFixed(decimal),
    _ => '',
  };
}

extension LogTypeExt on LogType {
  String get displayName => switch (this) {
    LogType.daily => locale.dailyLogsString,
    LogType.event => locale.eventLogsString,
    LogType.alarm => locale.alarmLogsString,
    LogType.q => locale.qLogsString,
    LogType.flowDp => locale.flowDPLogsString,
    LogType.interval => locale.intervalLogsString,
  };

  String get folderName => switch (this) {
    LogType.daily => 'Log-Daily',
    LogType.event => 'Log-Event',
    LogType.alarm => 'Log-Alarm',
    LogType.q => 'Log-Q',
    LogType.flowDp => 'Log-DP',
    LogType.interval => 'Log-Interval',
  };
}

extension CloudFileTypeExt on CloudFileType {
  String get folderName => switch (this) {
    CloudFileType.dailyLog => 'Log-Daily',
    CloudFileType.eventLog => 'Log-Event',
    CloudFileType.alarmLog => 'Log-Alarm',
    CloudFileType.qLog => 'Log-Q',
    CloudFileType.flowDpLog => 'Log-DP',
    CloudFileType.intervalLog => 'Log-Interval',
    CloudFileType.setupReport => 'Report-Setup',
    CloudFileType.setupConfig => 'Configuration',
    CloudFileType.checkReport => 'Report-Check',
  };

  String get text => switch (this) {
    CloudFileType.dailyLog => 'Daily Log',
    CloudFileType.eventLog => 'Event Log',
    CloudFileType.alarmLog => 'Alarm Log',
    CloudFileType.qLog => 'Q Log',
    CloudFileType.flowDpLog => 'DP Log',
    CloudFileType.intervalLog => 'Interval Log',
    CloudFileType.setupReport => 'Setup Report',
    CloudFileType.setupConfig => 'Setup Configuration',
    CloudFileType.checkReport => 'Check Report',
  };
}

extension ExportLogFmtDisplayName on ExportFormat {
  String get displayName => switch (this) {
    ExportFormat.excel => 'Excel (.xlsx)',
    ExportFormat.pdf => 'PDF (.pdf)',
    ExportFormat.json => 'JSON (.json)',
  };

  String get key => switch (this) {
    ExportFormat.excel => 'excel',
    ExportFormat.pdf => 'pdf',
    ExportFormat.json => 'json',
  };

  String get fmt => switch (this) {
    ExportFormat.excel => '.xlsx',
    ExportFormat.pdf => '.pdf',
    ExportFormat.json => '.json',
  };

  String get svg => switch (this) {
    ExportFormat.excel => 'xlsx',
    ExportFormat.pdf => 'pdf',
    ExportFormat.json => 'json',
  };
}

extension GroupDisplay on Group {
  /// Capitalizes the first letter of the string.
  String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  String get displayName {
    return '${company.replaceAll('-', ' ').toUpperCase()} (${_capitalize(role.displayName)})';
  }
}

// Determine if the value is fit the limitation
String? numValidator(String? text, AdemParamLimit? limit) {
  String? err;
  final value = text != null ? num.tryParse(text) : null;

  if (value == null) {
    // The value is null
    err = 'Value cannot be empty';
  } else if (limit != null ? !limit.isValid(value) : false) {
    // The value is out of the range
    err = '${limit.min} ~ ${limit.max}';
  }

  return err;
}

void showToast(BuildContext context, {required String text}) {
  if (AppDelegate.rootContext case final context? when context.mounted) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: SText.bodyMedium(text, color: Colors.black),
          backgroundColor: const Color(0xffffcd00),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

/// Handles errors based on the ApiHelperError type.
///
/// - `unauthorized`: Calls `requireLogin` to prompt for login.
/// - Other types (accessDenied, responseError, unknown): No action taken.
void handleApiHelperError(BuildContext context, ApiHelperError error) {
  switch (error.type) {
    case ApiHelperErrorType.unauthorized:
      signOut(true);
      break;
    case ApiHelperErrorType.accessDenied:
    case ApiHelperErrorType.responseError:
    case ApiHelperErrorType.unknown:
      break;
  }
}

/// Generates a filename by combining the serial number with the current timestamp
/// and the specified file format extension.
///
/// The filename follows the pattern: [serialNumber]_[current date and time in yyyy-MM-dd-HH-mm format].[file extension]
///
/// Example output: "12345678_2024-08-08-15-30.csv"
///
/// [serialNumber] - The serial number to include in the filename.
/// [format] - The export format specifying the file extension (e.g., .csv, .json).
///
/// Returns the formatted filename as a string.
String mapFilename(
  String serialNumber,
  String symbol,
  ExportFormat format,
  DateTime dateTime,
) {
  final date = DateTimeFmtManager.formatFilenameDateTime(dateTime);

  return '${serialNumber}_${date}_${dateTime.timeZoneName}_$symbol${format.fmt}';
}

Future<void> showLoadingDialog(
  BuildContext context, {
  required String text,
  void Function(BuildContext)? onBuild,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      if (onBuild != null) onBuild(context);
      return LoadingDialog(text);
    },
  );
}

extension StringExt on String {
  String removeTag() => replaceAll(RegExp(r'</?\w>'), '');
}

Future<LoginState> determineLoginState() async {
  final app = AppDelegate();
  final hasLoadedCredential = await app.loadUserCredential();
  final user = app.user;

  LoginState state = LoginState.unauthenticated;

  if (user != null && (user.isLimitedUser || hasLoadedCredential)) {
    state = user.isLimitedUser || !user.isExpired
        ? LoginState.authenticated
        : LoginState.expired;
  }

  return state;
}

void dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<void> openFile(BuildContext context, String path) async {
  BuildContext? dialogContext;

  unawaited(
    showLoadingDialog(
      context,
      onBuild: (context) => dialogContext = context,
      text: 'Opening...',
    ),
  );

  unawaited(
    Future.delayed(const Duration(seconds: 10), () {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);

        if (context.mounted) showToast(context, text: 'Open Failed');
      }
    }),
  );

  final result = await StorageManager().openFile(path);

  if (context.mounted) {
    showToast(context, text: getOpenFileResultMessage(result));
  }
  if (dialogContext != null && dialogContext!.mounted) {
    Navigator.pop(dialogContext!);
  }
}

extension AdemParamLimitExt on AdemParamLimit {
  String toDisplay(int decimal) =>
      '${min.toStringAsFixed(decimal)} ~ ${max.toStringAsFixed(decimal)}';
}

Future<void> showWarningDialog(
  BuildContext context, {
  required String title,
  String? detail,
  String? closeText,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => SDialogLayout(title: title, detail: detail),
  );
}

Future<void> showConnectivityWarning(BuildContext context) async {
  await showWarningDialog(
    context,
    title: 'No Internet Connection Detected',
    detail: AppDelegate().user == null
        ? 'Try again when you\'re back online.'
        : 'You\'re working offline. Programming is available. Cloud features will reconnect when internet is restored.',
    closeText: 'Close',
  );
}

Future<void> showCalibrationWarning(BuildContext context) async {
  await showWarningDialog(
    context,
    title: 'Calibration Warning',
    detail:
        'Each point of A/D Counts must greater than 100.\nEach A/D Slop must greater than 0, less than 1000',
  );
}

String getOpenFileResultMessage(OpenResult result) {
  return switch (result.type) {
    ResultType.done => 'File opened successfully',
    ResultType.noAppToOpen => 'No app available to open this file',
    ResultType.error => 'Error opening file: ${result.message}',
    ResultType.permissionDenied ||
    ResultType.fileNotFound => 'Unhandled result type: ${result.type}',
  };
}

void showExportSuccessToast(BuildContext context) {
  showToast(context, text: 'Exported to device storage.');
}
