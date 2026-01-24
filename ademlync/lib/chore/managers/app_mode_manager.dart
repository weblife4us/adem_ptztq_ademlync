import 'package:flutter/cupertino.dart';

import '../../utils/app_delegate.dart';
import '../../utils/preference_unit.dart';

const _debugModeKey = 'DebugMode';
const _tapInterval = Duration(seconds: 1);

class AppModeManager {
  AppModeManager._internal();

  static final _instance = AppModeManager._internal();

  factory AppModeManager() => _instance;

  int _tapCount = 0;
  DateTime? _lastTapTime;

  bool get isDebugMode => PreferenceUtils.getBool(_debugModeKey) ?? false;

  Future<bool> showDeveloperMenu() async {
    final now = _lastTapTime = DateTime.now();

    if (_lastTapTime == null || now.difference(_lastTapTime!) > _tapInterval) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    if (_tapCount >= 10) {
      _tapCount = 0;
      _lastTapTime = null;

      if (await _showDeveloperMenu() == true) {
        PreferenceUtils.setBool(_debugModeKey, !isDebugMode);
        return true;
      }
    }

    return false;
  }

  Future<bool?> _showDeveloperMenu() async {
    return await showCupertinoDialog(
      context: AppDelegate.rootNavContext!,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Developer Menu'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            isDestructiveAction: isDebugMode ? true : false,
            onPressed: () => Navigator.pop(context, true),
            child: Text('${isDebugMode ? 'Disable' : 'Enable'} Debug Mode'),
          ),

          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
