import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../chore/main_bloc.dart';
import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_list_view.dart';
import 'event_log_bottom_sheet.dart';
import 'time_range_bottom_sheet.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> with AccessCodeHelper {
  late final _bloc = BlocProvider.of<MainBloc>(context);

  LogTimeRange _dailyLogRange = LogTimeRange(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  LogTimeRange _intervalLogRange = LogTimeRange(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  LogTimeRange _alarmLogRange = LogTimeRange(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  LogTimeRange _eventLogRange = LogTimeRange(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  Adem get _adem => AppDelegate().adem;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, state) {
        final isAdemReady = state is MBAdemCachedState;
        final items = [
          LogItem.daily,
          LogItem.interval,
          LogItem.event,
          LogItem.alarm,
          if (isAdemReady && _adem.hasTqLog) ...[LogItem.q, LogItem.dp],
        ];

        return Scaffold(
          appBar: SAppBar.withMenu(
            context,
            text: 'Log',
            showBluetoothAction: true,
          ),
          body: SmartBodyLayout(
            child: SListView(
              value: items,
              textBuilder: (o) => o.text,
              iconBuilder: (o) => o.svg,
              disableChecker: (_) => !isAdemReady,
              onPressed: _onPressed,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onPressed(LogItem type) async {
    switch (type) {
      case LogItem.daily:
      case LogItem.interval:
      case LogItem.alarm when _adem.isAdem25:
        await _fetchPeriodicLog(type);
        break;

      case LogItem.event:
        await _fetchEventLog();
        break;

      case LogItem.alarm:
      case LogItem.q:
      case LogItem.dp:
        await context.push(type.location);
        break;
    }
  }

  Future<bool?> _showPeriodBottomSheet(
    BuildContext context,
    LogItem item,
  ) async {
    final period = switch (item) {
      LogItem.daily => _dailyLogRange,
      LogItem.interval => _intervalLogRange,
      LogItem.alarm => _alarmLogRange,
      LogItem.event => _eventLogRange,
      _ => null,
    };

    if (period == null) return null;

    return await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) {
        return TimeRangeBottomSheet(
          type: item,
          range: period,
          onChanged: (o) {
            switch (item) {
              case LogItem.daily:
                _dailyLogRange = o;
                break;

              case LogItem.interval:
                _intervalLogRange = o;
                break;

              case LogItem.alarm:
                _alarmLogRange = o;
                break;

              case LogItem.event:
                _eventLogRange = o;
                break;

              default:
            }
          },
        );
      },
    );
  }

  Future<bool?> _showEventTypeBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const EventLogBottomSheet(),
    );
  }

  Future<void> _fetchEventLog() async {
    final isUpdate = await _showEventTypeBottomSheet();
    if (isUpdate == null || !mounted) return;

    if (isUpdate) {
      final accessCode = await getAccessCode(
        context,
        isRequireSuperAccessCode: true,
      );

      if (accessCode != null && mounted) {
        await context.push(LogItem.event.location, extra: accessCode);
      }
    } else if (_adem.isAdem25) {
      await _fetchPeriodicLog(LogItem.event);
    } else {
      await context.push(LogItem.event.location);
    }
  }

  Future<void> _fetchPeriodicLog(LogItem type) async {
    final isPeriodic = await _showPeriodBottomSheet(context, type);
    if (isPeriodic == null || !mounted) return;

    if (isPeriodic) {
      final period = switch (type) {
        LogItem.daily => _dailyLogRange,
        LogItem.interval => _intervalLogRange,
        LogItem.alarm => _alarmLogRange,
        LogItem.event => _eventLogRange,
        _ => null,
      };

      await context.push(type.location, extra: period);
    } else {
      await context.push(type.location);
    }
  }
}
