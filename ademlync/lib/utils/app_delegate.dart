import 'dart:async';
import 'dart:io';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:ademlync_device/models/adem/config_cache.dart';
import 'package:ademlync_device/models/adem/measure_cache.dart';
import 'package:ademlync_device/models/modules/push_button_module.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import 'constants.dart';
import 'controllers/storage_manager.dart';
import 'enums.dart';
import 'functions.dart';
import 'preference_unit.dart';
import 'timer.dart';
import 'ui_specification.dart';

part './app_state_notifier.dart';

class AppDelegate {
  // Singleton
  AppDelegate._internal();
  static final _delegate = AppDelegate._internal();

  factory AppDelegate() => _delegate;

  static BuildContext? rootContext;
  static BuildContext? rootNavContext;

  // ---- AdEM ----

  final _ademManager = AdemManager();

  Adem get adem => _ademManager.adem;

  /// Updates the stored Adem object with a new Adem instance
  void updateAdem(Adem adem) {
    _ademManager.updateAdem(adem);
  }

  /// Caches a [ConfigCache] instance
  void cacheConfig(ConfigCache data) {
    _ademManager.cacheConfig(data);
  }

  /// Caches a [MeasureCache] instance
  void cacheMeasure(MeasureCache data) {
    _ademManager.cacheMeasure(data);
  }

  /// Caches a [PushButtonModule] instance
  void cachePushButtonModule(PushButtonModule data) {
    _ademManager.cachePushButtonModule(data);
  }

  /// Fetches `data` and `cache`.
  Future<void> fetchAdem() async {
    await _ademManager.fetchAdem();
  }

  /// Cleans `data` and `cache`.
  void clearAdem() {
    _ademManager.clearAdem();
  }

  /// Focus to disconnect
  Future<void> forceDisconnect() async {
    await _ademManager.disconnect(hasRetry: false, isForced: true);
  }

  CredentialUser? get user => UserManager().user;

  // ---- Package Info ----

  late final PackageInfo _packageInfo;

  /// Get the app version
  String get version => _packageInfo.version;

  /// Get the build number
  String get buildNumber => _packageInfo.buildNumber;

  /// Get the app name
  String get appName => _packageInfo.appName;

  /// Initializes package information from the platform.
  Future<void> initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // ---- Permission ----

  final permissionBluetooth = Permission.bluetooth;
  final permissionStorage = Permission.storage;

  bool isObserveBleStatus = false;

  /// Determine if the Bluetooth permission is granted.
  Future<bool> get isGrantedBluetooth async {
    if (Platform.isIOS) {
      // Request Bluetooth permission for iOS
      return await Permission.bluetooth.request().isGranted;
    } else if (Platform.isAndroid) {
      // Request Bluetooth permissions for Android
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      final isGranted =
          statuses[Permission.bluetoothScan]?.isGranted == true &&
          statuses[Permission.bluetoothConnect]?.isGranted == true;

      if (isGranted && !isObserveBleStatus) {
        BluetoothConnectionManager().observeStatus();
        isObserveBleStatus = true;
      }

      return isGranted;
    }
    return true;
  }

  /// Determine if the storage permission is granted.
  Future<bool> get isGrantedStorage async {
    bool isGranted = false;

    if (UISpecification.isIos) {
      isGranted = await permissionStorage.request().isGranted;
    } else if (UISpecification.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final isBelowSdk33 = androidInfo.version.sdkInt < 33;

      isGranted = isBelowSdk33
          ? await permissionStorage.request().isGranted
          : true;
    }

    if (isGranted) {
      String path = '';

      // Determine the storage path
      if (UISpecification.isIos) {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      } else {
        path = await _getPublicFolderPath();
      }

      if (path.isNotEmpty) localDirectoryPath = path;
    }

    return isGranted;
  }

  Future<String> _getPublicFolderPath() async {
    try {
      final basePath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS,
      );
      final fullPath = '$basePath/$appName';

      if (Directory(fullPath) case Directory dir when !await dir.exists()) {
        await dir.create(recursive: true);
      }

      return fullPath;
    } catch (e) {
      throw Exception(e);
    }
  }

  // ---- Local Storage ----

  String localDirectoryPath = '';

  /// Initializes the local storage directory.
  Future<void> initLocalStorage() async {
    // Create directories for each log type if they don't exist.
    final folders = [
      ...LogType.values.map((o) => o.folderName),
      aga8DetailFoldername,
      alarmsFoldername,
      checkReportFoldername,
      setupReportFoldername,
      configurationFoldername,
      dpCalculatorReportFoldername,
    ];

    for (var e in folders) {
      final dir = Directory('$localDirectoryPath/$e');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }

  Future<List<String>> localLogFilePaths() async {
    final manager = StorageManager();
    return [
      for (final o in LogType.values) ...await manager.readFolder(o.folderName),
    ];
  }

  // ---- Timer ----

  final Set<STimer> _timers = {};

  /// Registers a timer.
  void registerTimer(STimer timer) {
    _timers.add(timer);
  }

  /// Deregister a timer.
  void deregisterTimer(STimer timer) {
    _timers.remove(timer);
  }

  Timer? _mainTimer;

  Future<void> checkLoginState() async {
    final state = await determineLoginState();
    if (state == LoginState.expired) await signOut(true);
  }

  void setMainTimer() {
    if (_mainTimer != null) _mainTimer!.cancel();
    _mainTimer = Timer.periodic(mainTimerDuration, (_) => checkLoginState());
  }

  void cancelMainTimer() {
    _mainTimer?.cancel();
  }

  // ---- Connectivity ----

  /// Flag to prevent multiple connectivity warning dialogs from showing
  bool _isDialogOpened = false;
  late StreamSubscription<List<ConnectivityResult>> connectivityListener;

  /// Initialize connectivity monitoring and check initial status
  void initConnectivity() async {
    connectivityListener = Connectivity().onConnectivityChanged.listen(
      _checkConnectivity,
    );
  }

  Future<void> firstCheckConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    await _checkConnectivity(result);
  }

  /// Check network connectivity and internet access
  /// Shows a warning dialog if no connection is available
  Future<void> _checkConnectivity(List<ConnectivityResult> result) async {
    // Check if we have any network connection
    final hasNetworkConnection =
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.ethernet);

    // Verify actual internet connectivity by pinging Google
    final hasInternet = hasNetworkConnection && await _canPingInternet();

    // Show warning dialog if no internet and dialog not already shown
    if (!hasInternet && rootNavContext != null && !_isDialogOpened) {
      _isDialogOpened = true;

      await showConnectivityWarning(rootNavContext!);

      _isDialogOpened = false;
    }
  }

  /// Test internet connectivity by pinging Google
  /// Returns true if ping succeeds, false otherwise
  Future<bool> _canPingInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ---- Bluetooth ----

  StreamSubscription<BluetoothConnectionState>? bleConnStream;

  // ---- UI ----

  bool get is24HTimeFmt => PreferenceUtils.getBool(timeFmtKey) ?? true;

  ExportFormat get exportFmt => ExportFormat.values.firstWhere(
    (o) => o.key == PreferenceUtils.getString(exportFmtKey),
    orElse: () => ExportFormat.pdf,
  );

  void updateTimeFmt(bool value) => PreferenceUtils.setBool(timeFmtKey, value);

  void updateExportFmt(ExportFormat value) =>
      PreferenceUtils.setString(exportFmtKey, value.key);

  Future<bool> loadUserCredential() async {
    final json = PreferenceUtils.getString(credentialKey);
    if (json != null) {
      UserManager().import(json);
      return user != null;
    } else {
      return false;
    }
  }

  Future<void> storeUserCredential() async {
    final json = UserManager().export();
    PreferenceUtils.setString(credentialKey, json);
  }

  Future<void> removeUserCredential() async {
    PreferenceUtils.remove(credentialKey);
  }
}

/// Get the text theme.
TextTheme get textTheme => Theme.of(AppDelegate.rootContext!).textTheme;

/// Get the color scheme.
ColorScheme get colorScheme => Theme.of(AppDelegate.rootContext!).colorScheme;

/// Get the app localization.
AppLocalizations get locale {
  final context = AppDelegate.rootContext;

  if (context != null) {
    if (AppLocalizations.of(context) case AppLocalizations appLocale) {
      return appLocale;
    }
  }

  return lookupAppLocalizations(const Locale('en'));
}
