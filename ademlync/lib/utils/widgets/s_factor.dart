import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SFactor extends StatelessWidget {
  final String text;
  final String value;
  final bool isLive;

  const SFactor({
    super.key,
    required this.text,
    required this.value,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 4.0,
          alignment: WrapAlignment.center,
          children: [SText.bodyMedium(text), const SText.bodyMedium('Factor')],
        ),
        const Gap(8.0),
        SText.titleMedium(
          isLive ? 'Live' : 'Fixed',
          color: isLive
              ? colorScheme.connected(context)
              : colorScheme.accentGold(context),
        ),
        SText.titleMedium(value),
      ],
    );
  }
}
