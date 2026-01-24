import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../utils/communication_enums.dart';

// Represents the raw data received from a BLE device and provides utilities to
// parse and check for control characters.
class AdemResponse extends Equatable {
  final List<int> rawData;
  final int indexOfSoh;
  final int indexOfStx;
  final int indexOfEtx;
  final int indexOfEot;
  final int indexOfRs;
  final int indexOfAck;

  AdemResponse(this.rawData)
    : indexOfSoh = rawData.indexOf(ControlChar.soh.byte),
      indexOfStx = rawData.indexOf(ControlChar.stx.byte),
      indexOfEtx = rawData.indexOf(ControlChar.etx.byte),
      indexOfEot = rawData.indexOf(ControlChar.eot.byte),
      indexOfRs = rawData.indexOf(ControlChar.rs.byte),
      indexOfAck = rawData.indexOf(ControlChar.ack.byte);

  @override
  List<Object?> get props => [rawData];

  /// Private helper property to check if rawData contains only one element.
  bool get isSingle => rawData.length == 1;

  // Public properties to check the presence of specific control characters.
  bool get hasSoh => indexOfSoh != -1;
  bool get hasStx => indexOfStx != -1;
  bool get hasEtx => indexOfEtx != -1;
  bool get hasEot => indexOfEot != -1;
  bool get hasRs => indexOfRs != -1;
  bool get hasAck => indexOfAck != -1;

  /// Extracts the raw head data from rawData, if applicable.
  /// Returns null if the conditions for extracting head data are not met.
  List<int>? get rawHead =>
      !isSingle && hasStx ? rawData.sublist(hasSoh ? 1 : 0, indexOfStx) : null;

  /// Extracts the body data from rawData, adjusted for control characters.
  /// Returns the entire rawData if no specific delimiters are found.
  List<int> get rawBody => !isSingle
      ? rawData.sublist(
          hasStx ? indexOfStx + 1 : (hasSoh ? 1 : 0),
          hasEtx ? indexOfEtx : rawData.length,
        )
      : rawData;

  /// Extracts the CRC (Cyclic Redundancy Check) data from rawData, if applicable.
  /// Returns null if the conditions for extracting CRC data are not met.
  List<int>? get rawCrc => !isSingle && hasEtx
      ? rawData.sublist(indexOfEtx + 1, rawData.length - 1)
      : null;

  bool get has255FromAdem => rawData.contains(255);

  /// Decodes the head data from rawHead to a String, if rawHead is not null.
  /// Returns null if rawHead is null.
  String? get head => _decode(rawHead);

  /// Decodes the body data from rawBody to a String. Guaranteed not to be null.
  String get body => _decode(rawBody)!;

  /// Decodes the CRC data from rawCrc to a String, if rawCrc is not null.
  /// Returns null if rawCrc is null.
  String? get crc => _decode(rawCrc);

  /// Interprets the body data as a predefined message.
  PMessage? get pMessage => getPMessage(body);

  /// Attempts to decode a list of integers into a String using UTF-8 encoding.
  /// Trims the resulting String to remove any leading or trailing whitespace.
  /// Throws a DecodeException if decoding fails.
  String? _decode(List<int>? data) {
    if (data == null) return null;
    try {
      // NOTE: Handle 255 from AdEM
      if (has255FromAdem) {
        for (var i = 0; i < data.length; i++) {
          if (data[i] == 255) data[i] = 32;
        }
      }
      return utf8.decode(data);
    } catch (e) {
      throw DecodeException('Failed to decode data: $e');
    }
  }
}

// NOTE: Hardcode solve: Don't trim the data...Data contains spacing which is wrong.
String? decodeBleResponseBodyFor3ptCalibration(AdemResponse? data) {
  if (data == null) return null;
  try {
    // NOTE: Handle 255 from AdEM
    if (data.has255FromAdem) {
      for (var i = 0; i < data.rawBody.length; i++) {
        if (data.rawBody[i] == 255) data.rawBody[i] = 32;
      }
    }
    return utf8.decode(data.rawBody);
  } catch (e) {
    throw DecodeException('Failed to decode data: $e');
  }
}

/// Custom exception class for handling decoding errors.
class DecodeException implements Exception {
  final String message;

  DecodeException(this.message);

  @override
  String toString() => 'DecodeException: $message';
}
