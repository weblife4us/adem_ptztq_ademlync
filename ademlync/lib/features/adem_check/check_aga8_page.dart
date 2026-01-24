import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_aga8.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../file_export/export_bloc.dart';
import '../file_export/export_icon.dart';
import '../file_export/report.dart';
import 'check_aga8_page_bloc.dart';

class CheckAga8Page extends StatefulWidget {
  const CheckAga8Page({super.key});

  @override
  State<CheckAga8Page> createState() => _CheckAga8PageState();
}

class _CheckAga8PageState extends State<CheckAga8Page> {
  late final _bloc = BlocProvider.of<CheckAga8PageBloc>(context);

  Aga8Config? _aga8;
  final _data = <List<String>>[];

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: SAppBar(
              text: locale.aga8DetailString,
              hasAdemInfoAction: _aga8 != null,
              actions: _aga8 != null
                  ? [ExportIcon(onPressed: _onExport)]
                  : null,
            ),
            body: SmartBodyLayout(
              child: _aga8 == null
                  ? const SLoading()
                  : SCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, i) {
                              final o = Aga8Param.values[i];

                              return SAga8(
                                text: o.displayName,
                                formula: o.formula,
                                value: _value(o).toStringAsFixed(2),
                              );
                            },
                            separatorBuilder: (_, _) => const Gap(12.0),
                            itemCount: Aga8Param.values.length,
                          ),
                          const Divider(height: 24.0),
                          SAga8(
                            text: 'Total',
                            value: _aga8!.total.toStringAsFixed(2),
                            formula: '',
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is FetchedState) {
      setState(() {
        _aga8 = state.aga8;
      });
      _mapData();
    } else if (state is FailureState) {
      await handleError(context, state.error);
      if (context.mounted && context.canPop()) context.pop();
    }
  }

  double _value(Aga8Param o) {
    return switch (o) {
      Aga8Param.methane => _aga8!.methane,
      Aga8Param.ethane => _aga8!.ethane,
      Aga8Param.hydrogenSulphide => _aga8!.hydrogenSulphide,
      Aga8Param.oxygen => _aga8!.oxygen,
      Aga8Param.isoPentane => _aga8!.isoPentane,
      Aga8Param.nHeptane => _aga8!.nHeptane,
      Aga8Param.nDecane => _aga8!.nDecane,
      Aga8Param.nitrogen => _aga8!.nitrogen,
      Aga8Param.propane => _aga8!.propane,
      Aga8Param.hydrogen => _aga8!.hydrogen,
      Aga8Param.isoButane => _aga8!.isoButane,
      Aga8Param.nPentane => _aga8!.nPentane,
      Aga8Param.nOctane => _aga8!.nOctane,
      Aga8Param.helium => _aga8!.helium,
      Aga8Param.carbonDioxide => _aga8!.carbonDioxide,
      Aga8Param.water => _aga8!.water,
      Aga8Param.carbonMonoxide => _aga8!.carbonMonoxide,
      Aga8Param.nButane => _aga8!.nButane,
      Aga8Param.nHexane => _aga8!.nHexane,
      Aga8Param.nNonane => _aga8!.nNonane,
      Aga8Param.argon => _aga8!.argon,
    };
  }

  void _onExport(void Function(ExportEvent) addEvent) {
    final dateTime = DateTime.now();

    addEvent(
      ReportExportEvent(
        exportFormat: AppDelegate().exportFmt,
        folderName: aga8DetailFoldername,
        symbol: 'AGA8',
        report: Report(
          title: 'AGA8 Detail',
          headers: _headers,
          records: _data,
          dateTime: dateTime,
        ),
        dateTime: dateTime,
      ),
    );
  }

  void _mapData() {
    _data.addAll([
      for (final o in Aga8Param.values)
        [
          o.displayName,
          o.formula,
          '${o.limits.min} ~ ${o.limits.max}',
          (_value(o).toStringAsFixed(2)),
        ],
    ]);
  }
}

const _headers = ['Param', 'Periodic Table', 'Range [%]', 'Value [%]'];
