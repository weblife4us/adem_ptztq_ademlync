import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'setup_aga8_detail_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class SetupAga8PageBloc extends Bloc<SetupAga8PageEvent, SetupAga8PageState>
    with AdemActionHelper {
  SetupAga8PageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<SetupAga8PageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([Param.aga8GasComponentMolar]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final aga8 = manager.autoDecode(Param.aga8GasComponentMolar, map);

      if (aga8 == null) throw Exception('Aga8 is null.');

      emit(DataReady(SetupAga8DetailPageModel.from(aga8)));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<SetupAga8PageState> emit,
  ) async {
    emit(DataUpdating());

    final manager = ParamFormatManager();

    final user = AppDelegate().user;
    final cInfo = event.cInfo;

    try {
      if (user == null) throw NullSafety.user.exception;

      // Fetch support values
      final map = await fetchForParameters([Param.basePress, Param.baseTemp]);

      final basePress = manager.autoDecode(Param.basePress, map);
      final baseTemp = manager.autoDecode(Param.baseTemp, map);

      if (baseTemp is! double || basePress is! double) {
        throw Exception('Base Temp or Base Press is null.');
      }

      // Calculate values
      final aga8 =
          Aga8Manger(basePress, baseTemp, AppDelegate().adem.pressUnit!, [
            cInfo.percentiles[Aga8Param.methane]!,
            cInfo.percentiles[Aga8Param.nitrogen]!,
            cInfo.percentiles[Aga8Param.carbonDioxide]!,
            cInfo.percentiles[Aga8Param.ethane]!,
            cInfo.percentiles[Aga8Param.propane]!,
            cInfo.percentiles[Aga8Param.water]!,
            cInfo.percentiles[Aga8Param.hydrogenSulphide]!,
            cInfo.percentiles[Aga8Param.hydrogen]!,
            cInfo.percentiles[Aga8Param.carbonMonoxide]!,
            cInfo.percentiles[Aga8Param.oxygen]!,
            cInfo.percentiles[Aga8Param.isoButane]!,
            cInfo.percentiles[Aga8Param.nButane]!,
            cInfo.percentiles[Aga8Param.isoPentane]!,
            cInfo.percentiles[Aga8Param.nPentane]!,
            cInfo.percentiles[Aga8Param.nHexane]!,
            cInfo.percentiles[Aga8Param.nHeptane]!,
            cInfo.percentiles[Aga8Param.nOctane]!,
            cInfo.percentiles[Aga8Param.nNonane]!,
            cInfo.percentiles[Aga8Param.nDecane]!,
            cInfo.percentiles[Aga8Param.helium]!,
            cInfo.percentiles[Aga8Param.argon]!,
          ]);

      final key = Param.aga8GasComponentMolar.key;

      await executeTasks(
        [
          for (final o in aga8.mapDetail()) () => AdemManager().write(key, o),
          () => AdemManager().write(key, aga8.mapConfig()),
        ],
        accessCode: event.accessCode,
        userId: user.id,
      );

      emit(DataUpdated());
    } catch (e) {
      emit(UpdateDataFailed(e));
    }

    add(FetchData());
  }
}

// ---- Event ----

abstract class SetupAga8PageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends SetupAga8PageEvent {}

class UpdateData extends SetupAga8PageEvent {
  final String accessCode;
  final SetupAga8DetailPageModel cInfo;

  UpdateData(this.accessCode, this.cInfo);
}

// ---- State ----

abstract class SetupAga8PageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends SetupAga8PageState {}

class DataFetching extends SetupAga8PageState {}

class DataUpdating extends SetupAga8PageState {}

class DataReady extends SetupAga8PageState {
  final SetupAga8DetailPageModel info;

  DataReady(this.info);
}

class DataUpdated extends SetupAga8PageState {}

class FetchDataFailed extends SetupAga8PageState {
  final Object error;

  FetchDataFailed(this.error);
}

class UpdateDataFailed extends SetupAga8PageState {
  final Object error;

  UpdateDataFailed(this.error);
}
