import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_dropdown.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_list_view.dart';
import '../../utils/widgets/s_support_button.dart';

class CloudPage extends StatefulWidget {
  const CloudPage({super.key});

  @override
  State<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar.withMenu(
        context,
        text: 'Cloud',
        showBluetoothAction: true,
      ),
      body: SmartBodyLayout(
        child: Column(
          spacing: 24.0,
          children: [
            SListView(
              header: 'Upload to Cloud Storage',
              value: const [
                CloudItem.uploadSetupReport,
                CloudItem.uploadSetupConfig,
                CloudItem.uploadCheckReport,
                CloudItem.uploadLogs,
              ],
              textBuilder: (o) => o.text,
              onPressed: _uploadFile,
            ),

            SListView(
              header: 'Download via Email',
              footer:
                  'Selected logs, reports, or configurations will be emailed to your account\'s email address.',
              value: const [
                CloudItem.downloadSetupReport,
                CloudItem.downloadSetupConfig,
                CloudItem.downloadCheckReport,
                CloudItem.downloadLogs,
              ],
              textBuilder: (o) => o.text,
              onPressed: downloadFile,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(CloudItem item) async {
    switch (item) {
      case CloudItem.uploadSetupReport:
        await _toUploadLogsPage(CloudFileType.setupReport);

      case CloudItem.uploadSetupConfig:
        await _toUploadLogsPage(CloudFileType.setupConfig);

      case CloudItem.uploadCheckReport:
        await _toUploadLogsPage(CloudFileType.checkReport);

      case CloudItem.uploadLogs:
        final type = await showModalBottomSheet<LogType>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (_) => const _SelectLogTypeBottomSheet(),
        );

        if (type != null && context.mounted) {
          await _toUploadLogsPage(type.toCloudFileType);
        }

      default:
    }
  }

  Future<void> downloadFile(CloudItem item) async {
    final result = await showModalBottomSheet<(LogType?, String)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) =>
          _SerialNumberBottomSheet(isLogShown: item == CloudItem.downloadLogs),
    );

    if (!context.mounted) return;

    final logType = result?.$1;
    final sn = result?.$2;

    switch (item) {
      case CloudItem.downloadSetupReport when sn != null:
        await _toDownloadLogsPage(CloudFileType.setupReport, sn);

      case CloudItem.downloadSetupConfig when sn != null:
        await _toDownloadLogsPage(CloudFileType.setupConfig, sn);

      case CloudItem.downloadCheckReport when sn != null:
        await _toDownloadLogsPage(CloudFileType.checkReport, sn);

      case CloudItem.downloadLogs when logType != null && sn != null:
        await _toDownloadLogsPage(logType.toCloudFileType, sn);

      default:
    }
  }

  Future<void> _toUploadLogsPage(CloudFileType type) =>
      context.push('/cloud/upload/file', extra: {'fileType': type});

  Future<void> _toDownloadLogsPage(CloudFileType type, String sn) =>
      context.push(
        '/cloud/download/file',
        extra: {'fileType': type, 'serialNumber': sn},
      );
}

class _SelectLogTypeBottomSheet extends StatefulWidget {
  const _SelectLogTypeBottomSheet();

  @override
  State<_SelectLogTypeBottomSheet> createState() =>
      _SelectLogTypeBottomSheetState();
}

class _SelectLogTypeBottomSheetState extends State<_SelectLogTypeBottomSheet> {
  LogType _type = LogType.daily;

  @override
  Widget build(BuildContext context) {
    return SBottomSheetDecoration(
      buttonText: 'Next',
      onPressed: _onPressed,
      child: SDropdownButton(
        value: _type,
        items: LogType.values,
        stringBuilder: (o) => o.displayName,
        onChanged: (o) => setState(() {
          if (o != null) _type = o;
        }),
      ),
    );
  }

  void _onPressed() {
    Navigator.pop(context, _type);
  }
}

class _SerialNumberBottomSheet extends StatefulWidget {
  final bool isLogShown;

  const _SerialNumberBottomSheet({this.isLogShown = false});

  @override
  State<_SerialNumberBottomSheet> createState() =>
      _SerialNumberBottomSheetState();
}

class _SerialNumberBottomSheetState extends State<_SerialNumberBottomSheet> {
  late final _bloc = BlocProvider.of<MainBloc>(context);
  late final _isLogTypeShown = widget.isLogShown;

  final _controller = TextEditingController();
  LogType? _type;

  bool get _isValid => _controller.text.length == snLength;

  @override
  void initState() {
    super.initState();
    if (_isLogTypeShown) _type = LogType.daily;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, state) {
        final isAdemReady = state is MBAdemCachedState;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: SingleChildScrollView(
            child: SBottomSheetDecoration(
              buttonText: 'Next',
              onPressed: _isValid ? _onPressed : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLogTypeShown)
                    SDropdownButton(
                      value: _type,
                      items: LogType.values,
                      stringBuilder: (o) => o.displayName,
                      onChanged: (o) => setState(() {
                        if (o != null) _type = o;
                      }),
                    ),

                  const Gap(24.0),
                  SDataField.stringEdit(
                    controller: _controller,
                    hintText: 'Serial Number',
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    maxLength: snLength,
                    keyboardType: TextInputType.number,
                    formatters: [
                      LengthLimitingTextInputFormatter(8),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: _isValid ? (_) => _onPressed() : null,
                  ),

                  if (isAdemReady) ...[
                    const Gap(8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SSupportButton.autoFill(
                        onPressed: () => setState(() {
                          _controller.text = AppDelegate().adem.serialNumber;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPressed() {
    dismissKeyboard();

    Navigator.pop(context, (_type, _controller.text));
  }
}
