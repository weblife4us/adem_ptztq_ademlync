import 'package:flutter/material.dart';

import 's_loading_animation.dart';
import 's_text.dart';

class SLoading extends StatelessWidget {
  final String? text;

  const SLoading({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SLoadingAnimationStaggered(size: 20.0),
        if (text != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: SText.titleMedium(text!),
          ),
      ],
    );
  }
}
