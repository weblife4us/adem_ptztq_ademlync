import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../models/modules/push_button_module.dart';

import '../models/adem/adem.dart';
import '../models/adem/config_cache.dart';
import '../models/adem/measure_cache.dart';
import '../models/adem_response.dart';
import '../models/log/log.dart';
import '../utils/adem_param.dart';
import '../utils/communication_enums.dart';
import '../utils/constants.dart';
import '../utils/data_parser.dart';
import '../utils/error_enum.dart';
import '../utils/functions.dart';
import 'bluetooth_connection_manager.dart';
import 'cache_manager.dart';
import 'command_builder.dart';
import 'communication_manager.dart';

class AdemManager {
  // Singleton
  static final _manager = AdemManager._internal();
  factory AdemManager() => _manager;
  AdemManager._internal();

  Adem? _adem;
  String _accessCode = defaultAccessCode;
  bool _isConnecting = false;

  final _cache = CacheManager();

  CommunicationManager get _commService {
    try {
      final manager = BluetoothConnectionManager();
      return CommunicationManager(
        manager.writeCharacteristic!,
        manager.readCharacteristic!,
        manager.isAirConsole(),
      );
    } catch (e) {
      throw const AdemCommError(
        AdemCommErrorType.connectionBroken,
        'writeCharacteristic / readCharacteristic not ready',
      );
    }
  }

  /// Returns the stored [_adem] or throws an exception if null.
  Adem get adem {
    try {
      return _adem!;
    } catch (e) {
      throw StateError('AdEM is not ready.');
    }
  }

  /// Updates the stored Adem object with a new Adem instance
  void updateAdem(Adem adem) {
    _adem = adem;
  }

  /// Caches a [ConfigCache] instance
  void cacheConfig(ConfigCache data) {
    _cache.cacheConfig(data);
  }

  /// Caches a [MeasureCache] instance
  void cacheMeasure(MeasureCache data) {
    _cache.cacheMeasure(data);
  }

  /// Caches a [PushButtonModule] instance
  void cachePushButtonModule(PushButtonModule data) {
    _cache.cachePushButtonModule(data);
  }

  /// Fetches `data` and `cache`.
  Future<void> fetchAdem() async {
    final completer = Completer<void>();
    Object? error;
    Timer? timer;

    final Map<Param, AdemResponse?> map = {};
    String? productType;
    String? firmware;
    List<String>? location;
    String? customId;
    AdemType? ademType;

    try {
      // Wake up the AdEM
      await wakeUp();

      // Build a connection with AdEM
      await connect();

      // Set a timer for auto disconnection
      timer = Timer(const Duration(seconds: ademConnTimeoutInSec), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      // Fetch firmware and valid it
      firmware = await readFirmware();
      if (firmware.startsWith('E')) productType = await readProductType();

      ademType = AdemType.from(firmware, productType);

      // Fetch the location
      location = await readLocation();

      // Fetch the customer id
      customId = await readCustomerId();

      // Fetch all available config params
      for (var e in _getConfigParams(ademType)) {
        bool isTimeout = false;
        final stopwatch = Stopwatch()..start();
        do {
          try {
            isTimeout = false;
            map[e] = await read(e.key, ademType: ademType);
          } catch (e) {
            isTimeout =
                e is AdemCommError &&
                e.type == AdemCommErrorType.receiveTimeout;

            if (stopwatch.elapsedMilliseconds >= retryMs ||
                completer.isCompleted) {
              stopwatch.stop();
              rethrow;
            }

            await Future.delayed(const Duration(milliseconds: retryDelay));
          }
        } while (isTimeout && !completer.isCompleted);
      }

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      try {
        // Terminate the AdEM connection
        await disconnect();
      } catch (e) {
        if (error == null) rethrow;
      }
      timer?.cancel();
    }

    // Map data and init the AdEM
    _initAdem(firmware, productType, location, customId, map, ademType);
  }

  /// Cleans `data` and `cache`.
  void clearAdem() {
    _adem = null;
    CacheManager().clear();
  }

  /// Wakes up the unit, optionally retrying once if the first attempt fails.
  Future<void> wakeUp({bool retry = true}) async {
    try {
      // Sent out the wake up comment
      await _commService.communicateWithoutResponse([ControlChar.eot.byte]);
      final response = await _commService.communicate([
        ControlChar.enq.byte,
      ], timeout: wakeUpTimeoutInMs);

      // Validate the ACK response
      if (!response.isSingle ||
          response.rawData.single != ControlChar.ack.byte) {
        final error = response.pMessage?.ademCommunicationErrorType;
        throw AdemCommError(
          error ?? AdemCommErrorType.unknown,
          '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}',
        );
      }
    } catch (_) {
      if (retry) {
        Object? error;

        try {
          await disconnect(hasRetry: false, isForced: true);
        } catch (e) {
          error = e;
        }

        if (error == null) {
          await wakeUp(retry: false);
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Connects to the unit using an access code.
  Future<void> connect([String? accessCode]) async {
    if (accessCode != null) {
      // Use user's access code
      _accessCode = accessCode;
    } else {
      // Use default access code
      _accessCode = defaultAccessCode;
    }

    // Sent out the build connection comment
    final response = await _commService.communicate(
      CommandBuilder.build(CommandType.connection, accessCode: _accessCode),
      timeout: connectTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    final pm = response.pMessage;
    if (pm != PMessage.acknowledge) {
      // Handle the error
      final error = pm?.ademCommunicationErrorType;
      throw AdemCommError(
        error ?? AdemCommErrorType.unknown,
        '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}',
      );
    }

    _isConnecting = true;
  }

  /// Disconnects from the unit, optionally retrying once if the first attempt fails.
  Future<void> disconnect({
    bool hasRetry = true,
    bool isForced = false,
    int timeout = disconnectTimeoutInMs,
  }) async {
    // Reset the access code
    _accessCode = defaultAccessCode;

    // If there is connection built or force to disconnect
    if (_isConnecting || isForced) {
      try {
        // Sent out the disconnect comment
        final response = await _commService.communicate(
          CommandBuilder.build(
            CommandType.protocol,
            protocol: Protocol.disconnectLink,
          ),
          timeout: timeout,
        );

        // Validate the CRC
        _checkValidCrc(response);

        // Validate the response
        final pm = response.pMessage;
        if (!discSuccessPm.contains(pm)) {
          // Handle the error
          final error = pm?.ademCommunicationErrorType;
          throw AdemCommError(
            error ?? AdemCommErrorType.unknown,
            '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}',
          );
        }
      } catch (e) {
        if (e case AdemCommError(:final type)) {
          switch (type) {
            case AdemCommErrorType.receiveTimeout when hasRetry:
              await disconnect(
                hasRetry: false,
                isForced: isForced,
                timeout: timeout,
              );
              break;

            default:
              break;
          }
        }
      }
    }
  }

  /// Sends a read command to a unit for a specified item number from the BLE device, with an optional parameter check.
  Future<AdemResponse?> read(
    int itemNumber, {
    bool checking = true,
    AdemType? ademType,
  }) async {
    AdemResponse? response;
    final type = ademType ?? _adem?.type;

    if (checking && type != null) {
      // Determine if the param is valid
      if (_isValidParam(itemNumber, type)) {
        response = await _read(itemNumber);

        // Determine if there is data return
        if (_isNoData(response.body, type)) {
          response = null;
          // Log the param
          _logUnavailableParamWarning(itemNumber, type);
        }
      } else {
        // Log the param
        _logUnavailableParamWarning(itemNumber, type);
      }
    } else {
      response = await _read(itemNumber);
    }

    return response;
  }

  Future<AdemResponse> _read(int itemNumber) async {
    // Sent out the read comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.read,
        itemNumber: itemNumber,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads the firmware version.
  Future<String> readFirmware() async {
    // Sent out the comment
    final response = await read(Param.firmwareVersion.key, checking: false);

    // Validate the response
    if (response == null) {
      throw const AdemCommError(AdemCommErrorType.firmwareNotFound);
    }

    return response.body;
  }

  Future<String> readProductType() async {
    final response = await read(Param.productType.key, checking: false);

    if (response == null) {
      throw const AdemCommError(AdemCommErrorType.productTypeNotFound);
    }

    return response.body;
  }

  /// Reads the location information from the unit.
  Future<List<String>> readLocation() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.readLocation,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    // Map location data
    final data = utf8.decode(response.rawBody);
    final siteName = data.substring(0, 16).trim();
    final siteAddress = data.substring(16, 32).trim();

    return [siteName, siteAddress];
  }

  /// Reads the customer ID from the unit.
  Future<String> readCustomerId() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.readCustomerId,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response.body;
  }

  /// Sends a write command to a unit for a specified item with data.
  Future<void> write(int itemNumber, String data) async {
    if (_adem != null) {
      // Determine if this is valid param
      if (_isValidParam(itemNumber, _adem!.type)) {
        // Sent out the comment
        final response = await _commService.communicate(
          CommandBuilder.build(
            CommandType.protocol,
            protocol: Protocol.write,
            accessCode: _accessCode,
            itemNumber: itemNumber,
            data: data,
          ),
          timeout: writeParamTimeoutInMs,
        );

        // Validate the CRC
        _checkValidCrc(response);

        // Validate the response
        _checkAckPm(response);
      } else {
        // Log the param
        _logUnavailableParamWarning(itemNumber, _adem!.type);
      }
    }
  }

  /// Writes the user ID to the event log on the unit.
  Future<void> writeUserIdToEventLog(String userId) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.write,
        accessCode: _accessCode,
        itemNumber: Param.eventLogger.key,
        data: userId.padLeft(8, ' '),
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkAckPm(response);
  }

  /// Writes the provided location data to the unit.
  Future<void> writeLocation(String data) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.writeLocation,
        accessCode: _accessCode,
        data: data,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkAckPm(response);
  }

  /// Writes the provided customer ID to the unit.
  Future<void> writeCustomerId(String data) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.writeCustomerId,
        accessCode: _accessCode,
        data: data,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkAckPm(response);
  }

  /// Updates the access code on the unit to the new code provided.
  Future<void> changeAccessCode(String data) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.changeAccessCode,
        accessCode: _accessCode,
        data: data,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkAckPm(response);
  }

  /// Updates the super code on the unit to the new code provided.
  Future<void> changeSuperAccess(String data) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.changeSuperAccess,
        accessCode: _accessCode,
        data: data,
      ),
      timeout: readParamTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkAckPm(response);
  }

  /// Reads daily logs from the unit based on specified date/time range.
  Future<AdemResponse> readDailyLogs(
    DateTime from,
    DateTime to, [
    int itemCount = 8,
  ]) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.dailyLog,
        data: '$itemCount,${logPeriodFmtString(from, to)}',
      ),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads alarm logs from the unit.
  Future<AdemResponse> readAlarmLogs() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.readAlarmLogger,
      ),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads alarm logs from the unit.
  Future<AdemResponse> readAdem25AlarmLogs(
    DateTime from,
    DateTime to, [
    Adem25AlarmLogType type = Adem25AlarmLogType.fullFields,
  ]) async {
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.readAlarmLoggerAdem25,
        data: '${type.key},${logPeriodFmtString(from, to)}',
      ),
      timeout: readLogTimeoutInMs,
    );

    _checkValidCrc(response);
    _checkNonErrorPm(response);
    return response;
  }

  /// Reads event logs from the unit.
  Future<AdemResponse> readEventLogs() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.eventLog,
        data: EventLogType.read.key,
      ),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads event logs from the unit.
  Future<AdemResponse> readAdem25EventLogs(
    DateTime from,
    DateTime to, [
    Adem25EventLogType type = Adem25EventLogType.fullFields,
  ]) async {
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.eventLogAdem25,
        data: '${type.key},${logPeriodFmtString(from, to)}',
      ),
      timeout: readLogTimeoutInMs,
    );

    _checkValidCrc(response);
    _checkNonErrorPm(response);
    return response;
  }

  /// Initiates the download of event logs from the unit.
  Future<AdemResponse> downloadEventLogs() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.eventLog,
        data: EventLogType.download.key,
      ),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads Q logs from the unit.
  Future<AdemResponse> readQLogs() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(CommandType.protocol, protocol: Protocol.qLog),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads flow DP logs from the unit.
  Future<AdemResponse> readFlowDpLogs() async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(CommandType.protocol, protocol: Protocol.flowDpLog),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Reads interval logs from the unit based on specified type and date/time range.
  Future<AdemResponse> readIntervalLogs(
    IntervalLogType type,
    DateTime from,
    DateTime to,
  ) async {
    // Sent out the comment
    final response = await _commService.communicate(
      CommandBuilder.build(
        CommandType.protocol,
        protocol: Protocol.intervalLog,
        data: '${type.key},${logPeriodFmtString(from, to)}',
      ),
      timeout: readLogTimeoutInMs,
    );

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Sends an acknowledgment signal to the unit.
  Future<AdemResponse> sendAck() async {
    // Sent out the comment
    final response = await _commService.communicate([
      ControlChar.ack.byte,
    ], timeout: readLogTimeoutInMs);

    // Validate the CRC
    _checkValidCrc(response);

    // Validate the response
    _checkNonErrorPm(response);

    return response;
  }

  /// Determines the availability of a parameter for a specified item number and device unit.
  bool _isValidParam(int itemNumber, AdemType type) {
    return !unavailableParams(type).contains(itemNumber);
  }

  /// Checks if the provided data matches the noDataString symbol of the connected device unit.
  bool _isNoData(String data, AdemType type) {
    return data.trim() == type.noDataSymbol;
  }

  /// Logs a warning when a parameter is unavailable for the specified device unit.
  void _logUnavailableParamWarning(int itemNumber, AdemType type) {
    log(
      '$itemNumber is not available for ${_adem?.displayName}',
      name: 'ParameterUnavailable',
      level: 2,
    );
  }

  /// Asserts that the message received is an acknowledgment message.
  void _checkAckPm(AdemResponse response) {
    final pm = response.pMessage;
    if (pm != PMessage.acknowledge) {
      final error = pm?.ademCommunicationErrorType;
      throw AdemCommError(
        error ?? AdemCommErrorType.unknown,
        '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}',
      );
    }
  }

  /// Ensures the message received is not an error message.
  void _checkNonErrorPm(AdemResponse response) {
    final pm = response.pMessage;
    if (errorPm.contains(pm)) {
      final error = pm?.ademCommunicationErrorType;
      throw AdemCommError(
        error ?? AdemCommErrorType.unknown,
        '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}',
      );
    }
  }

  /// Validates the CRC of a Bluetooth Low Energy (BLE) response.
  void _checkValidCrc(AdemResponse response) {
    final crc = response.crc;
    if (crc != null && !response.has255FromAdem) {
      final start = response.hasSoh ? 1 : 0;
      final end = response.indexOfEtx + 1;
      final bytes = response.rawData.sublist(start, end);
      final checksum = crcCalculation(bytes);

      if (crc != checksum) {
        throw AdemCommError(
          AdemCommErrorType.receiveCrcError,
          '${bytesToReadableString(response.rawData)}\n${response.rawData.toString()}\n Expected:$checksum',
        );
      }
    }
  }

  /// Confirms that the current unit has not been switched.
  Future<void> checkAdemNotSwitch() async {
    final response = await read(Param.serialNumber.key, checking: false);
    if (response == null) {
      throw const AdemCommError(AdemCommErrorType.serialNumberNotFound);
    }

    if (_adem != null && response.body != _adem!.serialNumber) {
      throw const AdemCommError(AdemCommErrorType.ademSwitched);
    }
  }

  void _initAdem(
    String firmware,
    String? productType,
    List<String> location,
    String customId,
    Map<Param, AdemResponse?> map,
    AdemType type,
  ) {
    CacheManager()
      ..cacheConfig(_mapConfigCache(map))
      ..cacheMeasure(_mapMeasureCache(map, type))
      ..cachePushButtonModule(_mapPushButtonModule(map));

    _adem = Adem(
      map[Param.serialNumber]!.body,
      map[Param.serialNumberPart2]?.body,
      productType,
      firmware,
      map[Param.firmwareChecksum]?.body,
      location.first,
      location.last,
      customId,
      DataParser.asDate(map[Param.date])!,
      DataParser.asTime(map[Param.time])!,
    );
  }

  ConfigCache _mapConfigCache(Map<Param, AdemResponse?> map) {
    return ConfigCache(
      gasDayStartTime: DataParser.asDate(map[Param.gasDayStartTime])!,
      dateFmt: UnitDateFmt.from(map[Param.dateFormat]?.body)!,
      timeFmt: 'hh:mm a',
      lastSaveDate: DataParser.asDate(map[Param.lastSaveDate]),
      lastSaveTime: DataParser.asTime(map[Param.lastSaveTime]),
      backupIdxCounter: DataParser.asInt(map[Param.backupIndexCounter])!,
      dispTestPattern: map[Param.displayTestPattern]!.body,
      batteryType: BatteryType.from(map[Param.batteryType]?.body)!,
      isSealed: DataParser.asBool(map[Param.sealStatus]?.body)!,
    );
  }

  MeasureCache _mapMeasureCache(Map<Param, AdemResponse?> map, AdemType type) {
    final meterSize = MeterSize.from(map[Param.meterSize]?.body);
    DiffPressUnit? differentialPressureUnit;
    LineGaugePressUnit? lineGaugePressureUnit;

    if (type == AdemType.ademTq) {
      final measSys = meterSize!.serial.system;
      differentialPressureUnit = measSys.toDiffPressUnit;
      lineGaugePressureUnit = measSys.toLineGaugePressUnit;
    }

    return MeasureCache(
      meterSize: type.isMeterSizeSupported ? meterSize! : null,
      isDotShowed: DataParser.asBool(map[Param.showDot]?.body),
      uncVolUnit: VolumeUnit.from(map[Param.uncVolUnit]?.body),
      corVolUnit: VolumeUnit.from(map[Param.corVolUnit]?.body),
      uncVolDigits: VolDigits.from(map[Param.uncVolDigits]?.body),
      corVolDigits: VolDigits.from(map[Param.corVolDigits]?.body),
      dispVolSelect: DispVolSelect.from(map[Param.dispVolSelect]?.body),
      superXFactorType: FactorType.from(map[Param.superXFactorType]?.body),
      superXAlgorithm: SuperXAlgo.from(map[Param.superXAlgo]?.body),
      intervalType: IntervalLogType.from(map[Param.intervalLogType]?.body)!,
      intervalSetting: IntervalLogInterval.from(
        map[Param.intervalLogInterval]?.body,
      ),
      intervalFields: [
        IntervalLogField.from(map[Param.intervalField5]?.body),
        IntervalLogField.from(map[Param.intervalField6]?.body),
        IntervalLogField.from(map[Param.intervalField7]?.body),
        IntervalLogField.from(map[Param.intervalField8]?.body),
        IntervalLogField.from(map[Param.intervalField9]?.body),
        IntervalLogField.from(map[Param.intervalField10]?.body),
      ],
      pressFactorType: FactorType.from(map[Param.pressFactorType]?.body),
      pressUnit: PressUnit.from(map[Param.pressUnit]?.body),
      pressTransType: PressTransType.from(map[Param.pressTransType]?.body),
      differentialPressureUnit: differentialPressureUnit,
      lineGaugePressureUnit: lineGaugePressureUnit,
      tempFactorType: FactorType.from(map[Param.tempFactorType]?.body),
      tempUnit: TempUnit.from(map[Param.tempUnit]?.body),
      inputPulseVolUnit: InputPulseVolumeUnit.from(
        map[Param.inputPulseVolUnit]?.body,
      ),
      uncOutputPulseVolUnit: VolumeUnit.from(
        map[Param.uncOutputPulseVolUnit]?.body,
      ),
      corOutputPulseVolUnit: VolumeUnit.from(
        map[Param.corOutputPulseVolUnit]?.body,
      ),
    );
  }

  PushButtonModule _mapPushButtonModule(Map<Param, AdemResponse?> map) {
    return PushButtonModule(
      isProvingPulsesEnabled: DataParser.asBool(
        map[Param.pushBtnProvingPulsesOpFunc]?.body,
      ),
    );
  }

  List<Param> _getConfigParams(AdemType type) {
    return [
      Param.serialNumber,
      Param.serialNumberPart2,
      Param.firmwareChecksum,
      Param.date,
      Param.time,
      Param.gasDayStartTime,
      Param.dateFormat,
      Param.lastSaveDate,
      Param.lastSaveTime,
      Param.backupIndexCounter,
      Param.displayTestPattern,
      Param.batteryType,
      Param.sealStatus,
      Param.uncVolUnit,
      Param.corVolUnit,
      Param.uncVolDigits,
      Param.corVolDigits,
      Param.dispVolSelect,
      Param.superXFactorType,
      Param.superXAlgo,
      Param.intervalLogType,
      Param.intervalLogInterval,
      Param.intervalField5,
      Param.intervalField6,
      Param.intervalField7,
      Param.intervalField8,
      Param.intervalField9,
      Param.intervalField10,
      Param.pressFactorType,
      Param.pressUnit,
      Param.pressTransType,
      Param.tempFactorType,
      Param.tempUnit,
      Param.inputPulseVolUnit,
      Param.uncOutputPulseVolUnit,
      Param.corOutputPulseVolUnit,
      if (type.isMeterSizeSupported) Param.meterSize,
      if (type == AdemType.ademTq) Param.differentialPressureUnit,
      if (type == AdemType.ademTq) Param.lineGaugePressureUnit,
      Param.pushBtnProvingPulsesOpFunc,
      Param.showDot,
    ];
  }
}
