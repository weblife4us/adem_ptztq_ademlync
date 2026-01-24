import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_style_text.dart';
import 's_text.dart';

class SAga8 extends StatelessWidget {
  final String text;
  final String? formula;
  final String value;

  const SAga8({
    super.key,
    required this.text,
    this.formula,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: SText.bodyMedium(text, softWrap: true)),
        if (formula != null)
          Expanded(
            child: SStyleText(
              formula!,
              textStyle: STextStyle.bodySmall.style,
              tagTextStyle: STextStyle.titleSmall.style,
              textColor: colorScheme.grey,
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SText.titleMedium(value),
              const Gap(4.0),
              SText.bodySmall('%', color: colorScheme.grey),
            ],
          ),
        ),
      ],
    );
  }
}
