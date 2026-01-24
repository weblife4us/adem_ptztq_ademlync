import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/adem_response.dart';
import '../utils/communication_enums.dart';
import '../utils/constants.dart';
import '../utils/error_enum.dart';
import '../utils/functions.dart';

class CommunicationManager {
  final BluetoothCharacteristic writeCharacteristic;
  final BluetoothCharacteristic readCharacteristic;
  final bool isAirConsole;

  CommunicationManager(
    this.writeCharacteristic,
    this.readCharacteristic,
    this.isAirConsole,
  );

  bool _isCommunicating = false;

  /// Send a `command` and receive a `response`.
  Future<AdemResponse> communicate(
    List<int> command, {
    required int timeout,
  }) async {
    // Wait until previous communication finish
    await _waitForCommunicationToEnd();
    _isCommunicating = true;

    final completer = Completer<List<int>>();

    _catchResp(command, timeout: timeout)
        .then((response) {
          if (!completer.isCompleted) completer.complete(response);
        })
        .catchError((error) {
          if (!completer.isCompleted) completer.completeError(error);
        });

    _sendCommand(command)
        .catchError((error) {
          if (!completer.isCompleted) completer.completeError(error);
        })
        .whenComplete(() {
          _isCommunicating = false;
        });

    try {
      final response = await completer.future;

      if (response.contains(255)) {
        final data = response.map((o) => o == 255 ? 32 : o).toList();
        final str = bytesToReadableString(data).replaceAll(' ', 'ff');

        throw AdemCommError(
          AdemCommErrorType.trashBytes,
          'AdEM memory error. Please try again.\n\n$str',
        );
      }

      return AdemResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  /// Send a `command` and receive a `response`.
  Future<List<int>> communicateWithDongle(
    List<int> command, {
    int timeout = readDongleTimeoutInMs,
  }) async {
    final completer = Completer<List<int>>();

    _catchResp(command, timeout: timeout)
        .then((response) {
          if (!completer.isCompleted) completer.complete(response);
        })
        .catchError((error) {
          if (!completer.isCompleted) completer.completeError(error);
        });

    _sendCommand(command).catchError((error) {
      if (!completer.isCompleted) completer.completeError(error);
    });

    try {
      final response = await completer.future;
      return response;
    } catch (error) {
      rethrow;
    }
  }

  /// Sends a command without expecting any return response.
  Future<void> communicateWithoutResponse(List<int> command) async {
    // Wait until previous communication finish
    await _waitForCommunicationToEnd();
    _isCommunicating = true;

    try {
      // Send out the command
      await _sendCommand(command);
    } finally {
      _isCommunicating = false;
    }
  }

  /// Sends a Bluetooth command to a device, handling device-specific limitations.
  Future<void> _sendCommand(List<int> command) async {
    if (!isAirConsole) {
      // Dragonfly
      // NOTE: The limitation set in AdEM Key is 128 bytes.
      // Can increase the limitation to 256 bytes if need.

      if (command.length > maxBytesDf) {
        throw Exception(
          'The Command size exceeds the limitation of $maxBytesDf bytes',
        );
      }

      // Send out the bytes by the write characteristic
      await writeCharacteristic.write(
        command,
        allowLongWrite: true,
        timeout: sendCommandTimeoutInMs,
      );
    } else {
      // Air console
      // NOTE: The limitation set in Air Console is 20 bytes.
      final length = command.length;

      // Send out the bytes by parts
      for (var i = 0; i < command.length; i += maxBytesAc) {
        final end = (i + maxBytesAc).clamp(i + 1, length);
        final tmp = command.sublist(i, end);

        // Send out the bytes by the write characteristic
        await writeCharacteristic.write(
          tmp,
          withoutResponse: true,
          timeout: sendCommandTimeoutInMs,
        );
      }
    }

    logBleCmd(command, writeCharacteristic, isTransmit: true, isValid: true);
  }

  /// Receives a Bluetooth response within a given timeout.
  Future<List<int>> _catchResp(
    List<int> command, {
    required int timeout,
  }) async {
    final responseBuffer = <int>[];
    final timeoutDuration = Duration(milliseconds: timeout);
    final stream = readCharacteristic.onValueReceived.timeout(timeoutDuration);

    try {
      await for (var event in stream) {
        responseBuffer.addAll(event);

        final isValid = _verifyResponse(responseBuffer);

        logBleCmd(
          event,
          readCharacteristic,
          isTransmit: false,
          isValid: isValid,
        );

        if (isValid) break;
      }
    } on TimeoutException catch (_) {
      logBleCmdErr(
        command,
        responseBuffer,
        writeCharacteristic,
        readCharacteristic,
      );

      final txHex = command
          .map((o) => o.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      final txDec = bytesToReadableString(command);

      final rxHex = responseBuffer
          .map((o) => o.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      final rxDec = bytesToReadableString(responseBuffer);

      final message =
          '''
TX:HEX: [$txHex]
TX:DEC: $txDec

RX:HEX: [$rxHex]
RX:DEC: $rxDec

TIME: ${DateTime.now().toIso8601String()}
''';

      throw AdemCommError(AdemCommErrorType.receiveTimeout, message);
    }

    return responseBuffer;
  }

  /// Checks if the received bytes represent a complete response.
  bool _verifyResponse(List<int> bytes) {
    if (bytes.isEmpty) return false;
    if (bytes.length == 1) return bytes.single == ControlChar.ack.byte;
    return bytes.last == ControlChar.eot.byte ||
        bytes.last == ControlChar.rs.byte;
  }

  /// Waits for any ongoing communication to finish before proceeding, with a timeout to prevent infinite waiting.
  Future<void> _waitForCommunicationToEnd({int timeoutSeconds = 3}) async {
    final timeout = Duration(seconds: timeoutSeconds);
    final start = DateTime.now();

    while (_isCommunicating) {
      if (DateTime.now().difference(start) > timeout) {
        throw TimeoutException(
          'Waiting for communication to end timed out after $timeoutSeconds seconds.',
        );
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

void logBleCmdErr(
  List<int> txBytes,
  List<int> rxBytes,
  BluetoothCharacteristic writeCharacteristic,
  BluetoothCharacteristic readCharacteristic,
) {
  final txHex = txBytes
      .map((o) => o.toRadixString(16).padLeft(2, '0'))
      .join(' ');
  final txDec = bytesToReadableString(txBytes);

  final rxHex = rxBytes
      .map((o) => o.toRadixString(16).padLeft(2, '0'))
      .join(' ');
  final rxDec = bytesToReadableString(rxBytes);

  final message =
      '''
------------------------------------------------------------
TX:HEX: [$txHex]
TX:DEC: $txDec
UUID: ${writeCharacteristic.uuid}
RX:HEX: [$rxHex]
RX:DEC: $rxDec
UUID: ${readCharacteristic.uuid}
STS: RX TIMEOUT
TIME: ${DateTime.now().toIso8601String()}
------------------------------------------------------------
''';

  log(message, name: 'BLE:ERR');
}

void logBleCmd(
  List<int> data,
  BluetoothCharacteristic characteristic, {
  required bool isTransmit,
  bool isValid = true,
}) {
  final hex = data.map((o) => o.toRadixString(16).padLeft(2, '0')).join(' ');
  final dec = bytesToReadableString(data);
  final message =
      '''
 ------------------------------------------------------------
 HEX: [$hex]
 DEC: $dec
 VLD: ${isValid ? '✓' : '✗'}
 UUID: ${characteristic.uuid}
 TIME: ${DateTime.now().toIso8601String()}
 ------------------------------------------------------------
''';

  log(message, name: 'BLE:${isTransmit ? 'TX' : 'RX'}');
}

void logBleStatus(String detail) {
  final message =
      '''
------------------------------------------------------------
STS: $detail
TIME: ${DateTime.now().toIso8601String()}
------------------------------------------------------------
''';

  log(message, name: 'BLE:STS');
}
