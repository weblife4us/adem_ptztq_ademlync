import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/svg_image.dart';
import '../../utils/widgets/s_decoration.dart';

class Calibration1PointDecoration extends StatelessWidget {
  final CalibrationItem type;
  final TextEditingController controller;
  final Param param;
  final int count;
  final double reading;
  final double offset;
  final int adCounts;
  final bool isStabled;
  final bool isDisabled;
  final bool hasLimitCalculation;
  final AdemParamLimit? limit;
  final void Function(num?)? onChanged;
  final void Function()? onEditingComplete;

  const Calibration1PointDecoration({
    super.key,
    required this.type,
    required this.controller,
    required this.param,
    required this.count,
    required this.reading,
    required this.offset,
    required this.adCounts,
    required this.isStabled,
    required this.isDisabled,
    this.hasLimitCalculation = true,
    required this.limit,
    required this.onChanged,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final adem = AppDelegate().adem;
    final decimal = param.decimal(adem);
    AdemParamLimit? cLimit = limit;

    if (hasLimitCalculation && cLimit != null) {
      cLimit = _getLimit(reading, offset, cLimit, decimal, type);
    }

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
              const SDecoration(
                header: 'Sampling Method',
                child: SText.titleMedium('Instant'),
              ),
              const Gap(12.0),
              Row(
                children: [
                  Expanded(
                    child: SDecoration(
                      header: 'Reading',
                      child: SDataField.digit(value: reading, param: param),
                    ),
                  ),
                  const Gap(24.0),
                  Expanded(
                    child: SDecoration(
                      header: 'Offset',
                      child: SDataField.digit(value: offset, param: param),
                    ),
                  ),
                ],
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
                subHeader: cLimit?.toDisplay(decimal),
                child: SDataField.digitEdit(
                  param: param,
                  controller: controller,
                  isAutoValidate: false,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged,
                  isEnabled: !isDisabled,
                  unit: param.unit(adem),
                  limit: cLimit,
                  onEditingComplete: onEditingComplete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CalibrationHeader extends StatelessWidget {
  final String text;
  final int count;

  const CalibrationHeader({super.key, required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SText.titleLarge(text, softWrap: true),
          const Gap(4.0),
          SText.bodySmall('Fetched $count times', color: colorScheme.grey),
        ],
      ),
    );
  }
}

class ADCounts extends StatelessWidget {
  final int value;
  final bool isStabled;

  const ADCounts({super.key, required this.value, required this.isStabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SDecoration(
            header: 'A/D Counts',
            child: SDataField.digit(value: value),
          ),
        ),
        if (!isStabled) ...[
          SvgImage(
            'warning',
            width: 20.0,
            height: 20.0,
            color: colorScheme.accentGold(context),
          ),
          const Gap(4.0),
          SText.bodySmall('Unstable', color: colorScheme.accentGold(context)),
        ],
      ],
    );
  }
}

AdemParamLimit _getLimit(
  double reading,
  double offset,
  AdemParamLimit limits,
  int decimal,
  CalibrationItem type,
) {
  double min = calib1PtLimitCalculate(limits.min, reading, offset);
  double max = calib1PtLimitCalculate(limits.max, reading, offset);

  min = double.parse(min.toStringAsFixed(decimal));
  max = double.parse(max.toStringAsFixed(decimal));

  return AdemParamLimit(
    type == CalibrationItem.temp1Point
        ? min.clamp(min, max)
        : min.clamp(0, max),
    max,
  );
}
