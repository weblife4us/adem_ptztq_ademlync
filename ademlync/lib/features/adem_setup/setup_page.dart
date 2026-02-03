import 'dart:async';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../chore/managers/cloud_file_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_dialog_layout.dart';
import '../../utils/widgets/s_list_view.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../file_export/export_bloc.dart';

class SetupPage extends StatefulWidget {
  final bool hasChecking;

  const SetupPage({super.key, this.hasChecking = false});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late final _mBloc = BlocProvider.of<MainBloc>(context);
  late final _eBloc = BlocProvider.of<ExportBloc>(context);

  BuildContext? _dialogContext;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.hasChecking) return;
      await _handleMfaSetup();
      await _handlePendingLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _eBloc,
      listener: _listener,
      child: BlocBuilder(
        bloc: _mBloc,
        builder: (_, state) {
          final isAdemReady = state is MBAdemCachedState;

          final items = [
            SetupItem.basic,
            SetupItem.pressAndTemp,
            SetupItem.statistic,
            SetupItem.display,
            if (isAdemReady &&
                AppDelegate().adem.measureCache.superXAlgorithm ==
                    SuperXAlgo.aga8)
              SetupItem.aga8,
            if (isAdemReady && AppDelegate().adem.type.hasQMonitor)
              SetupItem.qMonitor,
          ];

          return Scaffold(
            appBar: SAppBar.withMenu(
              context,
              text: locale.setUpString,
              showBluetoothAction: true,
            ),
            body: SmartBodyLayout(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SListView(
                  value: items,
                  textBuilder: (o) => o.text,
                  iconBuilder: (o) => o.svg,
                  disableChecker: (_) => !isAdemReady,
                  onPressed: (o) => unawaited(context.push(o.location)),
                ),
                if (isAdemReady) ...[
                  SListView(
                    value: const [
                      SetupItem.configExport,
                      SetupItem.setupReportExport,
                    ],
                    textBuilder: (o) => o.text,
                    iconBuilder: (o) => o.svg,
                    onPressed: (o) => switch (o) {
                      SetupItem.configExport => _exportConfig(),
                      SetupItem.setupReportExport => _exportReport(
                        AppDelegate().exportFmt,
                      ),
                      _ => null,
                    },
                  ),
                ],
                if (isAdemReady) ...[
                  SListView(
                    value: const [SetupItem.configImport],
                    textBuilder: (o) => o.text,
                    iconBuilder: (o) => o.svg,
                    hasArrow: true,
                    onPressed: (o) => switch (o) {
                      SetupItem.configImport => _importConfig(),
                      _ => null,
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _listener(BuildContext context, Object? state) {
    if (state is FileExportedState) {
      if (_dialogContext != null) Navigator.pop(_dialogContext!);
      showExportSuccessToast(context);
    } else if (state is FileExportFailedState) {
      if (_dialogContext != null) Navigator.pop(_dialogContext!);
      showToast(context, text: 'Export failed.');
    }
  }

  Future<void> _handlePendingLog() async {
    if (!await CloudFileManager().anyNonUploadedLogs) return;
    if (!mounted) return;

    final isUpload = await showDialog(
      context: context,
      builder: (_) => const _UploadLogRemainder(),
    );

    if (isUpload == true && mounted) context.push('/cloud');
  }

  Future<void> _handleMfaSetup() async {
    final user = AppDelegate().user;
    if (user == null) return;

    final isEnabled = await CloudManager().getMfaStatus(user.email);
    if (isEnabled != false) return;

    if (!mounted) return;
    final isSetup = await showDialog<bool>(
      context: context,
      builder: (_) => const _MfaIntroductionDialog(),
    );

    if (isSetup == true && mounted) await context.push('/mfa');
  }

  void _exportReport(ExportFormat format) {
    _eBloc.add(
      NonFetchedReportExportEvent(
        params: setupReportParams,
        exportFormat: AppDelegate().exportFmt,
        folderName: setupReportFoldername,
        symbol: 'SETUP',
        title: 'Setup Report',
        dateTime: DateTime.now(),
      ),
    );

    _showLoading();
  }

  void _exportConfig() {
    _eBloc.add(ConfigExportEvent(ademConfigParams(AppDelegate().adem)));
    _showLoading();
  }

  Future<void> _importConfig() async {
    await context.push('/setup/configuration');
  }

  void _showLoading() {
    unawaited(
      showLoadingDialog(
        context,
        onBuild: (context) => _dialogContext = context,
        text: 'Exporting...',
      ),
    );
  }
}

class _UploadLogRemainder extends StatelessWidget {
  const _UploadLogRemainder();

  @override
  Widget build(BuildContext context) {
    return SDialogLayout(
      title: 'Log Upload Remainder',
      isShowCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SText.titleMedium(
            'Some logs in your local storage haven\'t been uploaded yet. Don\'t forget to back them up to the cloud.',
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          Container(
            height: 100.0,
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(vertical: 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: colorScheme.subCardBackground(context),
            ),
            child: FutureBuilder(
              future: CloudFileManager().nonUploadedLogs,
              builder: (context, snapshot) {
                final data = snapshot.data;

                return data == null || data.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (_, i) {
                          final temp = data[i].split('/');
                          final o =
                              '${temp[temp.length - 2]}/${temp[temp.length - 1]}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SText.bodyMedium(o, softWrap: true),
                          );
                        },
                        separatorBuilder: (_, _) =>
                            Divider(color: colorScheme.cardBackground(context)),
                        itemCount: data.length,
                      );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SButton.filled(
                text: 'Upload Now',
                onPressed: () => Navigator.pop(context, true),
              ),
              const Gap(12.0),
              SButton.outlined(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MfaIntroductionDialog extends StatelessWidget {
  const _MfaIntroductionDialog();

  @override
  Widget build(BuildContext context) {
    return SDialogLayout(
      title: 'Setup MFA',
      detail:
          'Multi-Factor Authentication (MFA) is now required to keep your ROMET account secure.',
      isShowCloseButton: false,
      child: Column(
        spacing: 32.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              SButton.filled(
                text: 'Setup',
                onPressed: () => Navigator.pop(context, true),
              ),

              SButton.outlined(
                text: 'Maybe Later',
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
