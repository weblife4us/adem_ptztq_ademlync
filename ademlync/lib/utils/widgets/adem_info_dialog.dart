import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../app_delegate.dart';
import '../ui_specification.dart';
import 'adem_model_info.dart';
import 's_text.dart';
import 's_decoration.dart';

Future<void> showAdemInfoDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => _Content(adem: AppDelegate().adem),
  );
}

class _Content extends StatelessWidget {
  final Adem adem;

  const _Content({required this.adem});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(
          maxWidth: UISpecification.maxWidthForTablet * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdemModelInfo(adem: adem),
            const Gap(24.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SDecoration(
                    header: 'S/N',
                    child: SText.titleMedium(adem.serialNumber, softWrap: true),
                  ),
                ),
                if (adem.serialNumberPart2 != null &&
                    adem.isSerialNumberPart2Supported) ...[
                  const Gap(24.0),
                  Expanded(
                    child: SDecoration(
                      header: '2<u>nd</u> S/N',
                      child: SText.titleMedium(
                        adem.serialNumberPart2!,
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Gap(24.0),
            SDecoration(
              header: 'Customer ID',
              child: SText.titleMedium(adem.customerId.trim(), softWrap: true),
            ),
            const Gap(24.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SDecoration(
                    header: 'Site Name',
                    child: SText.titleMedium(adem.siteName, softWrap: true),
                  ),
                ),
                const Gap(24.0),
                Expanded(
                  child: SDecoration(
                    header: 'Address',
                    child: SText.titleMedium(adem.siteAddress, softWrap: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
