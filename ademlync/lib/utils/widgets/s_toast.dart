import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SToast extends StatelessWidget {
  final String text;

  const SToast(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: colorScheme.accentGold(context),
      ),
      child: SText.bodyMedium(text, color: colorScheme.black),
    );
  }
}
