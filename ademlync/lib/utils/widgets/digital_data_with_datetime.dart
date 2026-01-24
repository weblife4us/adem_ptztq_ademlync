import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_data_field.dart';
import 's_text.dart';

class DigitDataWithDateTime extends StatelessWidget {
  final num? value;
  final Param param;
  final String? prefix;
  final String? dateTime;

  const DigitDataWithDateTime({
    super.key,
    this.value,
    required this.param,
    this.prefix,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SDataField.digit(prefix: prefix, value: value, param: param),
        if (dateTime != null)
          SText.bodySmall(dateTime!, color: colorScheme.grey, softWrap: true),
      ],
    );
  }
}
