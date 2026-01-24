import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_data_field.dart';
import 's_decoration.dart';
import 's_style_text.dart';
import 's_text.dart';
import 'svg_image.dart';

class SCalibration extends StatelessWidget {
  final Param? param;
  final String text;
  final num value;
  final String? unit;
  final num? newValue;

  const SCalibration({
    super.key,
    this.param,
    required this.text,
    required this.value,
    this.unit,
    this.newValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        SDecoration(
          header: text,
          child: SDataField.digit(param: param, value: value),
        ),
        if (newValue != null)
          Row(
            spacing: 4.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgImage(
                'arrow-right2',
                width: 20.0,
                height: 20.0,
                color: colorScheme.accentGold(context),
              ),
              SDataField.digit(param: param, value: newValue),
              if (unit != null)
                SStyleText(
                  unit!,
                  textColor: colorScheme.grey,
                  textStyle: STextStyle.bodyMedium.style,
                  tagTextStyle: STextStyle.titleMedium.style,
                ),
            ],
          ),
      ],
    );
  }
}
