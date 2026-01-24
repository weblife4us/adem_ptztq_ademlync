import 'package:ademlync_cloud/utils/enums.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/constants.dart';
import '../../utils/controllers/storage_manager.dart';
import '../../utils/functions.dart';
import 'dp_calculator_enums.dart';
import 'dp_calculator_manager.dart';

class DpCalculatorBloc extends Bloc<DpCalculatorEvent, DpCalculatorState>
    with AdemActionHelper {
  final _manager = DpCalculatorManager();

  DpCalculatorBloc() : super(DpCalculatorInitial()) {
    on<DpCalculatorLocationFetched>(_onDpCalculatorLocationFetched);
    on<DpCalculatorCalculated>(_onDpCalculatorCalculated);
    on<DpCalculatorReportExported>(_onDpCalculatorReportExported);
  }

  Future<void> _onDpCalculatorLocationFetched(
    DpCalculatorLocationFetched event,
    Emitter<DpCalculatorState> emit,
  ) async {
    emit(DpCalculatorLocationFetchInProgress());

    try {
      bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) throw Exception('Location service disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemark = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemark.isEmpty) throw Exception('Placemark is empty.');
      final place = placemark.first;
      final address =
          '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      emit(DpCalculatorLocationFetchSuccess(address));
    } catch (e) {
      emit(DpCalculatorLocationFetchFailure(e));
    }
  }

  Future<void> _onDpCalculatorCalculated(
    DpCalculatorCalculated event,
    Emitter<DpCalculatorState> emit,
  ) async {
    emit(DpCalculatorCalculateInProgress());

    try {
      _manager
        ..setArgument(
          meter: event.meter,
          atmosphericPressPsia: event.atmosphericPress,
          lineGaugePress: event.lineGaugePress,
          lineGaugePressUnit: event.lineGaugePressUnit,
          dpInWc: event.diffPress,
          specificGravity: event.specificGravity,
          uncFlowRate: event.uncFlowRate,
        )
        ..calculate();

      final arg = _manager.argument;
      if (arg == null) throw Exception('arg is null');

      final result = _manager.result;
      if (result == null) throw Exception('Result is null');

      final lastCalculationTime = _manager.lastCalculationTime;
      if (lastCalculationTime == null) {
        throw Exception('lastCalculationTime is null');
      }

      emit(
        DpCalculatorCalculateSuccess(
          arg.uncFlowRate,
          arg.percentMaxFlow,
          result.maxAllowableDp,
          result.isPassed,
          lastCalculationTime,
        ),
      );
    } catch (e) {
      emit(DpCalculatorCalculateFailure(e));
    }
  }

  Future<void> _onDpCalculatorReportExported(
    DpCalculatorReportExported event,
    Emitter<DpCalculatorState> emit,
  ) async {
    emit(DpCalculatorReportExportInProgress());

    try {
      final fmt = ExportFormat.pdf;
      // final fmt = AppDelegate().exportFmt;

      _manager.setStatus(
        badgeSerialNumber: event.badgeSn,
        rometSerialNumber: event.rometSn,
        customerName: event.customerName,
        customerId: event.customerId,
        meterType: event.meterType,
        snPart2: event.snPart2,
        installationSite: event.installationSite,
        indexReading: event.indexReadingAt,
        testedBy: event.testBy,
        comment: event.comments,
      );

      final arg = _manager.argument;
      if (arg == null) throw Exception('arg is null');

      final reportBytes = await _manager.buildReport(fmt);
      if (reportBytes == null) throw Exception('reportBytes is null');

      final lastCalculationTime = _manager.lastCalculationTime;
      if (lastCalculationTime == null) {
        throw Exception('lastCalculationTime is null');
      }

      final filename = mapFilename(
        'Dp Calculation Report',
        '',
        fmt,
        lastCalculationTime,
      );
      await StorageManager().saveFile(
        filename,
        dpCalculatorReportFoldername,
        reportBytes,
      );

      emit(DpCalculatorReportExportSuccess());
    } catch (e) {
      emit(DpCalculatorReportExportFailure(e));
    }
  }
}

sealed class DpCalculatorEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class DpCalculatorLocationFetched extends DpCalculatorEvent {}

final class DpCalculatorCalculated extends DpCalculatorEvent {
  final DpCalculatorMeter meter;
  final double atmosphericPress;
  final double lineGaugePress;
  final GasLineGaugePressureUnit lineGaugePressUnit;
  final double diffPress;
  final double specificGravity;
  final double uncFlowRate;

  DpCalculatorCalculated({
    required this.meter,
    required this.atmosphericPress,
    required this.lineGaugePress,
    required this.lineGaugePressUnit,
    required this.diffPress,
    required this.specificGravity,
    required this.uncFlowRate,
  });
}

final class DpCalculatorReportExported extends DpCalculatorEvent {
  final String badgeSn;
  final String rometSn;
  final String customerName;
  final String customerId;
  final String meterType;
  final String snPart2;
  final String installationSite;
  final String indexReadingAt;
  final String testBy;
  final String comments;

  DpCalculatorReportExported({
    required this.badgeSn,
    required this.rometSn,
    required this.customerName,
    required this.customerId,
    required this.meterType,
    required this.snPart2,
    required this.installationSite,
    required this.indexReadingAt,
    required this.testBy,
    required this.comments,
  });
}

sealed class DpCalculatorState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class DpCalculatorInitial extends DpCalculatorState {}

final class DpCalculatorLocationFetchInProgress extends DpCalculatorState {}

final class DpCalculatorLocationFetchSuccess extends DpCalculatorState {
  final String location;

  DpCalculatorLocationFetchSuccess(this.location);
}

final class DpCalculatorLocationFetchFailure extends DpCalculatorState {
  final Object error;

  DpCalculatorLocationFetchFailure(this.error);
}

final class DpCalculatorCalculateInProgress extends DpCalculatorState {}

final class DpCalculatorCalculateSuccess extends DpCalculatorState {
  final double uncFlowRate;
  final double percentMaxFlow;
  final double maxAllowableDp;
  final bool isPassed;
  final DateTime lastCalculationTime;

  DpCalculatorCalculateSuccess(
    this.uncFlowRate,
    this.percentMaxFlow,
    this.maxAllowableDp,
    this.isPassed,
    this.lastCalculationTime,
  );
}

final class DpCalculatorCalculateFailure extends DpCalculatorState {
  final Object error;

  DpCalculatorCalculateFailure(this.error);
}

final class DpCalculatorReportExportInProgress extends DpCalculatorState {}

final class DpCalculatorReportExportSuccess extends DpCalculatorState {}

final class DpCalculatorReportExportFailure extends DpCalculatorState {
  final Object error;

  DpCalculatorReportExportFailure(this.error);
}
