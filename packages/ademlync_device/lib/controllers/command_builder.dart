import 'dart:convert';

import '../utils/communication_enums.dart';
import '../utils/functions.dart';

/// A service class responsible for building various types of commands as byte arrays.
class CommandBuilder {
  /// Builds a list of bytes representing a command with the [command type] and [parameters].
  static List<int> build(
    CommandType commandType, {
    PMessage? predefinedMessage,
    Protocol? protocol,
    String? accessCode,
    int? itemNumber,
    String? data,
  }) {
    late List<int> commandBytes;

    switch (commandType) {
      case CommandType.connection:
        if (accessCode == null) throw ArgumentError('Access code is required.');
        // Build connection command
        commandBytes = _buildConnectionCommand(accessCode);
        break;

      case CommandType.protocol:
        if (protocol == null) throw ArgumentError('Protocol is required.');
        // Build connection command with protocol
        commandBytes = _buildCommandWithProtocol(
          protocol,
          accessCode,
          itemNumber,
          data,
        );
        break;

      case CommandType.predefinedMessage:
        if (predefinedMessage == null) throw ArgumentError('PM is required.');
        // Build connection command with pre-defined message
        commandBytes = _buildCommandWithPredefinedMessage(predefinedMessage);
        break;
    }

    // Calculate CRC
    final checksum = crcCalculation(commandBytes);

    // Return a byte list
    return [
      ControlChar.soh.byte,
      ...commandBytes,
      ...utf8.encode(checksum),
      ControlChar.eot.byte,
    ];
  }

  /// Builds a connection command using an access code.
  static List<int> _buildConnectionCommand(String accessCode) {
    return [
      ...utf8.encode('SN,$accessCode'),
      ControlChar.stx.byte,
      ...utf8.encode('vqAA'),
      ControlChar.etx.byte,
    ];
  }

  /// Builds a command incorporating a protocol, optionally including an access code, item number, and additional data.
  static List<int> _buildCommandWithProtocol(
    Protocol protocol,
    String? accessCode,
    int? itemNumber,
    String? data,
  ) {
    return [
      ...utf8.encode(protocol.key),
      if (accessCode != null) ...utf8.encode(',$accessCode'),
      if (itemNumber != null || data != null) ControlChar.stx.byte,
      if (itemNumber != null)
        ...utf8.encode(itemNumber.toString().padLeft(3, '0')),
      if (itemNumber != null && data != null) ...utf8.encode(','),
      if (data != null) ...utf8.encode(data),
      ControlChar.etx.byte,
    ];
  }

  /// Builds a command using a predefined message.
  static List<int> _buildCommandWithPredefinedMessage(PMessage pm) {
    return [...utf8.encode(pm.key), ControlChar.etx.byte];
  }
}

enum CommandType { connection, protocol, predefinedMessage }
