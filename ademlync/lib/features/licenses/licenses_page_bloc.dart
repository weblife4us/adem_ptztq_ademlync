import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../oss_licenses.dart';

class LicensesBloc extends Bloc<LicensesEvent, LicensesState>
    with AdemActionHelper {
  LicensesBloc() : super(LPBNotReadyState()) {
    on<LPBFetchEvent>(_mapLPBFetchEventToState);
  }

  Future<void> _mapLPBFetchEventToState(
    LPBFetchEvent event,
    Emitter<LicensesState> emit,
  ) async {
    emit(LPBFetchingState());

    try {
      // merging non-dart dependency list using LicenseRegistry.
      final lm = <String, List<String>>{};
      await for (var l in LicenseRegistry.licenses) {
        for (var p in l.packages) {
          final lp = lm.putIfAbsent(p, () => []);
          lp.addAll(l.paragraphs.map((p) => p.text));
        }
      }
      final licenses = allDependencies.toList();
      for (var key in lm.keys) {
        licenses.add(
          Package(
            name: key,
            description: '',
            authors: [],
            version: '',
            license: lm[key]!.join('\n\n'),
            isMarkdown: false,
            isSdk: false,
            dependencies: [],
            devDependencies: [],
          ),
        );
      }

      licenses.sort((a, b) => a.name.compareTo(b.name));

      emit(LPBReadyState(licenses));
    } catch (e) {
      emit(LPBFailedState(e));
    }
  }
}

// ---- Event ----

abstract class LicensesEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class LPBFetchEvent extends LicensesEvent {}

// ---- State ----

abstract class LicensesState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class LPBNotReadyState extends LicensesState {}

class LPBFetchingState extends LicensesState {}

class LPBReadyState extends LicensesState {
  final List<Package> info;

  LPBReadyState(this.info);
}

class LPBFailedState extends LicensesState {
  final Object error;

  LPBFailedState(this.error);
}
