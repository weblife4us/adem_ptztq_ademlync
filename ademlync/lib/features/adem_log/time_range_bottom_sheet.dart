import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/enums.dart';
import '../../utils/widgets/date_time_picker_button.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_text.dart';

class TimeRangeBottomSheet extends StatefulWidget {
  final LogItem type;
  final LogTimeRange range;
  final void Function(LogTimeRange) onChanged;

  const TimeRangeBottomSheet({
    super.key,
    required this.type,
    required this.range,
    required this.onChanged,
  });

  @override
  State<TimeRangeBottomSheet> createState() => _TimeRangeBottomSheetState();
}

class _TimeRangeBottomSheetState extends State<TimeRangeBottomSheet> {
  late final _type = widget.type;
  late final _onChanged = widget.onChanged;

  late LogTimeRange _range = widget.range;

  @override
  Widget build(BuildContext context) {
    return SBottomSheetDecoration(
      header: _type.text,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SDecoration(
            header: 'From',
            child: DateTimePickerButton.all(
              context,
              value: _range.from,
              minimumDate: defaultLogStartDate,
              onChanged: (o) => _onDateChanged(o),
              onTimeChanged: (o) => _onTimeChanged(o),
            ),
          ),
          const Gap(24.0),
          SDecoration(
            header: 'To',
            child: DateTimePickerButton.all(
              context,
              value: _range.to,
              minimumDate: defaultLogStartDate,
              onChanged: (o) => _onDateChanged(o, isFrom: false),
              onTimeChanged: (o) => _onTimeChanged(o, isFrom: false),
            ),
          ),
          if (!_range.isValid) ...[
            const Gap(12.0),
            SText.bodySmall(
              'Please adjust the dates accordingly.',
              color: colorScheme.warning(context),
            ),
            const Gap(12.0),
          ] else
            const Gap(24.0),
          SButton.filled(
            text: 'By Date...',
            onPressed: _range.isValid
                ? () => Navigator.pop(context, true)
                : null,
          ),
          const Gap(8.0),
          SButton.outlined(
            text: 'Full...',
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }

  void _onDateChanged(DateTime o, {bool isFrom = true}) {
    final pDate = _range.from;
    final nDate = DateTime(o.year, o.month, o.day, pDate.hour, pDate.minute);

    _range = isFrom ? _range.copyWith(from: nDate) : _range.copyWith(to: nDate);

    setState(() => _onChanged(_range));
  }

  void _onTimeChanged(DateTime o, {bool isFrom = true}) {
    final pDate = _range.from;
    final nDate = DateTime(
      pDate.year,
      pDate.month,
      pDate.day,
      o.hour,
      o.minute,
    );

    _range = isFrom ? _range.copyWith(from: nDate) : _range.copyWith(to: nDate);

    setState(() => _onChanged(_range));
  }
}
