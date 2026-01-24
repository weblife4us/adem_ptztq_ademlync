import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 's_loading_animation.dart';
import 's_text.dart';

class LoadingDialog extends StatelessWidget {
  final String text;

  const LoadingDialog(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SLoadingAnimationStaggered(size: 20.0),
          const Gap(12.0),
          SText.titleMedium(text),
        ],
      ),
      contentPadding: const EdgeInsets.all(24.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
