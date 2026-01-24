import 'dart:async';
import 'dart:developer';

import 'package:ademlync_device/ademlync_device.dart';

import '../../utils/app_delegate.dart';

class StressTest with AdemActionHelper {
  Timer? _timer;
  final _duration = const Duration(minutes: 10);
  final _logStreamOffset = 10;
  int _testCount = 0;
  int _logCount = 0;

  bool get isStarted => _timer != null;

  void startTimer() {
    _testCount = 0;
    log('Start Timer', name: 'Stress Test', level: 3);
    _timer = Timer.periodic(_duration, (_) async => await _task());
    _task();
  }

  void stopTimer() {
    cancelCommunication();
    _timer?.cancel();
    _timer = null;
    log('Stop Timer', name: 'Stress Test', level: 3);
  }

  Future<void> _task() async {
    log(
      'Start Testing (${++_testCount}) ${DateTime.now()}',
      name: 'Stress Test',
      level: 3,
    );
    if (_timer != null) {
      await readAllParams();
    }
    if (_timer != null) {
      await Future.delayed(const Duration(seconds: 2));
      await _streamAllLogs();
    }
    if (_timer != null) {
      await Future.delayed(const Duration(seconds: 2));
      await _writeParams();
    }
    log('Testing ($_testCount) Finished', name: 'Stress Test', level: 3);
  }

  void _cancelCommunicationOnExcessiveLogs(AdemResponse e) {
    _logCount++;
    if (_logCount > _logStreamOffset || e.hasEot) {
      cancelCommunication();
      _logCount = 0;
    }
  }

  Future<void> readAllParams() async {
    log('--- Read All Params ---', name: 'Stress Test', level: 3);
    await fetchForParameters(Param.values);
  }

  Future<void> _streamAllLogs() async {
    final dateTimeRange = [
      DateTime(2000, 1, 1, 0, 0, 0),
      DateTime(2025, 01, 21, 23, 59, 59),
    ];
    final intervalType = AppDelegate().adem.measureCache.intervalType;

    log('--- Daily Logs ---', name: 'Stress Test', level: 3);
    await for (var e in streamLogs(
      LogType.daily,
      from: dateTimeRange[0],
      to: dateTimeRange[1],
    )) {
      _cancelCommunicationOnExcessiveLogs(e);
    }

    log('--- Alarm Logs ---', name: 'Stress Test', level: 3);
    await for (var e in streamLogs(LogType.alarm)) {
      _cancelCommunicationOnExcessiveLogs(e);
    }

    log('--- Event Logs ---', name: 'Stress Test', level: 3);
    await for (var e in streamLogs(LogType.event)) {
      _cancelCommunicationOnExcessiveLogs(e);
    }

    log('--- Interval Logs ---', name: 'Stress Test', level: 3);
    await for (var e in streamLogs(
      LogType.interval,
      intervalType: intervalType,
      from: dateTimeRange[0],
      to: dateTimeRange[1],
    )) {
      _cancelCommunicationOnExcessiveLogs(e);
    }

    if (AppDelegate().adem.type == AdemType.ademTq) {
      log('--- Q Logs ---', name: 'Stress Test', level: 3);
      await for (var e in streamLogs(LogType.q)) {
        _cancelCommunicationOnExcessiveLogs(e);
      }
    }

    if (AppDelegate().adem.type == AdemType.ademTq) {
      log('--- Flow D.P. Logs ---', name: 'Stress Test', level: 3);
      await for (var e in streamLogs(LogType.flowDp)) {
        _cancelCommunicationOnExcessiveLogs(e);
      }
    }
  }

  Future<void> _writeParams() async {
    log('--- Write Some Params ---', name: 'Stress Test', level: 3);
    await executeTasks(
      [
        () => AdemManager().writeLocation('         AdEM-TQ        Lab_test'),
        () => AdemManager().write(Param.dispVolSelect.key, '00000000'),
      ],
      accessCode: '33333',
      userId: AppDelegate().user!.id,
    );
  }
}
