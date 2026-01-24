import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ademlync_device.dart';

class BluetoothConnectionManager {
  static final _manager = BluetoothConnectionManager._internal();
  factory BluetoothConnectionManager() => _manager;
  BluetoothConnectionManager._internal() {
    FlutterBluePlus.setLogLevel(LogLevel.info, color: false);
  }

  StreamSubscription<List<ScanResult>>? _deviceScanStream;
  StreamSubscription<BluetoothConnectionState>? _deviceConnStream;

  final deviceScanNotifier = ValueNotifier(<BluetoothDevice>[]);
  late bool isBtSupported;

  int? _battery;
  int? get battery => _battery;

  final _deviceScanController = StreamController<bool>.broadcast();
  Stream<bool> get deviceScanStream => _deviceScanController.stream;

  /// Returns the currently connected Bluetooth device if exactly one is connected, otherwise null.
  BluetoothDevice? get connectedDevice {
    final devices = FlutterBluePlus.connectedDevices;
    return devices.isNotEmpty && devices.length == 1 ? devices.single : null;
  }

  bool get isReady => writeCharacteristic != null && readCharacteristic != null;

  /// Determines if the connected device is an Air Console by checking if it has the Air Console service UUID.
  bool isAirConsole() {
    final id = Guid(serviceIdAc);
    final res = connectedDevice?.servicesList.any((e) => e.serviceUuid == id);
    return res ?? false;
  }

  /// Returns the readable Bluetooth characteristic based on device type.
  /// Returns Air Console read characteristic if device is Air Console, otherwise AdEM Key read characteristic.
  BluetoothCharacteristic? get readCharacteristic {
    final id = isAirConsole() ? readCharacteristicAc : readCharacteristicDf;
    return _findCharacteristic(Guid(id));
  }

  /// Returns the writable Bluetooth characteristic based on device type.
  /// Returns Air Console write characteristic if device is Air Console, otherwise AdEM Key write characteristic.
  BluetoothCharacteristic? get writeCharacteristic {
    final id = isAirConsole() ? writeCharacteristicAc : writeCharacteristicDf;
    return _findCharacteristic(Guid(id));
  }

  /// Helper function to retrieve a Bluetooth characteristic by its UUID.
  /// First finds the service by service UUID based on device type, then finds the characteristic within that service.
  BluetoothCharacteristic? _findCharacteristic(Guid id) {
    final serviceId = Guid(isAirConsole() ? serviceIdAc : serviceIdDf);
    final service = connectedDevice?.servicesList.firstWhereOrNull(
      (e) => e.serviceUuid == serviceId,
    );
    final characteristic = service?.characteristics.firstWhereOrNull(
      (e) => e.characteristicUuid == id,
    );
    return characteristic;
  }

  Future<void> observeStatus() async {
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint('Bluetooth not supported by this device');
      return;
    }

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> startDeviceScan({
    bool isHasAirConsole = false,
    int timeoutMinute = 3,
  }) async {
    _deviceScanController.sink.add(true);

    // Keep track of the last update time
    DateTime lastUpdate = DateTime.now();

    // listen to scan results
    // Note: `onScanResults` clears the results between scans. You should use
    //  `scanResults` if you want the current scan results *or* the results from the previous scan.
    _deviceScanStream = FlutterBluePlus.scanResults.listen(
      (results) {
        // Add a delay of 2 seconds between updates for each device
        if (DateTime.now().difference(lastUpdate).inSeconds >= 2) {
          lastUpdate = DateTime.now();

          // Sort by RSSI
          results.sort((a, b) => a.rssi.compareTo(b.rssi));

          // Map out devices
          final devices = results.map((e) => e.device).toList();

          if (!listEquals(deviceScanNotifier.value.ids, devices.ids)) {
            deviceScanNotifier.value = devices;
          }
        }
      },
      onError: (e) {
        log('Timeout', name: 'Ble-Comm', level: 2);
      },
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(_deviceScanStream!);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
      withServices: [Guid(serviceIdDf), if (isHasAirConsole) Guid(serviceIdAc)],
      timeout: Duration(minutes: timeoutMinute),
      removeIfGone: const Duration(seconds: 3),
      continuousUpdates: true,
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    _deviceScanController.sink.add(false);
  }

  Future<void> stopDeviceScan() async {
    _deviceScanController.sink.add(false);
    await FlutterBluePlus.stopScan();
    await _deviceScanStream?.cancel();
    _deviceScanStream = null;
  }

  Future<void> connect(BluetoothDevice device) async {
    if (connectedDevice != null || _deviceConnStream != null) {
      await disconnect();
    }

    try {
      await device.connect();

      if (connectedDevice == null) {
        throw Exception('No connected device found.');
      }

      const timeoutDuration = Duration(seconds: 10);
      final stream = connectedDevice!.connectionState.timeout(timeoutDuration);

      if (Platform.isAndroid) await connectedDevice?.requestMtu(247);

      await for (var status in stream) {
        if (status == BluetoothConnectionState.connected) {
          await device.discoverServices();

          if (writeCharacteristic == null) {
            throw Exception('No write characteristic found.');
          }

          if (readCharacteristic == null) {
            throw Exception('No read characteristic found.');
          }

          await readCharacteristic!.setNotifyValue(true);

          deviceScanNotifier.value.remove(connectedDevice);
          break;
        }
      }

      _deviceConnStream = connectedDevice!.connectionState.listen((
        status,
      ) async {
        log(status.toString(), name: 'Ble-Conn', level: 3);
      });
    } catch (e) {
      await disconnect();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    await _deviceConnStream?.cancel();
    _deviceConnStream = null;
    _battery = null;
  }

  Future<int?> fetchBattery() async {
    try {
      const command = 'batt';
      final bytes = utf8.encode(command);

      final response = await CommunicationManager(
        writeCharacteristic!,
        readCharacteristic!,
        isAirConsole(),
      ).communicateWithDongle(bytes, timeout: readBattTimeoutInMs);

      if (response.last == ControlChar.eot.byte) response.removeLast();

      _battery = double.tryParse(utf8.decode(response))?.clamp(0, 100).toInt();
    } catch (e) {
      throw const AdemCommError(AdemCommErrorType.dongleBatteryFail);
    }

    return _battery;
  }
}

extension _BluetoothDevicesExt on List<BluetoothDevice> {
  List<String> get ids => map((e) => e.remoteId.str).toList();
}
