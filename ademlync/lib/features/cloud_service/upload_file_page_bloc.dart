import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chore/managers/cloud_file_manager.dart';
import '../../utils/controllers/storage_manager.dart';
import '../../utils/functions.dart';

class UploadFilePageBloc
    extends Bloc<UploadFilePageEvent, UploadFilePageState> {
  UploadFilePageBloc() : super(UploadFilePageInitial()) {
    on<UploadFilePageDataFetched>(_onUploadFilePageDataFetched);
    on<UploadFilePageFileUploaded>(_onUploadFilePageFileUploaded);
  }

  Future<void> _onUploadFilePageDataFetched(
    UploadFilePageDataFetched event,
    Emitter<UploadFilePageState> emit,
  ) async {
    emit(UploadFilePageDataFetchInProgress());

    final type = event.type;

    try {
      final filePaths = await StorageManager().readFolder(type.folderName);
      filePaths
        ..removeWhere((e) => ExportFormat.fromFilename(e) == null)
        ..sort((a, b) => b.compareTo(a));

      final folderPaths = await CloudManager().fetchFolders(type);

      emit(UploadFilePageDataFetchSuccess(filePaths, folderPaths));
    } catch (e) {
      emit(UploadFilePageDataFetchFailure(e));
    }
  }

  Future<void> _onUploadFilePageFileUploaded(
    UploadFilePageFileUploaded event,
    Emitter<UploadFilePageState> emit,
  ) async {
    emit(UploadFilePageFileUploadInProgress());

    final filePath = event.filePath;

    try {
      await CloudManager().uploadFile(
        event.sn,
        event.folderPath,
        filePath,
        event.filename,
        event.fmt,
      );

      CloudFileManager().saveUploadedFiles({filePath});

      emit(UploadFilePageFileUploadSuccess());
    } catch (e) {
      emit(UploadFilePageFileUploadFailure(e));
    }
  }
}

sealed class UploadFilePageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UploadFilePageDataFetched extends UploadFilePageEvent {
  final CloudFileType type;

  UploadFilePageDataFetched(this.type);
}

final class UploadFilePageFileUploaded extends UploadFilePageEvent {
  final String sn;
  final String folderPath;
  final String filePath;
  final String filename;
  final ExportFormat fmt;

  UploadFilePageFileUploaded(
    this.sn,
    this.folderPath,
    this.filePath,
    this.filename,
    this.fmt,
  );
}

sealed class UploadFilePageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UploadFilePageInitial extends UploadFilePageState {}

final class UploadFilePageDataFetchInProgress extends UploadFilePageState {}

final class UploadFilePageDataFetchSuccess extends UploadFilePageState {
  final List<String> filePaths;
  final List<String> folderPaths;

  UploadFilePageDataFetchSuccess(this.filePaths, this.folderPaths);
}

final class UploadFilePageDataFetchFailure extends UploadFilePageState {
  final Object error;

  UploadFilePageDataFetchFailure(this.error);
}

final class UploadFilePageFileUploadInProgress extends UploadFilePageState {}

final class UploadFilePageFileUploadSuccess extends UploadFilePageState {}

final class UploadFilePageFileUploadFailure extends UploadFilePageState {
  final Object error;

  UploadFilePageFileUploadFailure(this.error);
}
