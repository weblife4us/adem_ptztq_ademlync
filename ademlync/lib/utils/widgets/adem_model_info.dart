import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';

import 's_text.dart';

class AdemModelInfo extends StatelessWidget {
  final Adem adem;

  const AdemModelInfo({super.key, required this.adem});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SText.titleLarge(adem.displayName),
        Row(
          children: [
            SText.bodyMedium(adem.firmwareVersion),
            if (adem.isPOnly) const SText.bodyMedium(', P-only'),
            if (adem.isTOnly) const SText.bodyMedium(', T-only'),
          ],
        ),
      ],
    );
  }
}
