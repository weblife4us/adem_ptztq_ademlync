import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_button.dart';

class EventLogBottomSheet extends StatelessWidget with AccessCodeHelper {
  const EventLogBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SBottomSheetDecoration(
      header: 'Event Log',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SButton.filled(
            text: 'Full...',
            onPressed: () => Navigator.pop(context, false),
          ),
          const Gap(8.0),
          SButton.outlined(
            text: 'Update...',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
