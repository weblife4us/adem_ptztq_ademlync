import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';

class CustomDisplayPageBloc
    extends Bloc<CustomDisplayPageEvent, CustomDisplayPageState>
    with AdemActionHelper {
  CustomDisplayPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CustomDisplayPageState> emit,
  ) async {
    emit(DataFetching());

    final info = <Param, String>{};

    try {
      // Fetch params
      final map = await fetchForParameters([
        Param.cstmDispParam1,
        Param.cstmDispParam2,
        Param.cstmDispParam3,
        Param.cstmDispParam4,
        Param.cstmDispParam5,
        Param.cstmDispParam6,
        Param.cstmDispParam7,
        Param.cstmDispParam8,
        Param.cstmDispParam9,
        Param.cstmDispParam10,
        Param.cstmDispParam11,
        Param.cstmDispParam12,
        Param.cstmDispParam13,
        Param.cstmDispParam14,
        Param.cstmDispParam15,
      ]);

      // Map param numbers base on custom params
      final params = map.values
          .where((e) => e != null)
          .map((e) => CustDispItem.from(e?.body))
          .map(
            (e) =>
                e == CustDispItem.notSet ||
                    !AppDelegate().adem.customDisplayParams.contains(e)
                ? null
                : e,
          )
          .whereType<CustDispItem>()
          .map((e) => e.toParam(AppDelegate().adem))
          .toList();

      // Fetch params
      final data = await fetchForParameters(params);

      // Map widgets
      for (var e in data.entries) {
        final value = ParamFormatManager().decodeToDisplayValue(
          e.key,
          e.value?.body,
          AppDelegate().adem,
        );

        if (value != null) info[e.key] = value;
      }

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CustomDisplayPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CustomDisplayPageEvent {}

class UpdateData extends CustomDisplayPageEvent {}

// ---- State ----

abstract class CustomDisplayPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CustomDisplayPageState {}

class DataFetching extends CustomDisplayPageState {}

class DataReady extends CustomDisplayPageState {
  final Map<Param, String> info;

  DataReady(this.info);
}

class FetchDataFailed extends CustomDisplayPageState {
  final Object error;

  FetchDataFailed(this.error);
}
