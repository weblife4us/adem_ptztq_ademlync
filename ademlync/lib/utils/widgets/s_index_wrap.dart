import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 's_text.dart';

class SIndexWrap extends StatelessWidget {
  final List<String> value;

  const SIndexWrap({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final index = i * 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24.0,
          children: [
            Expanded(
              child: _Item(index: index + 1, text: value[index]),
            ),
            if (index + 1 < value.length)
              Expanded(
                child: _Item(index: index + 2, text: value[index + 1]),
              ),
          ],
        );
      },
      separatorBuilder: (_, _) => const Gap(8.0),
      itemCount: (value.length / 2).round(),
    );
  }
}

class _Item extends StatelessWidget {
  final int index;
  final String text;

  const _Item({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 22.0),
          child: SText.bodySmall(index.toString()),
        ),
        Expanded(child: SText.titleMedium(text, softWrap: true)),
      ],
    );
  }
}
