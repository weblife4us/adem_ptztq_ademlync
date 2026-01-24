import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../chore/managers/cloud_file_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_file_checkbox.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_support_button.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'upload_file_page_bloc.dart';

class UploadFilePage extends StatefulWidget {
  final CloudFileType fileType;
  final String? filePath;

  const UploadFilePage({super.key, required this.fileType, this.filePath});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  late final _mBloc = BlocProvider.of<MainBloc>(context);
  late final _bloc = BlocProvider.of<UploadFilePageBloc>(context);

  late final _fileType = widget.fileType;
  late final _filePath = widget.filePath;
  List<String>? _filePaths;
  List<String>? _folderPaths;

  final _snController = TextEditingController();
  String? _selectedFile;
  String? _selectedFolder;

  List<String> get _uploadedFiles => CloudFileManager().uploadedFiles;

  bool get _isValid =>
      _selectedFolder != null &&
      _selectedFile != null &&
      _snController.text.length == snLength;

  String get _serialNumber => AppDelegate().adem.serialNumber;

  @override
  void initState() {
    super.initState();
    if (_mBloc.state is MBAdemCachedState) _snController.text = _serialNumber;
    _bloc.add(UploadFilePageDataFetched(_fileType));
  }

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading = state is UploadFilePageFileUploadInProgress;

        return BlocBuilder(
          bloc: _mBloc,
          builder: (_, state) {
            final isAdemReady = state is MBAdemCachedState;

            return GestureDetector(
              onTap: dismissKeyboard,
              child: Scaffold(
                appBar: SAppBar.withSubmit(
                  context,
                  text: 'Upload',
                  isSubmitLoading: isLoading,
                  actionText: 'Confirm',
                  onPressed: _isValid ? _upload : null,
                ),
                body: SmartBodyLayout(
                  child: Column(
                    children: [
                      _Detail(
                        text: _fileType.text,
                        isLoading: isLoading,
                        isShowAutoFill: isAdemReady,
                        controller: _snController,
                        onChanged: () => setState(() {}),
                        onPressed: () =>
                            setState(() => _snController.text = _serialNumber),
                      ),

                      const Gap(24.0),
                      if (_folderPaths != null && _filePaths != null) ...[
                        _Companies(
                          folderPaths: _folderPaths!,
                          folderPath: _selectedFolder,
                          isLoading: isLoading,
                          onChanged: (o) => setState(() => _selectedFolder = o),
                        ),

                        const Gap(24.0),
                        SCard(
                          title: 'Local storage',
                          child: _filePaths!.isEmpty
                              ? const Center(
                                  child: SText.titleMedium(
                                    noLogFoundString,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _LogListView(
                                  filePaths: _filePaths!,
                                  filePath: _selectedFile,
                                  isLoading: isLoading,
                                  isShowChecked: (o) =>
                                      _uploadedFiles.contains(o),
                                  onChanged: (o) => setState(() {
                                    _selectedFile = o;
                                  }),
                                  onPressed: (o) async =>
                                      await openFile(context, o),
                                ),
                        ),
                      ] else
                        const SLoading(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _listener(BuildContext context, Object? state) async {
    switch (state) {
      case UploadFilePageDataFetchSuccess(:final filePaths, :final folderPaths):
        setState(() {
          _folderPaths = folderPaths;
          _filePaths = filePaths;

          if (_filePath != null && _filePaths!.contains(_filePath)) {
            _selectedFile = _filePath;
          }

          if (folderPaths.length == 1) _selectedFolder = folderPaths.single;
          if (filePaths.length == 1) _selectedFile = filePaths.single;
        });

      case UploadFilePageFileUploadSuccess():
        showToast(context, text: 'Upload Succeeded');

      case UploadFilePageDataFetchFailure(:final error):
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

      case UploadFilePageFileUploadFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);
            if (context.mounted && context.canPop()) context.pop();

          default:
            showToast(context, text: 'Upload Failed');
        }
    }
  }

  void _upload() {
    final filename = _selectedFile!.split('/').last;
    final fmt = ExportFormat.fromFilename(filename);

    if (fmt != null) {
      _bloc.add(
        UploadFilePageFileUploaded(
          _snController.text,
          _selectedFolder!,
          _selectedFile!,
          filename,
          fmt,
        ),
      );
    }
  }
}

class _Detail extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool isShowAutoFill;
  final TextEditingController controller;
  final void Function() onChanged;
  final void Function() onPressed;

  const _Detail({
    required this.text,
    required this.isLoading,
    required this.isShowAutoFill,
    required this.controller,
    required this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SText.titleLarge(text),

          const Gap(4.0),
          const SText.bodySmall(
            'Upload to cloud storage based on the ADEM serial number',
            softWrap: true,
          ),

          const Gap(24.0),
          SDataField.stringEdit(
            controller: controller,
            hintText: 'Serial Number',
            textAlign: TextAlign.center,
            isEnabled: !isLoading,
            keyboardType: TextInputType.number,
            formatters: [
              LengthLimitingTextInputFormatter(8),
              FilteringTextInputFormatter.digitsOnly,
            ],
            maxLength: snLength,
            onChanged: (_) => onChanged(),
          ),

          if (isShowAutoFill) ...[
            const Gap(8.0),
            Align(
              alignment: Alignment.centerRight,
              child: SSupportButton.autoFill(
                onPressed: isLoading ? null : onPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Companies extends StatelessWidget {
  final List<String> folderPaths;
  final String? folderPath;
  final bool isLoading;
  final void Function(String?) onChanged;

  const _Companies({
    required this.folderPaths,
    required this.folderPath,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SCard(
      title: 'Upload to...',
      child: folderPaths.isNotEmpty
          ? ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, i) {
                final path = folderPaths[i];
                final isActive = path == folderPath;

                return SFileCheckbox(
                  isActive: isActive,
                  text: path.split('/')[1].toUpperCase().replaceAll('-', ' '),
                  isDisabled: isLoading,
                  onChanged: (_) => onChanged(isActive ? null : path),
                );
              },
              separatorBuilder: (_, _) => const SizedBox.shrink(),
              itemCount: folderPaths.length,
            )
          : const Center(child: SText.bodyMedium('Not company found')),
    );
  }
}

class _LogListView extends StatelessWidget {
  final List<String> filePaths;
  final String? filePath;
  final bool isLoading;
  final bool Function(String) isShowChecked;
  final void Function(String?) onChanged;
  final void Function(String) onPressed;

  const _LogListView({
    required this.filePaths,
    required this.filePath,
    required this.isLoading,
    required this.isShowChecked,
    required this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final path = filePaths[i];
        final isActive = path == filePath;

        return SFileCheckbox(
          isActive: isActive,
          text: path.split('/').last,
          isDisabled: isLoading,
          fileFormat: ExportFormat.fromFilename(path),
          hasQuickLook: isActive,
          isShowChecked: isShowChecked(path),
          onChanged: (_) => onChanged(isActive ? null : path),
          onPressed: isLoading ? null : () => onPressed(path),
        );
      },
      separatorBuilder: (_, _) => const SizedBox.shrink(),
      itemCount: filePaths.length,
    );
  }
}
