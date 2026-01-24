import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../ui_specification.dart';
import 's_button.dart';
import 's_text.dart';

class SBottomSheetDecoration extends StatelessWidget {
  final String? header;
  final String? text;
  final String? buttonText;
  final void Function()? onPressed;
  final Widget? child;

  const SBottomSheetDecoration({
    super.key,
    this.header,
    this.text,
    this.buttonText,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final width = constraints.maxWidth;
          final extraSide = (width - UISpecification.maxWidthForTablet).clamp(
            0.0,
            double.maxFinite,
          );
          final side = (extraSide / 2) + 24.0;

          return Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: colorScheme.cardBackground(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              side,
              36.0,
              side,
              48.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              spacing: 24.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null)
                  SText.titleLarge(
                    header!,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                if (text != null)
                  SText.bodyMedium(
                    text!,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                if (child != null) child!,
                if (buttonText != null)
                  SButton.filled(text: buttonText!, onPressed: onPressed),
              ],
            ),
          );
        },
      ),
    );
  }
}
