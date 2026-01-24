import 'package:flutter/material.dart';

import 's_checkbox.dart';

class SReset extends StatelessWidget {
  final bool? isActive;
  final bool isDisable;
  final void Function(bool)? onPressed;
  final Widget child;

  const SReset({
    super.key,
    this.isActive,
    this.isDisable = false,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (isActive != null && onPressed != null)
          Align(
            alignment: Alignment.centerRight,
            child: SCheckbox(
              isActive: isActive!,
              text: 'Reset',
              onPressed: onPressed!,
            ),
          ),
      ],
    );
  }
}
