import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadFilePageBloc
    extends Bloc<DownloadFilePageEvent, DownloadFilePageState> {
  DownloadFilePageBloc() : super(NotReadyState()) {
    on<DownloadFilePageDataFetched>(_onDownloadFilePageDataFetched);
    on<DownloadFilePageEmailRequested>(_onDownloadFilePageEmailRequested);
  }

  Future<void> _onDownloadFilePageDataFetched(
    DownloadFilePageDataFetched event,
    Emitter<DownloadFilePageState> emit,
  ) async {
    emit(DownloadFilePageDataFetchInProgress());

    try {
      final map = <String, Map<String, List<String>>>{};

      final filePaths = await CloudManager().fetchFiles(
        event.type,
        event.deviceSn,
      );
      filePaths.sort((a, b) => b.compareTo(a));

      for (final o in filePaths) {
        final list = o.split('/');
        final company = list[1];
        final deviceSn = list[2];
        ((map[company] ??= {})[deviceSn] ??= []).add(o);
      }

      emit(DownloadFilePageDataFetchSuccess(map));
    } catch (e) {
      emit(
        _isNoFile(e)
            ? DownloadFilePageDataFetchSuccess(const {})
            : DownloadFilePageDataFetchFailure(e),
      );
    }
  }

  Future<void> _onDownloadFilePageEmailRequested(
    DownloadFilePageEmailRequested event,
    Emitter<DownloadFilePageState> emit,
  ) async {
    emit(DownloadFilePageEmailRequestInProgress());

    try {
      final paths = event.filePaths;

      paths.length == 1
          ? await CloudManager().requestDownloadFileEmail(paths.single)
          : await CloudManager().requestDownloadMultiFileEmail(paths);

      emit(DownloadFilePageEmailRequestSuccess());
    } catch (e) {
      emit(DownloadFilePageEmailRequestFailure(e));
    }
  }

  bool _isNoFile(Object error) {
    if (error case ApiHelperError(detail: Map<String, dynamic> detail)) {
      if (detail case {'body': Map<String, dynamic> body}) {
        if (body case {'message': String message}) {
          return message.contains('No files found');
        }
      }
    }
    return false;
  }
}

sealed class DownloadFilePageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class DownloadFilePageDataFetched extends DownloadFilePageEvent {
  final CloudFileType type;
  final String deviceSn;

  DownloadFilePageDataFetched(this.type, this.deviceSn);
}

final class DownloadFilePageEmailRequested extends DownloadFilePageEvent {
  final List<String> filePaths;

  DownloadFilePageEmailRequested(this.filePaths);
}

sealed class DownloadFilePageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class NotReadyState extends DownloadFilePageState {}

final class DownloadFilePageDataFetchInProgress extends DownloadFilePageState {}

final class DownloadFilePageDataFetchSuccess extends DownloadFilePageState {
  final Map<String, Map<String, List<String>>> fileMap;

  DownloadFilePageDataFetchSuccess(this.fileMap);
}

final class DownloadFilePageDataFetchFailure extends DownloadFilePageState {
  final Object error;

  DownloadFilePageDataFetchFailure(this.error);
}

final class DownloadFilePageEmailRequestInProgress
    extends DownloadFilePageState {}

final class DownloadFilePageEmailRequestSuccess extends DownloadFilePageState {}

final class DownloadFilePageEmailRequestFailure extends DownloadFilePageState {
  final Object error;

  DownloadFilePageEmailRequestFailure(this.error);
}
