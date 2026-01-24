import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/date_time_fmt_manager.dart';
import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_style_text.dart';
import 's_text.dart';

class DateTimePickerButton extends StatelessWidget {
  final Param? param;
  final String? title;
  final String text;
  final bool isEdited;
  final bool enable;
  final bool isError;
  final VoidCallback onPressed;
  final void Function(DateTime) onChanged;

  DateTimePickerButton.time(
    BuildContext context, {
    super.key,
    this.param,
    this.title,
    this.isEdited = false,
    this.enable = true,
    bool showMinute = true,
    this.isError = false,
    required DateTime value,
    required this.onChanged,
  }) : text = showMinute
           ? DateTimeFmtManager.formatTime(value)
           : DateTimeFmtManager.formatHour(value),
       onPressed = (() async {
         await showModalBottomSheet(
           context: context,
           builder: (context) {
             return Container(
               decoration: BoxDecoration(
                 borderRadius: const BorderRadius.vertical(
                   top: Radius.circular(12.0),
                 ),
                 color: colorScheme.cardBackground(context),
               ),
               height: 160.0,
               padding: const EdgeInsets.only(top: 24.0),
               child: SafeArea(
                 top: false,
                 child: CupertinoDatePicker(
                   initialDateTime: showMinute
                       ? value
                       : DateTime(
                           value.year,
                           value.month,
                           value.day,
                           value.hour,
                           0,
                         ),
                   mode: CupertinoDatePickerMode.time,
                   minuteInterval: showMinute ? 1 : 60,
                   onDateTimeChanged: (date) => onChanged(
                     DateTime(
                       value.year,
                       value.month,
                       value.day,
                       date.hour,
                       showMinute ? date.minute : 0,
                     ),
                   ),
                   use24hFormat: AppDelegate().is24HTimeFmt,
                 ),
               ),
             );
           },
         );
       });

  DateTimePickerButton.date(
    BuildContext context, {
    super.key,
    this.param,
    this.title,
    this.isEdited = false,
    this.enable = true,
    this.isError = false,
    required DateTime value,
    required this.onChanged,
  }) : text = DateTimeFmtManager.formatDate(value),
       onPressed = (() async {
         await showModalBottomSheet(
           context: context,
           builder: (_) {
             return Container(
               decoration: BoxDecoration(
                 borderRadius: const BorderRadius.vertical(
                   top: Radius.circular(12.0),
                 ),
                 color: colorScheme.cardBackground(context),
               ),
               height: 160.0,
               padding: const EdgeInsets.only(top: 24.0),
               child: SafeArea(
                 top: false,
                 child: CupertinoDatePicker(
                   initialDateTime: value,
                   mode: CupertinoDatePickerMode.date,
                   onDateTimeChanged: (date) => onChanged(
                     DateTime(
                       date.year,
                       date.month,
                       date.day,
                       value.hour,
                       value.minute,
                     ),
                   ),
                 ),
               ),
             );
           },
         );
       });

  DateTimePickerButton.dateTime(
    BuildContext context, {
    super.key,
    this.param,
    this.title,
    this.isEdited = false,
    this.enable = true,
    this.isError = false,
    DateTime? minimumDate,
    DateTime? maximumDate,
    required DateTime value,
    required this.onChanged,
  }) : text = DateTimeFmtManager.formatDateTime(value),
       onPressed = (() async {
         await showModalBottomSheet(
           context: context,
           builder: (_) {
             return Container(
               decoration: BoxDecoration(
                 borderRadius: const BorderRadius.vertical(
                   top: Radius.circular(12.0),
                 ),
                 color: colorScheme.cardBackground(context),
               ),
               height: 160.0,
               padding: const EdgeInsets.only(top: 24.0),
               child: SafeArea(
                 top: false,
                 child: CupertinoDatePicker(
                   initialDateTime: value,
                   minimumDate: minimumDate,
                   maximumDate: maximumDate,
                   use24hFormat: AppDelegate().is24HTimeFmt,
                   mode: CupertinoDatePickerMode.dateAndTime,
                   onDateTimeChanged: (date) => onChanged(date),
                 ),
               ),
             );
           },
         );
       });

  DateTimePickerButton.all(
    BuildContext context, {
    super.key,
    this.param,
    this.title,
    this.isEdited = false,
    this.enable = true,
    DateTime? minimumDate,
    DateTime? maximumDate,
    this.isError = false,
    required DateTime value,
    required this.onChanged,
    required void Function(DateTime time) onTimeChanged,
  }) : text = DateTimeFmtManager.formatDateTime(value),
       onPressed = (() async {
         await showModalBottomSheet(
           context: context,
           builder: (_) {
             return Container(
               decoration: BoxDecoration(
                 borderRadius: const BorderRadius.vertical(
                   top: Radius.circular(12.0),
                 ),
                 color: colorScheme.cardBackground(context),
               ),
               padding: const EdgeInsets.symmetric(vertical: 24.0),
               child: Column(
                 spacing: 24.0,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   SizedBox(
                     height: 100.0,
                     child: CupertinoDatePicker(
                       mode: CupertinoDatePickerMode.date,
                       initialDateTime: value,
                       minimumDate: minimumDate,
                       maximumDate: maximumDate,
                       onDateTimeChanged: (o) => onChanged(o),
                     ),
                   ),
                   SizedBox(
                     height: 100.0,
                     child: CupertinoDatePicker(
                       mode: CupertinoDatePickerMode.time,
                       initialDateTime: value,
                       minimumDate: minimumDate,
                       maximumDate: maximumDate,
                       use24hFormat: AppDelegate().is24HTimeFmt,
                       onDateTimeChanged: (o) => onTimeChanged(o),
                     ),
                   ),
                 ],
               ),
             );
           },
         );
       });

  @override
  Widget build(BuildContext context) {
    final textColor = (isEdited ? colorScheme.black : colorScheme.text(context))
        .withValues(alpha: enable ? 1.0 : 0.4);

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.maxFinite,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isError
                ? colorScheme.warning(context)
                : colorScheme
                      .border(context)
                      .withValues(alpha: enable ? 1.0 : 0.4),
            width: 1.0,
          ),
          color: isEdited
              ? colorScheme.accentGold(context)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: SStyleText(
          text,
          textColor: isError ? colorScheme.warning(context) : textColor,
          textStyle: STextStyle.titleMedium.style,
        ),
      ),
    );
  }
}
