import 'dart:convert';
import 'dart:developer';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/controllers/storage_manager.dart';
import '../../utils/enums.dart';
import 'adem_config.dart';

class ConfigsPageBloc extends Bloc<ConfigsPageEvent, ConfigsPageState>
    with AdemActionHelper {
  ConfigsPageBloc() : super(NotReadyState()) {
    on<FetchEvent>(_mapFetchEventToState);
    on<ImportEvent>(_mapImportEventToState);
  }

  Future<void> _mapFetchEventToState(
    FetchEvent event,
    Emitter<ConfigsPageState> emit,
  ) async {
    emit(FetchingState());

    final storage = StorageManager();
    final res = <AdemConfigDetail>[];

    try {
      final paths = await storage.readFolder(configurationFoldername);

      for (final o in paths) {
        final filename = o.split('/').last.split('.').first;
        final json = await storage.getFile(o);
        final map = Map<String, String>.from(jsonDecode(json));

        final validParams = <Param, String>{};
        final nullParams = <Param>[];

        for (final o in map.entries) {
          final param = Param.values.firstWhereOrNull(
            (e) => e.toString() == o.key,
          );
          if (param == null || param == Param.unknown) continue;

          if (ParamFormatManager().canDecode(param, o.value)) {
            validParams[param] = o.value;
          } else {
            nullParams.add(param);
          }
        }

        log('Null param in config: $nullParams');

        final config = AdemConfig(validParams);
        final detail = config.toDetail(filename, AppDelegate().adem);
        res.add(detail);
      }

      res.sort((a, b) => b.filename.compareTo(a.filename));

      emit(FetchedState(res));
    } catch (e) {
      emit(FailedState(event, e));
    }
  }

  Future<void> _mapImportEventToState(
    ImportEvent event,
    Emitter<ConfigsPageState> emit,
  ) async {
    emit(ImportingState());

    final user = AppDelegate().user;
    final config = event.config.importableConfig(AppDelegate().adem);
    final validParams = <Param, String>{};
    final nullParams = <Param>{};

    try {
      if (user == null) throw NullSafety.user.exception;

      for (final o in config.entries) {
        final sendValue = ParamFormatManager().encode(o.key, o.value);

        if (sendValue != null) {
          validParams[o.key] = sendValue;
        } else {
          nullParams.add(o.key);
        }
      }

      log('Null param in config: $nullParams');

      await executeTasks(
        [
          for (var o in validParams.entries)
            () => AdemManager().write(o.key.key, o.value),
        ],
        accessCode: event.accessCode,
        userId: user.id,
      );

      emit(ImportedState());
    } catch (e) {
      emit(FailedState(event, e));
    }
  }
}

// --- Event ---

abstract class ConfigsPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchEvent extends ConfigsPageEvent {}

class ImportEvent extends ConfigsPageEvent {
  final String accessCode;
  final AdemConfigDetail config;

  ImportEvent(this.accessCode, this.config);
}

// --- State ---

abstract class ConfigsPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class NotReadyState extends ConfigsPageState {}

class FetchingState extends ConfigsPageState {}

class FetchedState extends ConfigsPageState {
  final List<AdemConfigDetail> configs;

  FetchedState(this.configs);
}

class ImportingState extends ConfigsPageState {}

class ImportedState extends ConfigsPageState {}

class FailedState extends ConfigsPageState {
  final ConfigsPageEvent event;
  final Object error;

  FailedState(this.event, this.error);
}
