import 'dart:async';

import '../models/adem_response.dart';
import '../utils/adem_param.dart';
import '../utils/constants.dart';
import '../utils/error_enum.dart';
import 'adem_manager.dart';

mixin AdemActionHelper {
  bool _isCancelCommunication = false;
  bool _isCommunicating = false;

  bool get isCommunicating => _isCommunicating;

  bool get isCancelCommunication => _isCancelCommunication;

  /// Defines an asynchronous function to fetch responses with [parameters].
  Future<Map<Param, AdemResponse?>> fetchForParameters(
    List<Param> params, {
    bool checking = true,
    bool checkAdemNotSwitch = true,
  }) async {
    Object? error;
    final completer = Completer<void>();
    Timer? timer;
    bool isConnectedToAdem = false;

    _isCancelCommunication = false;
    _isCommunicating = true;

    final res = <Param, AdemResponse?>{};
    final manager = AdemManager();

    try {
      // Wake up the AdEM
      await manager.wakeUp();

      // Build a connection with AdEM
      await manager.connect();
      isConnectedToAdem = true;

      // Set a timer for auto disconnection
      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      // Determine if the AdEM have been switched
      if (checkAdemNotSwitch) await manager.checkAdemNotSwitch();

      // Fetch data
      for (var param in params) {
        if (_isCancelCommunication || completer.isCompleted) break;

        bool isTimeout = false;
        final stopwatch = Stopwatch()..start();
        do {
          try {
            isTimeout = false;
            res[param] = await AdemManager().read(
              param.key,
              checking: checking,
            );
          } catch (e) {
            if (e case AdemCommError(
              :final type,
            ) when type == AdemCommErrorType.receiveTimeout) {
              isTimeout = true;

              await Future.delayed(const Duration(milliseconds: retryDelay));
            } else {
              stopwatch.stop();
              rethrow;
            }
          }
        } while (isTimeout &&
            !completer.isCompleted &&
            !_isCancelCommunication);
      }

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        if (isConnectedToAdem) await manager.disconnect();
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
      _isCommunicating = false;
    }

    return res;
  }

  /// Executes a list of asynchronous tasks.
  Future<void> executeTasks(
    List<Future<void> Function()> tasks, {
    String? accessCode,
    String? userId,
    bool checkAdemNotSwitch = true,
  }) async {
    Object? error;
    final completer = Completer<void>();
    Timer? timer;
    bool isConnectedToAdem = false;

    _isCancelCommunication = false;
    _isCommunicating = true;

    final manager = AdemManager();

    try {
      // Wake up the AdEM
      await manager.wakeUp();

      // Build a connection with AdEM
      await manager.connect(accessCode);
      isConnectedToAdem = true;

      // Set a timer for auto disconnection
      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      // Determine if the AdEM have been switched
      if (checkAdemNotSwitch) await manager.checkAdemNotSwitch();

      // Set user id if necessary
      await _setUserIdIfNeeded(accessCode, userId);

      // Complete tasks
      for (var task in tasks) {
        if (_isCancelCommunication || completer.isCompleted) break;

        bool isTimeout = false;
        final stopwatch = Stopwatch()..start();
        int retryCount = 0;

        do {
          try {
            isTimeout = false;
            await task();
          } catch (e) {
            if (e case AdemCommError(
              :final type,
            ) when type == AdemCommErrorType.receiveTimeout) {
              if (++retryCount < 3) {
                isTimeout = true;

                await Future.delayed(const Duration(milliseconds: retryDelay));
              } else {
                stopwatch.stop();
                rethrow;
              }
            } else {
              stopwatch.stop();
              rethrow;
            }
          }
        } while (isTimeout &&
            !completer.isCompleted &&
            !_isCancelCommunication);
      }

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        if (isConnectedToAdem) await manager.disconnect();
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
      _isCommunicating = false;
    }
  }

  Stream<Map<Param, AdemResponse?>> streamCalibration(
    List<Param> params,
  ) async* {
    final res = <Param, AdemResponse?>{};
    final completer = Completer<void>();
    Object? error;
    Timer? timer;
    bool isConnectedToAdem = false;

    _isCancelCommunication = false;
    _isCommunicating = true;

    final manager = AdemManager();

    // Wake up the AdEM
    try {
      await manager.wakeUp();

      // Build a connection with AdEM
      await manager.connect();
      isConnectedToAdem = true;

      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      // Fetch data
      do {
        for (var param in params) {
          if (_isCancelCommunication || completer.isCompleted) break;

          bool isTimeout = false;
          final stopwatch = Stopwatch()..start();

          do {
            try {
              isTimeout = false;

              res[param] = await AdemManager().read(param.key);
            } catch (e) {
              if (e case AdemCommError(
                :final type,
              ) when type == AdemCommErrorType.receiveTimeout) {
                isTimeout = true;

                await Future.delayed(const Duration(milliseconds: retryDelay));
              } else {
                stopwatch.stop();
                rethrow;
              }
            }
          } while (isTimeout &&
              !completer.isCompleted &&
              !_isCancelCommunication);
        }

        if (!_isCancelCommunication &&
            !completer.isCompleted &&
            params.every((o) => res.keys.contains(o))) {
          yield (res);
          res.clear();
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } while (!_isCancelCommunication && !completer.isCompleted);

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        if (isConnectedToAdem) {
          await manager.disconnect(timeout: disconnectLogTimeoutInMs);
        }
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
      _isCommunicating = false;
    }
  }

  /// Streams log entries from an `AdEM` with [logType] and [date ranges].
  Stream<AdemResponse> streamLogs(
    LogType logType, {
    DateTime? from,
    DateTime? to,
    IntervalLogType? intervalType,
    String? accessCode,
    String? userId,
    bool checkAdemNotSwitch = true,
    bool isAdem25 = false,
  }) async* {
    Object? error;
    final completer = Completer<void>();
    Timer? timer;
    bool isConnectedToAdem = false;

    _isCancelCommunication = false;
    _isCommunicating = true;

    final manager = AdemManager();
    AdemResponse? resp;
    late bool hasLog;

    try {
      // Wake up the AdEM
      await manager.wakeUp();

      // Build a connection with AdEM
      await manager.connect(accessCode);
      isConnectedToAdem = true;

      // Set a timer for auto disconnection
      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      // Determine if the AdEM have been switched
      if (checkAdemNotSwitch) await manager.checkAdemNotSwitch();

      // Set user id if necessary
      await _setUserIdIfNeeded(accessCode, userId);

      // Fetch logs
      do {
        if (resp == null) {
          switch (logType) {
            case LogType.daily:
              if (from == null || to == null) {
                throw ArgumentError('dateTimeRange is required in daily log.');
              }
              resp = await manager.readDailyLogs(from, to);
              break;

            case LogType.alarm when isAdem25 && from != null && to != null:
              resp = await manager.readAdem25AlarmLogs(from, to);
              break;

            case LogType.alarm:
              resp = await manager.readAlarmLogs();
              break;

            case LogType.event when isAdem25 && from != null && to != null:
              resp = await manager.readAdem25EventLogs(from, to);
              break;

            case LogType.event when accessCode != null:
              resp = await manager.downloadEventLogs();
              break;

            case LogType.event:
              resp = await manager.readEventLogs();
              break;

            case LogType.interval:
              if (intervalType == null || from == null || to == null) {
                throw ArgumentError(
                  'intervalType and dateTimeRange are required in interval log.',
                );
              }
              resp = await manager.readIntervalLogs(intervalType, from, to);
              break;

            case LogType.q:
              resp = await manager.readQLogs();
              break;

            case LogType.flowDp:
              resp = await manager.readFlowDpLogs();
              break;
          }
        } else {
          resp = await manager.sendAck();
        }

        // Determine if there still is log left
        hasLog = noLogPm.every((e) => e != resp?.pMessage);

        // Yield the log
        if (hasLog) yield (resp);
      } while (resp.hasRs &&
          hasLog &&
          !_isCancelCommunication &&
          !completer.isCompleted);

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        if (isConnectedToAdem) {
          await manager.disconnect(timeout: disconnectLogTimeoutInMs);
        }
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
      _isCommunicating = false;
    }
  }

  /// Signals to cancel any ongoing communication with the AdEM module.
  void cancelCommunication() {
    _isCancelCommunication = true;
  }

  /// Attempts to set the user ID in the event log if not already set.
  Future<void> _setUserIdIfNeeded(String? accessCode, String? userId) async {
    if (accessCode != null && userId != null) {
      await AdemManager().writeUserIdToEventLog(userId);
    }
  }

  // Fetch values by param item number
  Future<String> fetchByItemNumber(
    String itemNumber, {
    bool checking = true,
    bool checkAdemNotSwitch = true,
  }) async {
    AdemResponse? response;
    Object? error;
    final completer = Completer<void>();
    Timer? timer;
    bool isConnectedToAdem = false;

    _isCancelCommunication = false;
    _isCommunicating = true;

    final manager = AdemManager();

    try {
      // Wake up the AdEM
      await manager.wakeUp();

      // Build a connection with AdEM
      await manager.connect();
      isConnectedToAdem = true;

      // Set a timer for auto disconnection
      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      bool isTimeout = false;
      final stopwatch = Stopwatch()..start();
      do {
        try {
          isTimeout = false;
          response = await AdemManager().read(int.parse(itemNumber));
        } catch (e) {
          if (e case AdemCommError(
            :final type,
          ) when type == AdemCommErrorType.receiveTimeout) {
            isTimeout = true;

            await Future.delayed(const Duration(milliseconds: retryDelay));
          } else {
            stopwatch.stop();
            rethrow;
          }
        }
      } while (isTimeout && !completer.isCompleted && !_isCancelCommunication);

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        if (isConnectedToAdem) await manager.disconnect();
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
      _isCommunicating = false;
    }

    return response?.body ?? 'null';
  }
}
