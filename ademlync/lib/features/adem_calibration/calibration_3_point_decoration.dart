import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_calibration.dart';
import '../../utils/widgets/s_decoration.dart';
import 'calibration_1_point_decoration.dart';

class Calibration3PointDecoration extends StatelessWidget {
  final Param param;
  final AdemParamLimit? limit;
  final TextEditingController controller;
  final CalibrationItem type;
  final int count;
  final int adCounts;
  final bool isStabled;
  final bool isDisabled;
  final int adCountsLow;
  final double offsetLow;
  final int? newAdCountsLow;
  final double? newOffsetLow;
  final void Function(int, double) onPressedLow;
  final int adCountsMid;
  final double offsetMid;
  final int? newAdCountsMid;
  final double? newOffsetMid;
  final void Function(int, double) onPressedMid;
  final int adCountsHigh;
  final double offsetHigh;
  final int? newAdCountsHigh;
  final double? newOffsetHigh;
  final void Function(int, double) onPressedHigh;
  final void Function(num?)? onChanged;

  const Calibration3PointDecoration({
    super.key,
    required this.controller,
    required this.count,
    required this.param,
    required this.limit,
    required this.adCountsLow,
    required this.offsetLow,
    required this.newAdCountsLow,
    required this.newOffsetLow,
    required this.onPressedLow,
    required this.adCountsMid,
    required this.offsetMid,
    required this.newAdCountsMid,
    required this.newOffsetMid,
    required this.onPressedMid,
    required this.adCountsHigh,
    required this.offsetHigh,
    required this.newAdCountsHigh,
    required this.newOffsetHigh,
    required this.onPressedHigh,
    required this.adCounts,
    required this.isStabled,
    required this.type,
    required this.onChanged,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final adem = AppDelegate().adem;
    final decimal = param.decimal(adem);
    final inputTitle = switch (type) {
      CalibrationItem.dp1Point || CalibrationItem.dp3Point => 'True D.P.',
      CalibrationItem.press1Point ||
      CalibrationItem.press3Point => 'True Pressure',
      CalibrationItem.temp1Point ||
      CalibrationItem.temp3Point => 'True Temperature',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalibrationHeader(text: type.text, count: count),
              const Gap(24.0),
              _Point.low(
                param: param,
                adCounts: adCountsLow,
                offset: offsetLow,
                newADCounts: newAdCountsLow,
                newOffset: newOffsetLow,
              ),
              const Gap(24.0),
              _Point.mid(
                param: param,
                adCounts: adCountsMid,
                offset: offsetMid,
                newADCounts: newAdCountsMid,
                newOffset: newOffsetMid,
              ),
              const Gap(24.0),
              _Point.high(
                param: param,
                adCounts: adCountsHigh,
                offset: offsetHigh,
                newADCounts: newAdCountsHigh,
                newOffset: newOffsetHigh,
              ),
            ],
          ),
        ),
        const Gap(24.0),
        SCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ADCounts(value: adCounts, isStabled: isStabled),
              const Gap(24.0),
              SDecoration(
                header: inputTitle,
                subHeader: limit?.toDisplay(decimal),
                child: SDataField.digitEdit(
                  param: param,
                  controller: controller,
                  isAutoValidate: false,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged,
                  isEnabled: !isDisabled,
                  unit: param.unit(adem),
                  limit: limit,
                ),
              ),
              const Gap(12.0),
              Row(
                children: [
                  Expanded(
                    child: SButton.filled(
                      text: 'Low',
                      onPressed: isDisabled
                          ? null
                          : () => onPressedLow(adCounts, _getValue()),
                      minimumSize: const Size(0.0, 40.0),
                    ),
                  ),
                  const Gap(12.0),
                  Expanded(
                    child: SButton.filled(
                      text: 'Mid',
                      onPressed: isDisabled
                          ? null
                          : () => onPressedMid(adCounts, _getValue()),
                      minimumSize: const Size(0.0, 40.0),
                    ),
                  ),
                  const Gap(12.0),
                  Expanded(
                    child: SButton.filled(
                      text: 'High',
                      onPressed: isDisabled
                          ? null
                          : () => onPressedHigh(adCounts, _getValue()),
                      minimumSize: const Size(0.0, 40.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getValue() {
    return controller.text.isEmpty ||
            controller.text == '-.00' ||
            controller.text == '.00'
        ? 0.0
        : double.parse(controller.text);
  }
}

class _Point extends StatelessWidget {
  final String title;
  final Param param;
  final int adCounts;
  final double offset;
  final int? newADCounts;
  final double? newOffset;

  const _Point.low({
    required this.param,
    required this.adCounts,
    required this.offset,
    required this.newADCounts,
    required this.newOffset,
  }) : title = 'Low Point';

  const _Point.mid({
    required this.param,
    required this.adCounts,
    required this.offset,
    required this.newADCounts,
    required this.newOffset,
  }) : title = 'Mid Point';

  const _Point.high({
    required this.param,
    required this.adCounts,
    required this.offset,
    required this.newADCounts,
    required this.newOffset,
  }) : title = 'High Point';

  @override
  Widget build(BuildContext context) {
    return SDecoration(
      header: title,
      type: STextStyle.titleMedium,
      child: Row(
        children: [
          Expanded(
            child: SCalibration(
              text: 'A/D Counts',
              value: adCounts,
              newValue: newADCounts,
            ),
          ),
          const Gap(24.0),
          Expanded(
            child: SCalibration(
              param: param,
              text: 'Offset',
              value: offset,
              newValue: newOffset,
            ),
          ),
        ],
      ),
    );
  }
}
