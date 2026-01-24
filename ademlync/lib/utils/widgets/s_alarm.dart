import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../app_delegate.dart';
import '../controllers/date_time_fmt_manager.dart';
import '../custom_color_scheme.dart';
import 'digital_data_with_datetime.dart';
import 's_decoration.dart';
import 's_text.dart';

class SAlarm extends StatelessWidget {
  final String text;
  final double? high;
  final Param? highParam;
  final double? low;
  final Param? lowParam;
  final DateTime? malfDateTime;
  final bool? isMalfunctioned;
  final bool? isHigh;
  final bool? isLow;

  const SAlarm({
    super.key,
    required this.text,
    this.high,
    this.highParam,
    this.low,
    this.lowParam,
    this.malfDateTime,
    this.isMalfunctioned,
    this.isHigh,
    this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
                children: [
                  isMalfunctioned != null
                      ? Container(
                          width: 6.0,
                          height: 6.0,
                          margin: const EdgeInsets.only(left: 14.0, right: 4.0),
                          decoration: BoxDecoration(
                            color: isMalfunctioned!
                                ? colorScheme.warning(context)
                                : colorScheme.connected(context),
                            shape: BoxShape.circle,
                          ),
                        )
                      : const Gap(24.0),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SText.bodyMedium(
                            (isHigh == true || isLow == true)
                                ? '$text — '
                                : text,
                          ),
                        ),
                        if (isHigh ?? false)
                          SText.titleMedium(
                            'Low',
                            color: colorScheme.accentGold(context),
                          ),
                        if (isLow ?? false)
                          SText.titleMedium(
                            'High',
                            color: colorScheme.accentGold(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (malfDateTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: SText.bodySmall(
                  DateTimeFmtManager.formatDateTime(malfDateTime!),
                  color: colorScheme.warning(context),
                ),
              ),
          ],
        ),
        if (high != null || low != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 24.0),
            child: Row(
              spacing: 24.0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (highParam != null && high != null)
                  Expanded(
                    child: SDecoration(
                      header: 'High Limit',
                      child: DigitDataWithDateTime(
                        param: highParam!,
                        value: high!,
                      ),
                    ),
                  ),
                if (lowParam != null && low != null)
                  Expanded(
                    child: SDecoration(
                      header: 'Low Limit',
                      child: DigitDataWithDateTime(
                        param: lowParam!,
                        value: low!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
