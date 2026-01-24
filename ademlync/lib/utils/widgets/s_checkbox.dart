import 'package:flutter/material.dart';

import 's_text.dart';

class SCheckbox extends StatelessWidget {
  final bool isActive;
  final String? text;
  final bool isDisabled;
  final void Function(bool) onPressed;

  const SCheckbox({
    super.key,
    required this.isActive,
    this.text,
    this.isDisabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (text != null)
          InkWell(
            onTap: !isDisabled ? () => onPressed(!isActive) : null,
            child: Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: SText.bodyMedium(text!),
            ),
          ),
        Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Transform.scale(
            scale: 0.9,
            child: SizedBox.square(
              dimension: 20.0,
              child: Checkbox(
                value: isActive,
                onChanged: !isDisabled ? (_) => onPressed(!isActive) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
