import 'dart:developer';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/controllers/storage_manager.dart';
import '../../utils/functions.dart';
import '../adem_config/adem_config.dart';
import 'report.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> with AdemActionHelper {
  ExportBloc() : super(NotReadyState()) {
    on<ConfigExportEvent>(_mapConfigExportEventToState);
    on<ReportExportEvent>(_mapReportExportEventToState);
    on<NonFetchedReportExportEvent>(_mapNonFetchedReportExportEventToState);
    on<FileOpenEvent>(_mapFileOpenEventToState);
  }

  Future<List<List<String>>> _buildReportData(Set<Param> params) async {
    final map = await fetchForParameters(params.toList());

    final data = <List<String>>[];

    final format = ParamFormatManager();

    if (format.autoDecode(Param.superXFactorType, map) case FactorType? type) {
      final p = <Param>{};

      switch (type) {
        case FactorType.live:
          if (format.autoDecode(Param.superXAlgo, map) case SuperXAlgo algo) {
            switch (algo) {
              case SuperXAlgo.nx19:
                p.addAll({
                  Param.gasMoleH2,
                  Param.gasMoleHs,
                  Param.aga8GasComponentMolar,
                });

              case SuperXAlgo.aga8:
                p.addAll({
                  Param.gasSpecificGravity,
                  Param.gasMoleN2,
                  Param.gasMoleCO2,
                  Param.gasMoleH2,
                  Param.gasMoleHs,
                });

              case SuperXAlgo.sgerg88:
                p.addAll({Param.gasMoleN2, Param.aga8GasComponentMolar});

              case SuperXAlgo.aga8G1:
                p.addAll({
                  Param.gasMoleN2,
                  Param.gasMoleH2,
                  Param.aga8GasComponentMolar,
                });

              case SuperXAlgo.aga8G2:
                p.addAll({
                  Param.gasMoleH2,
                  Param.gasMoleHs,
                  Param.aga8GasComponentMolar,
                });
            }
          }

        case FactorType.fixed:
        case null:
          p.addAll({
            Param.superXAlgo,
            Param.gasSpecificGravity,
            Param.gasMoleCO2,
            Param.gasMoleH2,
            Param.gasMoleHs,
            Param.gasMoleN2,
            Param.aga8GasComponentMolar,
          });
      }

      map.removeWhere((k, v) => p.contains(k));
    }

    for (final o in map.entries) {
      final key = o.key;

      if (o.value?.body != null && key != Param.aga8GasComponentMolar) {
        final val = ParamFormatManager().decodeToDisplayValue(
          key,
          o.value?.body,
          AppDelegate().adem,
        );

        if (val != null) {
          data.add([key.displayName, val, key.unit(AppDelegate().adem) ?? '']);
        }
      }
    }

    // Handle AGA8
    if (map.keys.contains(Param.aga8GasComponentMolar)) {
      final val = Aga8Config.from(map[Param.aga8GasComponentMolar]?.body);

      if (val != null) {
        data
          ..add(['AGA 8 Detail'])
          ..addAll([
            for (var e in Aga8Param.values)
              [
                e.displayName,
                switch (e) {
                  Aga8Param.methane => val.methane,
                  Aga8Param.ethane => val.ethane,
                  Aga8Param.hydrogenSulphide => val.hydrogenSulphide,
                  Aga8Param.oxygen => val.oxygen,
                  Aga8Param.isoPentane => val.isoPentane,
                  Aga8Param.nHeptane => val.nHeptane,
                  Aga8Param.nDecane => val.nDecane,
                  Aga8Param.nitrogen => val.nitrogen,
                  Aga8Param.propane => val.propane,
                  Aga8Param.hydrogen => val.hydrogen,
                  Aga8Param.isoButane => val.isoButane,
                  Aga8Param.nPentane => val.nPentane,
                  Aga8Param.nOctane => val.nOctane,
                  Aga8Param.helium => val.helium,
                  Aga8Param.carbonDioxide => val.carbonDioxide,
                  Aga8Param.water => val.water,
                  Aga8Param.carbonMonoxide => val.carbonMonoxide,
                  Aga8Param.nButane => val.nButane,
                  Aga8Param.nHexane => val.nHexane,
                  Aga8Param.nNonane => val.nNonane,
                  Aga8Param.argon => val.argon,
                }.toString(),
                '%',
              ],
          ]);
      }
    }

    final meterSize =
        ParamFormatManager().autoDecode(Param.meterSize, map) as MeterSize;

    int index = data.indexWhere((o) => o.first == Param.meterSize.displayName);
    data.insert(index, [
      'Meter Manuf. and Model',
      meterSize.serial.displayName,
      '',
    ]);

    index = data.indexWhere((o) => o.first == Param.date.displayName);
    data.insert(index, ['Customer ID', AppDelegate().adem.customerId, '']);

    return data;
  }

  Future<void> _mapConfigExportEventToState(
    ConfigExportEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(FileExportingState());

    final serialNumber = AppDelegate().adem.serialNumber;
    final filename = mapFilename(
      serialNumber,
      'CONFIG',
      ExportFormat.json,
      DateTime.now(),
    );
    final validParams = <Param, String>{};
    final nullParams = <Param>{};

    try {
      final map = await fetchForParameters(event.params.toList());

      for (final o in map.entries) {
        final key = o.key;
        final value = o.value?.body;

        if (value != null && ParamFormatManager().canDecode(key, value)) {
          validParams[key] = value;
        } else {
          nullParams.add(key);
        }
      }

      log('Null param in config: $nullParams');

      final config = AdemConfig(validParams);
      final path = await StorageManager().saveFile(
        filename,
        configurationFoldername,
        config.toBytes(),
      );

      emit(FileExportedState(path, filename));
    } catch (e) {
      emit(FileExportFailedState(e));
    }
  }

  Future<void> _mapReportExportEventToState(
    ReportExportEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(FileExportingState());

    final serialNumber = AppDelegate().adem.serialNumber;
    final filename = mapFilename(
      serialNumber,
      event.symbol,
      event.exportFormat,
      event.dateTime,
    );

    try {
      final bytes = await event.report.toBytes(event.exportFormat);
      final path = await StorageManager().saveFile(
        filename,
        event.folderName,
        bytes,
      );

      emit(FileExportedState(path, filename));
    } catch (e) {
      emit(FileExportFailedState(e));
    }
  }

  Future<void> _mapNonFetchedReportExportEventToState(
    NonFetchedReportExportEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(FileExportingState());

    final serialNumber = AppDelegate().adem.serialNumber;
    final exportFormat = event.exportFormat;
    final filename = mapFilename(
      serialNumber,
      event.symbol,
      exportFormat,
      event.dateTime,
    );

    try {
      final records = await _buildReportData(event.params);
      final report = Report(
        title: event.title,
        headers: const ['Param', 'Value', 'Unit'],
        records: records,
        dateTime: event.dateTime,
      );
      final bytes = await report.toBytes(exportFormat);
      final path = await StorageManager().saveFile(
        filename,
        event.folderName,
        bytes,
      );

      emit(FileExportedState(path, filename));
    } catch (e) {
      emit(FileExportFailedState(e));
    }
  }

  Future<void> _mapFileOpenEventToState(
    FileOpenEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(FileOpeningState());

    try {
      final result = await StorageManager().openFile(event.path);

      emit(FileOpenedState(getOpenFileResultMessage(result)));
    } catch (e) {
      emit(FileOpenFailedState(event, e));
    }
  }
}

// ---- Event ----

abstract class ExportEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class ConfigExportEvent extends ExportEvent {
  final Set<Param> params;

  ConfigExportEvent(this.params);
}

class NonFetchedReportExportEvent extends ExportEvent {
  final Set<Param> params;
  final ExportFormat exportFormat;
  final String folderName;
  final String symbol;
  final String title;
  final DateTime dateTime;

  NonFetchedReportExportEvent({
    required this.params,
    required this.exportFormat,
    required this.folderName,
    required this.symbol,
    required this.title,
    required this.dateTime,
  });
}

class ReportExportEvent extends ExportEvent {
  final ExportFormat exportFormat;
  final String folderName;
  final String symbol;
  final Report report;
  final DateTime dateTime;

  ReportExportEvent({
    required this.exportFormat,
    required this.folderName,
    required this.symbol,
    required this.report,
    required this.dateTime,
  });
}

class FileOpenEvent extends ExportEvent {
  final String path;

  FileOpenEvent(this.path);
}

// ---- State ----

abstract class ExportState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class NotReadyState extends ExportState {}

class FileExportingState extends ExportState {}

class FileExportedState extends ExportState {
  final String filePath;
  final String filename;

  FileExportedState(this.filePath, this.filename);
}

class FileExportFailedState extends ExportState {
  final Object error;

  FileExportFailedState(this.error);
}

class FileOpeningState extends ExportState {}

class FileOpenedState extends ExportState {
  final String toast;

  FileOpenedState(this.toast);
}

class FileOpenFailedState extends ExportState {
  final ExportEvent event;
  final Object error;

  FileOpenFailedState(this.event, this.error);
}
