import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../ui_specification.dart';
import 's_button.dart';
import 's_text.dart';

class SDialogLayout extends StatelessWidget {
  final String? title;
  final String? detail;
  final bool isShowCloseButton;
  final EdgeInsets? insetPadding;
  final EdgeInsets? contentPadding;
  final String? closeText;
  final Widget? child;

  const SDialogLayout({
    super.key,
    this.title,
    this.detail,
    this.isShowCloseButton = true,
    this.insetPadding,
    this.contentPadding,
    this.closeText,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      contentPadding: contentPadding ?? const EdgeInsets.all(24.0),
      insetPadding: insetPadding ?? const EdgeInsets.all(24.0),
      backgroundColor: colorScheme.cardBackground(context),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(
          maxWidth: UISpecification.maxWidthForTablet * 0.9,
        ),
        child: Column(
          spacing: 24.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              SText.titleMedium(
                title!,
                softWrap: true,
                textAlign: TextAlign.center,
              ),

            if (detail != null)
              SText.bodyMedium(
                detail!,
                softWrap: true,
                textAlign: TextAlign.center,
              ),

            if (child != null) child!,

            if (isShowCloseButton)
              SButton.filled(
                text: closeText ?? locale.okayString,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}
