import 'dart:async';

import 'package:ademlync_cloud/utils/enums.dart';
import 'package:ademlync_device/utils/adem_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'dp_calculator_bloc.dart';
import 'dp_calculator_const.dart';
import 'dp_calculator_enums.dart';

class DpCalculatorPage extends StatefulWidget {
  const DpCalculatorPage({super.key});

  @override
  State<DpCalculatorPage> createState() => _DpCalculatorPageState();
}

class _DpCalculatorPageState extends State<DpCalculatorPage> {
  late final _bloc = BlocProvider.of<DpCalculatorBloc>(context);
  final _formKey = GlobalKey<FormState>();

  DpCalculatorMeter _meter = .rmt600Flange;
  GasLineGaugePressureUnit _lineGaugePressUnit = .psig;
  String? _error;
  String? _addressError;

  final _badgeSnTEC = TextEditingController();
  final _rometSnTEC = TextEditingController();
  final _customerNameTEC = TextEditingController();
  final _installationSiteTEC = TextEditingController();
  final _atmosphericPressTEC = TextEditingController(
    text: dpCalculatorAtmosphericPressPsiaLimit.min.toStringAsFixed(
      dpCalculatorAtmosphericPressPsiaDecimal,
    ),
  );
  final _lineGaugePressTEC = TextEditingController(
    text: dpCalculatorLineGaugePressPsigLimit.min.toStringAsFixed(
      dpCalculatorLineGaugePressPsigDecimal,
    ),
  );
  final _diffPressTEC = TextEditingController(
    text: dpCalculatorLineGaugePressPsigLimit.min.toStringAsFixed(
      dpCalculatorDpInWcDecimal,
    ),
  );
  final _specificGravityTEC = TextEditingController(
    text: dpCalculatorSpecificGravityLimit.min.toStringAsFixed(
      dpCalculatorSpecificGravityDecimal,
    ),
  );
  final _uncFlowRateTEC = TextEditingController(
    text: 0.toStringAsFixed(dpCalculatorUncFlowRateDecimal),
  );
  final _indexReadingTEC = TextEditingController();
  final _testTEC = TextEditingController();
  final _commentsTEC = TextEditingController();
  final _meterTypeTEC = TextEditingController();
  final _snPart2TEC = TextEditingController();
  final _customerIdTEC = TextEditingController();

  @override
  void dispose() {
    _badgeSnTEC.dispose();
    _rometSnTEC.dispose();
    _customerNameTEC.dispose();
    _installationSiteTEC.dispose();
    _atmosphericPressTEC.dispose();
    _lineGaugePressTEC.dispose();
    _diffPressTEC.dispose();
    _specificGravityTEC.dispose();
    _uncFlowRateTEC.dispose();
    _indexReadingTEC.dispose();
    _testTEC.dispose();
    _commentsTEC.dispose();
    _meterTypeTEC.dispose();
    _snPart2TEC.dispose();
    _customerIdTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLocationFetching = state is DpCalculatorLocationFetchInProgress;

        final isCalculating = state is DpCalculatorCalculateInProgress;
        final isLoading = isLocationFetching || isCalculating;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: GestureDetector(
            onTap: dismissKeyboard,
            child: Scaffold(
              appBar: SAppBar.withMenu(
                context,
                text: 'D.P. Calculator',
                showBluetoothAction: true,
              ),
              body: SmartBodyLayout(
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 24.0,
                    children: [
                      SCard(
                        title: 'Meter Information',
                        child: Column(
                          spacing: 24.0,
                          children: [
                            SDecoration(
                              header: 'Meter',
                              child: SDataField.dropdown(
                                value: _meter,
                                list: DpCalculatorMeter.values,
                                stringBuilder: (o) => o.name,
                                isEdited: false,
                                softWrap: true,
                                isDisable: isLoading,
                                onChanged: (o) => setState(() => _meter = o!),
                              ),
                            ),

                            SDecoration(
                              header: 'Badge Serial Number',
                              child: SDataField.stringEdit(
                                controller: _badgeSnTEC,
                                maxLength: 16,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'ROMET Serial Number',
                              child: SDataField.stringEdit(
                                controller: _rometSnTEC,
                                maxLength: 16,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Customer Name',
                              child: SDataField.stringEdit(
                                controller: _customerNameTEC,
                                maxLength: 16,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Customer ID',
                              child: SDataField.stringEdit(
                                controller: _customerIdTEC,
                                maxLength: 16,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Meter Manuf. and Model',
                              child: SDataField.stringEdit(
                                controller: _meterTypeTEC,
                                maxLength: 32,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: '2nd Serial Number',
                              child: SDataField.stringEdit(
                                controller: _snPart2TEC,
                                maxLength: 8,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                keyboardType: .number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Installation Site',
                              child: Column(
                                children: [
                                  if (_addressError case final err?)
                                    SText.bodySmall(
                                      err,
                                      color: colorScheme.warning(context),
                                    ),
                                  SDataField.stringEdit(
                                    controller: _installationSiteTEC,
                                    maxLength: 100,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    isEnabled: !isLoading,
                                    onChanged: (_) =>
                                        setState(() => _addressError = null),
                                  ),

                                  const Gap(8.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: SButton.filled(
                                      text: 'Capture Location',
                                      isLoading: isLocationFetching,
                                      onPressed: !isLoading
                                          ? _captureLocation
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SCard(
                        title: 'Field Data',
                        child: Column(
                          spacing: 24.0,
                          children: [
                            SDecoration(
                              header: 'Atmospheric Pressure',
                              subHeader: dpCalculatorAtmosphericPressPsiaLimit
                                  .toDisplay(
                                    dpCalculatorAtmosphericPressPsiaDecimal,
                                  ),
                              child: SDataField.digitEdit(
                                controller: _atmosphericPressTEC,
                                unit: 'PSIA',
                                limit: dpCalculatorAtmosphericPressPsiaLimit,
                                decimal:
                                    dpCalculatorAtmosphericPressPsiaDecimal,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Gas Line Gauge Pressure',
                              subHeader: switch (_lineGaugePressUnit) {
                                GasLineGaugePressureUnit.psig =>
                                  dpCalculatorLineGaugePressPsigLimit.toDisplay(
                                    dpCalculatorLineGaugePressPsigDecimal,
                                  ),
                                GasLineGaugePressureUnit.inWc =>
                                  dpCalculatorLineGaugePressInWcLimit.toDisplay(
                                    dpCalculatorLineGaugePressInWcDecimal,
                                  ),
                              },
                              child: Column(
                                spacing: 8.0,
                                children: [
                                  SDataField.digitEdit(
                                    controller: _lineGaugePressTEC,
                                    unit: switch (_lineGaugePressUnit) {
                                      GasLineGaugePressureUnit.psig => 'PSIG',
                                      GasLineGaugePressureUnit.inWc => 'inWC',
                                    },
                                    limit: switch (_lineGaugePressUnit) {
                                      GasLineGaugePressureUnit.psig =>
                                        dpCalculatorLineGaugePressPsigLimit,
                                      GasLineGaugePressureUnit.inWc =>
                                        dpCalculatorLineGaugePressInWcLimit,
                                    },
                                    decimal: switch (_lineGaugePressUnit) {
                                      GasLineGaugePressureUnit.psig =>
                                        dpCalculatorLineGaugePressPsigDecimal,
                                      GasLineGaugePressureUnit.inWc =>
                                        dpCalculatorLineGaugePressInWcDecimal,
                                    },
                                    isEnabled: !isLoading,
                                    onChanged: (_) => setState(() {}),
                                  ),

                                  SDataField.dropdown(
                                    value: _lineGaugePressUnit,
                                    list: GasLineGaugePressureUnit.values,
                                    stringBuilder: (o) => o.name,
                                    isEdited: false,
                                    softWrap: true,
                                    isDisable: isLoading,
                                    onChanged: (o) => setState(
                                      () => _lineGaugePressUnit = o!,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SDecoration(
                              header: 'Differential Pressure',
                              subHeader: dpCalculatorLineGaugePressPsigLimit
                                  .toDisplay(dpCalculatorDpInWcDecimal),
                              child: Column(
                                spacing: 8.0,
                                children: [
                                  SDataField.digitEdit(
                                    controller: _diffPressTEC,
                                    unit: 'inWC',
                                    limit: dpCalculatorLineGaugePressPsigLimit,
                                    decimal: dpCalculatorDpInWcDecimal,
                                    isEnabled: !isLoading,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),

                            SDecoration(
                              header: 'Gas Specific Gravity',
                              subHeader: dpCalculatorSpecificGravityLimit
                                  .toDisplay(
                                    dpCalculatorSpecificGravityDecimal,
                                  ),
                              child: SDataField.digitEdit(
                                controller: _specificGravityTEC,
                                limit: dpCalculatorSpecificGravityLimit,
                                decimal: dpCalculatorSpecificGravityDecimal,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Uncorrected Flow Rate',
                              child: SDataField.digitEdit(
                                controller: _uncFlowRateTEC,
                                unit: FlowRateType.cf.displayName,
                                decimal: dpCalculatorUncFlowRateDecimal,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Index Reading at',
                              child: SDataField.stringEdit(
                                controller: _indexReadingTEC,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SCard(
                        child: Column(
                          spacing: 24.0,
                          children: [
                            SDecoration(
                              header: 'Tested by',
                              child: SDataField.stringEdit(
                                controller: _testTEC,
                                maxLength: 16,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            SDecoration(
                              header: 'Comments',
                              child: SDataField.stringEdit(
                                controller: _commentsTEC,
                                maxLines: 3,
                                textAlign: TextAlign.start,
                                isEnabled: !isLoading,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_error case final err?)
                        SText.bodySmall(
                          err,
                          color: colorScheme.warning(context),
                          softWrap: true,
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: SButton.filled(
                          text: 'Calculate',
                          isLoading: isCalculating,
                          onPressed: !isLoading ? _calculate : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case DpCalculatorLocationFetchSuccess(:final location):
        setState(() => _installationSiteTEC.text = location);

      case DpCalculatorLocationFetchFailure(:final error):
        setState(() => _addressError = error.toString());

      case DpCalculatorCalculateSuccess(
        :final uncFlowRate,
        :final percentMaxFlow,
        :final maxAllowableDp,
        :final isPassed,
        :final lastCalculationTime,
      ):
        await showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (_) => BlocProvider.value(
            value: _bloc,
            child: _ResultBottomSheet(
              badgeSn: _badgeSnTEC.text,
              rometSn: _rometSnTEC.text,
              customerName: _customerNameTEC.text,
              customerId: _customerIdTEC.text,
              meterType: _meterTypeTEC.text,
              snPart2: _snPart2TEC.text,
              installationSite: _indexReadingTEC.text,
              indexReadingAt: _indexReadingTEC.text,
              testBy: _testTEC.text,
              comments: _commentsTEC.text,
              uncFlowRate: uncFlowRate,
              percentMaxFlow: percentMaxFlow,
              maxAllowableDp: maxAllowableDp,
              isPassed: isPassed,
              lastCalculationTime: lastCalculationTime,
            ),
          ),
        );

      case DpCalculatorCalculateFailure(:final error):
        setState(() {
          _error = switch (error) {
            DpCalculatorError _ =>
              'The Differential calculation will not be performed at the flow rate below 10% of the maximum flow rate.',
            _ => null,
          };
        });
    }
  }

  void _captureLocation() {
    setState(() => _addressError = null);
    _bloc.add(DpCalculatorLocationFetched());
  }

  void _calculate() {
    dismissKeyboard();
    setState(() => _error = null);

    if (_formKey.currentState?.validate() != true) return;

    final atmosphericPress = double.tryParse(_atmosphericPressTEC.text);
    final lineGaugePress = double.tryParse(_lineGaugePressTEC.text);
    final diffPress = double.tryParse(_diffPressTEC.text);
    final specificGravity = double.tryParse(_specificGravityTEC.text);
    final uncFlowRate = double.tryParse(_uncFlowRateTEC.text);

    if (atmosphericPress == null ||
        lineGaugePress == null ||
        diffPress == null ||
        specificGravity == null ||
        uncFlowRate == null) {
      return;
    }

    _bloc.add(
      DpCalculatorCalculated(
        meter: _meter,
        atmosphericPress: atmosphericPress,
        lineGaugePress: lineGaugePress,
        lineGaugePressUnit: _lineGaugePressUnit,
        diffPress: diffPress,
        specificGravity: specificGravity,
        uncFlowRate: uncFlowRate,
      ),
    );
  }
}

class _ResultBottomSheet extends StatefulWidget {
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
  final double uncFlowRate;
  final double percentMaxFlow;
  final double maxAllowableDp;
  final bool isPassed;
  final DateTime lastCalculationTime;

  const _ResultBottomSheet({
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
    required this.uncFlowRate,
    required this.percentMaxFlow,
    required this.maxAllowableDp,
    required this.isPassed,
    required this.lastCalculationTime,
  });

  @override
  State<_ResultBottomSheet> createState() => __ResultBottomSheetState();
}

class __ResultBottomSheetState extends State<_ResultBottomSheet> {
  late final _bloc = BlocProvider.of<DpCalculatorBloc>(context);

  late final _badgeSn = widget.badgeSn;
  late final _rometSn = widget.rometSn;
  late final _customerName = widget.customerName;
  late final _customerId = widget.customerId;
  late final _meterType = widget.meterType;
  late final _snPart2 = widget.snPart2;
  late final _installationSite = widget.installationSite;
  late final _indexReadingAt = widget.indexReadingAt;
  late final _testBy = widget.testBy;
  late final _comments = widget.comments;
  late final _uncFlowRate = widget.uncFlowRate;
  late final _percentMaxFlow = widget.percentMaxFlow;
  late final _maxAllowableDp = widget.maxAllowableDp;
  late final _isPassed = widget.isPassed;
  late final _lastCalculationTime = widget.lastCalculationTime;

  String? _msg;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (context, state) {
        if (!context.mounted) return;

        switch (state) {
          case DpCalculatorReportExportSuccess():
            setState(() => _msg = 'Export Success');

          case DpCalculatorReportExportFailure():
            setState(() => _msg = 'Export Failure');
        }
      },
      builder: (context, state) {
        final isLoading = state is DpCalculatorReportExportInProgress;

        return SBottomSheetDecoration(
          header: '∆P Acceptance Result',
          child: Column(
            spacing: 24.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SText.titleLarge(
                    _isPassed ? resultPassedString : resultFailedString,
                    color: _isPassed
                        ? colorScheme.connected(context)
                        : colorScheme.warning(context),
                  ),

                  SText.bodySmall(
                    '${DateTimeFmtManager.formatDate(_lastCalculationTime)} | ${DateTimeFmtManager.formatTimestamp(_lastCalculationTime)}',
                  ),
                ],
              ),

              SDecoration(
                header: 'Uncorrected Flow Rate',
                child: SDataField.string(
                  unit: FlowRateType.cf.displayName,
                  value: _uncFlowRate.toStringAsFixed(
                    dpCalculatorUncFlowRateDecimal,
                  ),
                ),
              ),

              SDecoration(
                header: 'Percentage of Max Flow Rate',
                child: SDataField.string(
                  unit: '%',
                  value: _percentMaxFlow.toStringAsFixed(
                    dpCalculatorPercentMaxFlowDecimal,
                  ),
                ),
              ),

              SDecoration(
                header: 'Max Allowable (∆P)',
                child: SDataField.string(
                  unit: 'inWC',
                  value: _maxAllowableDp.toStringAsFixed(
                    dpCalculatorMaxAllowableDpDecimal,
                  ),
                ),
              ),

              Column(
                spacing: 8.0,
                children: [
                  if (_percentMaxFlow < 15.0)
                    SText.bodySmall(
                      'The flow rate is below 15% of the maximum flow rate, the Differential measurement may not be repeatable.\n\nTherefore, it is recommended to repeat the Differential test 3 times using the average recording for calculation.',
                      softWrap: true,
                      color: colorScheme.warning(context),
                    )
                  else if (_percentMaxFlow > 100)
                    SText.bodySmall(
                      'The flow rate is above 100% of the maximum flow rate.\n\nNote: ROMET does not recommend Differential test above 100% of the maximum flow rate and results may not be accurate.',
                      softWrap: true,
                      color: colorScheme.warning(context),
                    ),

                  if (_msg case final msg?) SText.titleSmall(msg),

                  SButton.filled(
                    // text: 'Export Report (${AppDelegate().exportFmt.fmt})',
                    text: 'Export Report (${ExportFormat.pdf.fmt})',
                    isLoading: isLoading,
                    onPressed: !isLoading
                        ? () => _bloc.add(
                            DpCalculatorReportExported(
                              badgeSn: _badgeSn,
                              rometSn: _rometSn,
                              customerName: _customerName,
                              customerId: _customerId,
                              meterType: _meterType,
                              snPart2: _snPart2,
                              installationSite: _installationSite,
                              indexReadingAt: _indexReadingAt,
                              testBy: _testBy,
                              comments: _comments,
                            ),
                          )
                        : null,
                  ),

                  SButton.outlined(
                    text: 'Close',
                    onPressed: !isLoading ? () => Navigator.pop(context) : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
