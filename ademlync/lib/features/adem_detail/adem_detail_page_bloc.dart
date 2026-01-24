import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/controllers/param_format_manager.dart';
import 'adem_detail_page.dart';

class AdemDetailPageBloc extends Bloc<AdemDetailPageEvent, AdemDetailPageState>
    with AdemActionHelper {
  AdemDetailPageBloc() : super(NotReadyState()) {
    on<FetchEvent>(_handleFetch);
    on<ChangeSNPart2Event>(_handleSNPart2Change);
    on<ChangeCustomerIdEvent>(_handleChangeCustomerId);
    on<ChangeSiteLocationEvent>(_handleChangeSiteLocation);
    on<ChangeAccessCodeEvent>(_handleChangeAccessCode);
    on<ChangeSuperAccessCodeEvent>(_handleChangeSuperAccessCode);
    on<ChangeDateTimeEvent>(_handleChangeDateTime);
  }

  AppDelegate get _app => AppDelegate();
  Adem get _adem => _app.adem;
  CredentialUser get _user => _app.user!;

  Future<void> _handleFetch(
    FetchEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(FetchingState());

    final manager = ParamFormatManager();

    try {
      final response = await fetchForParameters([Param.date, Param.time]);

      final date = manager.autoDecode(Param.date, response);
      final time = manager.autoDecode(Param.time, response);

      _app.updateAdem(_adem.copyWith(date: date, time: time));

      emit(FetchedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleSNPart2Change(
    ChangeSNPart2Event event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(ChangingState());

    final manager = AdemManager();
    final param = Param.serialNumberPart2;
    final data = event.serialNumber.padLeft(
      AdemDetailConfigType.changeSerialNumberPart2.maxChar,
      ' ',
    );

    final tasks = [
      () => manager.write(param.key, data),
      () => manager
          .read(param.key)
          .then(
            (v) => _app.updateAdem(
              _adem.copyWith(
                serialNumberPart2: ParamFormatManager().decode(param, v?.body),
              ),
            ),
          ),
    ];

    try {
      await executeTasks(tasks, accessCode: event.accessCode, userId: _user.id);

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleChangeCustomerId(
    ChangeCustomerIdEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(ChangingState());

    final manager = AdemManager();
    final maxChar = AdemDetailConfigType.changeCustomerId.maxChar;
    final data = event.customerId.padLeft(maxChar, ' ');

    final tasks = [
      () => manager.writeCustomerId(data),
      () => manager.readCustomerId().then(
        (v) => _app.updateAdem(_adem.copyWith(customerId: v)),
      ),
    ];

    try {
      await executeTasks(tasks, accessCode: event.accessCode, userId: _user.id);

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleChangeSiteLocation(
    ChangeSiteLocationEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(ChangingState());

    final manager = AdemManager();
    final maxChar = AdemDetailConfigType.changeCustomerId.maxChar;
    final data =
        event.siteName.padLeft(maxChar, ' ') +
        event.siteAddress.padLeft(maxChar, ' ');

    final tasks = [
      () => manager.writeLocation(data),
      () => manager.readLocation().then(
        (v) => _app.updateAdem(
          _adem.copyWith(siteName: v.first, siteAddress: v.last),
        ),
      ),
    ];

    try {
      await executeTasks(tasks, accessCode: event.accessCode, userId: _user.id);

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleChangeAccessCode(
    ChangeAccessCodeEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(ChangingState());

    final manager = AdemManager();

    final tasks = [() => manager.changeAccessCode(event.value)];

    try {
      await executeTasks(tasks, accessCode: event.accessCode, userId: _user.id);

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleChangeSuperAccessCode(
    ChangeSuperAccessCodeEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(ChangingState());

    final manager = AdemManager();

    final tasks = [() => manager.changeSuperAccess(event.value)];

    try {
      await executeTasks(tasks, accessCode: event.accessCode, userId: _user.id);

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }

  Future<void> _handleChangeDateTime(
    ChangeDateTimeEvent event,
    Emitter<AdemDetailPageState> emit,
  ) async {
    emit(
      AdemDetailPageDateTimeChangeInProgress(isSync: event.ademDate == null),
    );

    final manager = AdemManager();

    final now = DateTime.now().add(const Duration(seconds: 3));
    final date = event.ademDate ?? now;
    final time = event.ademTime ?? now;

    try {
      await executeTasks(
        [
          () => manager.write(Param.date.key, unitDateFmt.format(date)),
          () => manager.write(Param.time.key, unitTimeFmt.format(time)),
        ],
        accessCode: event.accessCode,
        userId: _user.id,
      );

      await executeTasks(
        [
          () => manager
              .read(Param.date.key)
              .then(
                (v) => _app.updateAdem(
                  _app.adem.copyWith(date: DataParser.asDate(v)),
                ),
              ),
          () => manager
              .read(Param.time.key)
              .then(
                (v) => _app.updateAdem(
                  _app.adem.copyWith(time: DataParser.asTime(v)),
                ),
              ),
        ],
        accessCode: event.accessCode,
        userId: _user.id,
      );

      emit(ChangedState());
    } catch (e) {
      emit(FailureState(event, e));
    }
  }
}

// ---- Event ----

abstract class AdemDetailPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchEvent extends AdemDetailPageEvent {}

class ChangeSNPart2Event extends AdemDetailPageEvent {
  final String serialNumber;
  final String accessCode;

  ChangeSNPart2Event(this.serialNumber, this.accessCode);
}

class ChangeCustomerIdEvent extends AdemDetailPageEvent {
  final String customerId;
  final String accessCode;

  ChangeCustomerIdEvent(this.customerId, this.accessCode);
}

class ChangeSiteLocationEvent extends AdemDetailPageEvent {
  final String siteName;
  final String siteAddress;
  final String accessCode;

  ChangeSiteLocationEvent(this.siteName, this.siteAddress, this.accessCode);
}

class ChangeAccessCodeEvent extends AdemDetailPageEvent {
  final String value;
  final String accessCode;

  ChangeAccessCodeEvent(this.value, this.accessCode);
}

class ChangeSuperAccessCodeEvent extends AdemDetailPageEvent {
  final String value;
  final String accessCode;

  ChangeSuperAccessCodeEvent(this.value, this.accessCode);
}

class ChangeDateTimeEvent extends AdemDetailPageEvent {
  final String accessCode;
  final DateTime? ademDate;
  final DateTime? ademTime;

  ChangeDateTimeEvent(this.accessCode, {this.ademDate, this.ademTime});
}

// ---- State ----

abstract class AdemDetailPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class NotReadyState extends AdemDetailPageState {}

class FetchingState extends AdemDetailPageState {}

class FetchedState extends AdemDetailPageState {}

class ChangingState extends AdemDetailPageState {}

class AdemDetailPageDateTimeChangeInProgress extends AdemDetailPageState {
  final bool isSync;

  AdemDetailPageDateTimeChangeInProgress({this.isSync = false});
}

class ChangedState extends AdemDetailPageState {}

class FailureState extends AdemDetailPageState {
  final AdemDetailPageEvent event;
  final Object error;

  FailureState(this.event, this.error);
}
