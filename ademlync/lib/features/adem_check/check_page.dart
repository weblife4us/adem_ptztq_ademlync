import 'dart:async';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../file_export/export_bloc.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_list_view.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  late final _mBloc = BlocProvider.of<MainBloc>(context);
  late final _eBloc = BlocProvider.of<ExportBloc>(context);

  BuildContext? _dialogContext;

  Adem get _adem => AppDelegate().adem;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      bloc: _eBloc,
      listener: _listener,
      child: BlocBuilder<MainBloc, MainState>(
        bloc: _mBloc,
        builder: (_, state) {
          final isAdemReady = state is MBAdemCachedState;
          final items = [
            CheckItem.basic,
            CheckItem.battery,
            CheckItem.alarm,
            CheckItem.factor,
            CheckItem.statistic,
            CheckItem.display,
            if (isAdemReady &&
                _adem.measureCache.superXAlgorithm == SuperXAlgo.aga8)
              CheckItem.aga8,
            if (isAdemReady && _adem.type.isAdemTq) CheckItem.qMonitor,
          ];
          final items2 = [CheckItem.checkReportExport];

          return Scaffold(
            appBar: SAppBar.withMenu(
              context,
              text: locale.checkString,
              showBluetoothAction: true,
            ),
            body: SmartBodyLayout(
              crossAxisAlignment: CrossAxisAlignment.start,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SListView(
                    value: items,
                    textBuilder: (o) => o.text,
                    iconBuilder: (o) => o.svg,
                    disableChecker: (_) => !isAdemReady,
                    onPressed: (o) => unawaited(context.push(o.location)),
                  ),
                  if (isAdemReady) ...[
                    const Gap(24.0),
                    SListView(
                      value: items2,
                      textBuilder: (o) => o.text,
                      iconBuilder: (o) => o.svg,
                      onPressed: (o) => switch (o) {
                        CheckItem.checkReportExport => _exportReport(
                          AppDelegate().exportFmt,
                        ),
                        _ => null,
                      },
                    ),
                  ],
                ],
              ),
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

  void _exportReport(ExportFormat format) {
    _eBloc.add(
      NonFetchedReportExportEvent(
        params: checkReportParams,
        exportFormat: format,
        folderName: checkReportFoldername,
        symbol: 'CHECK',
        title: 'Check Report',
        dateTime: DateTime.now(),
      ),
    );
    _showLoading();
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
