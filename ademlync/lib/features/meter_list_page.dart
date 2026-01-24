import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';

import '../utils/app_delegate.dart';
import '../utils/widgets/s_app_bar.dart';
import '../utils/widgets/s_card.dart';
import '../utils/widgets/s_data_field.dart';
import '../utils/widgets/s_text.dart';
import '../utils/widgets/smart_body_layout.dart';

class MeterListPage extends StatelessWidget {
  const MeterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar(text: locale.meterListString, hasAdemInfoAction: true),
      body: SmartBodyLayout(
        children: [
          Column(
            spacing: 18.0,
            children: MeterSerial.values.map((e) {
              final sizes = e.sizes;

              return _Card(
                text: e.displayName,
                unit: '',
                count: sizes.length,
                titles: sizes.map((e) => e.name).toList(),
                capacities: sizes.map((e) => e.maxFlowRate).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.text,
    required this.unit,
    required this.count,
    required this.titles,
    required this.capacities,
  });
  final String text;
  final String unit;
  final int count;
  final List<String> titles;
  final List<int> capacities;

  @override
  Widget build(BuildContext context) {
    return SCard.columnForDisplay(
      title: text,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(flex: 4, child: SText.titleMedium(locale.sizeString)),
              Expanded(
                flex: 3,
                child: SText.titleMedium('${locale.capacityString}  [$unit]'),
              ),
            ],
          ),
        ),
        for (var i = 0; i < count; i++) ...[
          SDataField.string(
            title: titles[i],
            value: capacities[i].toString(),
            // titleAlign: TextAlign.center,
            // textAlign: TextAlign.start,
          ),
          if (i < count - 1) const Divider(),
        ],
      ],
    );
  }
}
