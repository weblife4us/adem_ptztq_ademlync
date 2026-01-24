import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import '../../utils/widgets/s_file_checkbox.dart';
import '../../utils/widgets/s_loading.dart';
import 'download_file_page_bloc.dart';

class DownloadLogPage extends StatefulWidget {
  final CloudFileType fileType;
  final String serialNumber;

  const DownloadLogPage({
    super.key,
    required this.fileType,
    required this.serialNumber,
  });

  @override
  State<DownloadLogPage> createState() => _DownloadLogPageState();
}

class _DownloadLogPageState extends State<DownloadLogPage> {
  late final _bloc = BlocProvider.of<DownloadFilePageBloc>(context);

  late final _fileType = widget.fileType;
  late final _serialNumber = widget.serialNumber;

  Map<String, Map<String, List<String>>>? _fileMap;
  final _paths = <String>{};

  @override
  void initState() {
    super.initState();
    _bloc.add(DownloadFilePageDataFetched(_fileType, _serialNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading = state is DownloadFilePageEmailRequestInProgress;

        return Scaffold(
          appBar: SAppBar.withSubmit(
            context,
            text: 'Download',
            isSubmitLoading: isLoading,
            actionText: 'Confirm',
            onPressed: _paths.isNotEmpty ? _submit : null,
          ),
          body: SmartBodyLayout(
            child: Column(
              children: [
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SText.titleLarge(_fileType.text),

                      const Gap(4.0),
                      const SText.bodySmall(
                        'Download link will be sent to your email.',
                        softWrap: true,
                      ),

                      const Gap(24.0),
                      Row(
                        children: [
                          const SvgImage('mail-send'),
                          const Gap(8.0),
                          SText.titleMedium(
                            AppDelegate().user?.email ?? '-',
                            softWrap: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(24.0),
                _fileMap == null
                    ? const SLoading()
                    : _fileMap!.isEmpty
                    ? const SText.titleMedium(
                        'No files found. Please upload your log first.',
                        softWrap: true,
                      )
                    : _FileListView(
                        fileMap: _fileMap,
                        selectedPaths: _paths,
                        isLoading: isLoading,
                        onChanged: _onFileChanged,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _listener(BuildContext context, Object? state) async {
    switch (state) {
      case DownloadFilePageDataFetchSuccess(:final fileMap):
        setState(() => _fileMap = fileMap);

      case DownloadFilePageEmailRequestSuccess():
        showToast(context, text: 'Email sent successfully');

      case DownloadFilePageDataFetchFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);
            if (context.mounted && context.canPop()) context.pop();

          default:
            await handleError(context, state.error);
            if (context.mounted && context.canPop()) context.pop();
        }

      case DownloadFilePageEmailRequestFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);
            if (context.mounted && context.canPop()) context.pop();

          default:
            showToast(context, text: 'Email sent failed');
            if (context.mounted && context.canPop()) context.pop();
        }
    }
  }

  void _submit() => _bloc.add(DownloadFilePageEmailRequested(_paths.toList()));

  void _onFileChanged(String o) =>
      setState(() => _paths.contains(o) ? _paths.remove(o) : _paths.add(o));
}

class _FileListView extends StatelessWidget {
  final Map<String, Map<String, List<String>>>? fileMap;
  final Set<String> selectedPaths;
  final bool isLoading;
  final void Function(String) onChanged;

  const _FileListView({
    required this.fileMap,
    required this.selectedPaths,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final companyEntry = fileMap!.entries.toList()[i];
        final company = companyEntry.key;
        final devices = companyEntry.value;

        return SCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SvgImage('folder'),
                  const Gap(8.0),
                  Expanded(child: SText.titleMedium(company)),
                ],
              ),

              const Gap(24.0),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, j) {
                  final deviceEntry = devices.entries.toList()[j];
                  final deviceSn = deviceEntry.key;
                  final filePaths = deviceEntry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SText.titleMedium(deviceSn),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, k) {
                          final path = filePaths[k];

                          return SFileCheckbox(
                            isActive: selectedPaths.contains(path),
                            text: path.split('/').last,
                            isDisabled: isLoading,
                            fileFormat: ExportFormat.fromFilename(path),
                            onChanged: (_) => onChanged(path),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox.shrink(),
                        itemCount: filePaths.length,
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, _) => const Gap(24.0),
                itemCount: devices.length,
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, _) => const Gap(24.0),
      itemCount: fileMap!.entries.length,
    );
  }
}
