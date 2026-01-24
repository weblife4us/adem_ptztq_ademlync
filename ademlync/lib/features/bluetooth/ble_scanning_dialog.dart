import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gap/gap.dart';

import '../../chore/main_bloc.dart';
import '../../chore/managers/app_mode_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_dialog_layout.dart';
import '../../utils/widgets/s_loading_animation.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/svg_image.dart';
import 'ble_scanning_dialog_bloc.dart';

Future<void> showBleScanningDialog(BuildContext context) async {
  if (await AppDelegate().isGrantedBluetooth) {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider(
          create: (_) => BleScanningDialogBloc(),
          child: const BleScanningDialog(),
        ),
      );
    }
  } else {
    if (context.mounted) {
      showWarningDialog(
        context,
        title: 'Bluetooth Warning',
        detail: BluetoothError.notReady.description,
      );
    }
  }
}

class BleScanningDialog extends StatefulWidget {
  const BleScanningDialog({super.key});

  @override
  State<BleScanningDialog> createState() => _BleScanningDialogState();
}

class _BleScanningDialogState extends State<BleScanningDialog> {
  late final _bloc = BlocProvider.of<MainBloc>(context);
  late final _subBloc = BlocProvider.of<BleScanningDialogBloc>(context);
  final _manager = BluetoothConnectionManager();
  String? _connectingDeviceId;
  bool _isForcingDisconnect = false;
  late int? _battery = _manager.battery;

  BluetoothDevice? get _connectedDevice => _manager.connectedDevice;

  @override
  void initState() {
    super.initState();

    unawaited(
      _manager.startDeviceScan(isHasAirConsole: AppModeManager().isDebugMode),
    );

    if (_bloc.state is! MBBtConnectingState &&
        _bloc.state is! MBBtDisconnectingState &&
        _bloc.state is! MBBtDisconnectedState) {
      _subBloc.add(BatteryFetchEvent());
    }
  }

  @override
  void dispose() {
    unawaited(_manager.stopDeviceScan());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading =
            state is MBBtConnectingState ||
            state is MBBtDisconnectingState ||
            state is MBAdemCachingState ||
            state is MBAdemCleaningState ||
            _isForcingDisconnect;

        return BlocListener(
          bloc: _subBloc,
          listener: (_, state) {
            if (state is BatteryFetchedState && state.battery != null) {
              setState(() => _battery = state.battery);
            }
          },
          child: SDialogLayout(
            contentPadding: const EdgeInsets.all(12.0),
            isShowCloseButton: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connected
                Card(
                  color: colorScheme.subCardBackground(context),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      spacing: 4.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Connected device
                        _connectedDevice != null
                            ? Column(
                                spacing: 4.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const SvgImage('bluetooth'),
                                          const Gap(4.0),
                                          Expanded(
                                            child: SText.titleMedium(
                                              _mapAdemKeyName(
                                                _connectedDevice!.platformName,
                                              ),
                                            ),
                                          ),
                                          if (_battery != null)
                                            BatteryIndicator(
                                              value: _mapBatteryLevel(
                                                _battery!,
                                              ),
                                              trackColor: Colors.transparent,
                                              barColor: colorScheme.text(
                                                context,
                                              ),
                                              trackBorderColor: colorScheme
                                                  .text(context),
                                            ),
                                        ],
                                      ),
                                      SButton.text(
                                        text: locale.disconnectString,
                                        minimumSize: const Size(0.0, 20.0),
                                        foregroundColor: colorScheme.text(
                                          context,
                                        ),
                                        isLoading:
                                            State is MBBtDisconnectingState,
                                        loadingSize: 12.0,
                                        onPressed: isLoading
                                            ? null
                                            : () => _bloc.add(MBBtDiscEvent()),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    indent: 4.0,
                                    endIndent: 4.0,
                                    color: colorScheme.cardBackground(context),
                                  ),
                                  Row(
                                    spacing: 4.0,
                                    children: [
                                      SvgImage(
                                        state is MBAdemCachedState
                                            ? 'link'
                                            : 'unlink',
                                      ),
                                      Row(
                                        spacing: 4.0,
                                        children: [
                                          SText.titleMedium(
                                            state is MBAdemCachingState
                                                ? 'Preparing'
                                                : state is MBAdemCachedState
                                                ? AppDelegate().adem.displayName
                                                : 'Not Ready',
                                          ),
                                          if (state is MBAdemCachingState)
                                            SLoadingAnimationStaggered(
                                              size: 14.0,
                                              color: colorScheme.text(context),
                                            ),
                                        ],
                                      ),
                                      const Spacer(),
                                      if (state is! MBBtDisconnectedState)
                                        SButton.text(
                                          text: state is MBAdemCachedState
                                              ? 'Clear Cache'
                                              : 'Retrieve',
                                          foregroundColor: colorScheme.text(
                                            context,
                                          ),
                                          minimumSize: const Size(0.0, 20.0),
                                          loadingSize: 12.0,
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  state is MBAdemCachedState
                                                      ? _bloc.add(
                                                          MBAdemCleanEvent(),
                                                        )
                                                      : _bloc.add(
                                                          MBAdemCacheEvent(),
                                                        );
                                                },
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgImage(
                                              'information-square',
                                              height: 20.0,
                                              width: 20.0,
                                              color: colorScheme.grey,
                                            ),
                                            const Gap(4.0),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                    ),
                                                child: SText.titleSmall(
                                                  'If it is stuck in LINK',
                                                  color: colorScheme.grey,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                            SButton.text(
                                              text: 'Force Disconnect',
                                              minimumSize: const Size(
                                                112.0,
                                                20.0,
                                              ),
                                              loadingSize: 12.0,
                                              foregroundColor: colorScheme.text(
                                                context,
                                              ),
                                              isLoading: _isForcingDisconnect,
                                              onPressed: isLoading
                                                  ? null
                                                  : () async {
                                                      if (!_isForcingDisconnect) {
                                                        setState(
                                                          () =>
                                                              _isForcingDisconnect =
                                                                  true,
                                                        );
                                                        try {
                                                          await AppDelegate()
                                                              .forceDisconnect();
                                                        } finally {
                                                          setState(
                                                            () =>
                                                                _isForcingDisconnect =
                                                                    false,
                                                          );
                                                        }
                                                      }
                                                    },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                height: 20.0,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    spacing: 4.0,
                                    children: [
                                      SvgImage('bluetooth-search'),
                                      SText.titleMedium('Select your AdEM key'),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8.0),

                // Other
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SText.bodyMedium('Other'),
                          StreamBuilder<bool>(
                            stream: _manager.deviceScanStream,
                            initialData: true,
                            builder: (_, snapshot) {
                              return snapshot.hasData && snapshot.data!
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SLoadingAnimationThreeArchedCircle(
                                        size: 16.0,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () => _manager.startDeviceScan(
                                        isHasAirConsole:
                                            AppModeManager().isDebugMode,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgImage(
                                          'refresh',
                                          height: 16.0,
                                          width: 16.0,
                                          color: colorScheme.text(context),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),

                      Divider(height: 0.0, color: colorScheme.divider(context)),
                      const Gap(8.0),

                      // Devices list
                      ValueListenableBuilder(
                        valueListenable: _manager.deviceScanNotifier,
                        builder: (_, scannedDevices, _) {
                          final size = MediaQuery.of(context).size;
                          final Size(:width, :height) = size;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: width * 0.9,
                              minHeight: height * 0.3,
                              maxHeight: height * 0.3,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var e in scannedDevices)
                                    InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () async {
                                              setState(
                                                () => _connectingDeviceId =
                                                    e.remoteId.str,
                                              );
                                              _bloc.add(MBBtConnEvent(e));
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        child: Row(
                                          spacing: 2.0,
                                          children: [
                                            SText.bodyMedium(
                                              _mapAdemKeyName(e.platformName),
                                            ),
                                            if (_connectingDeviceId ==
                                                e.remoteId.str)
                                              const SLoadingAnimationStaggered(
                                                size: 12.0,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Close button
                Center(
                  child: SButton.text(
                    text: 'Close',
                    minimumSize: const Size(120.0, 40.0),
                    foregroundColor: colorScheme.text(context),
                    onPressed: isLoading
                        ? null
                        : () async {
                            await _manager.stopDeviceScan();
                            if (context.mounted) Navigator.pop(context);
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    switch (state) {
      case MBBtConnectedState():
        _bloc.add(MBAdemCacheEvent());

        setState(() {
          _connectingDeviceId = null;
          if (state.battery != null) _battery = state.battery;
        });

      case MBAdemCachedState():
        Navigator.pop(context);

      case MBFailedState(:final event, :final error):
        switch (event) {
          case MBBtConnEvent():
            setState(() => _connectingDeviceId = null);
            await handleError(context, error);

          case MBAdemCacheEvent():
            await handleError(context, error);
        }
    }
  }
}

enum BluetoothError {
  notSupported,
  notReady;

  String get description => {
    BluetoothError.notSupported: 'Bluetooth not supported by this device',
    BluetoothError.notReady: 'Please turn on Bluetooth in settings.',
  }[this]!;
}

/// Maps an ADC value to a battery level as a percentage.
///
/// - ADC values less than or equal to 43 return 0.0 (0% battery).
/// - ADC values between 44 and 52 increase the battery level by 10% per step.
/// - ADC values greater than or equal to 53 return 1.0 (100% battery).
double _mapBatteryLevel(int adcValue) {
  if (adcValue <= 43) return 0.0; // Return 0% for ADC <= 43.
  if (adcValue >= 53) return 1.0; // Return 100% for ADC >= 53.
  return (adcValue - 43) * 0.1; // Calculate battery level for ADC 44–52.
}

String _mapAdemKeyName(String name) =>
    RegExp(r'^\d{7}$').hasMatch(name) ? 'K$name' : name;
