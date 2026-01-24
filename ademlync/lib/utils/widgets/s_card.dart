import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SCard extends StatelessWidget {
  final String? title;
  final String? footer;
  final EdgeInsetsGeometry? padding;
  final void Function()? onPressed;
  final Widget? child;

  const SCard({
    super.key,
    this.title,
    this.footer,
    this.padding,
    this.onPressed,
    this.child,
  });

  factory SCard.column({
    double spacing = 8.0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    String? title,
    String? footer,
    EdgeInsetsGeometry? padding,
    void Function()? onPressed,
    required List<Widget> children,
  }) {
    return SCard(
      title: title,
      footer: footer,
      padding: padding,
      onPressed: onPressed,
      child: Column(
        spacing: spacing,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  factory SCard.columnForDisplay({
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    String? title,
    String? footer,
    void Function()? onPressed,
    required List<Widget> children,
  }) {
    return SCard(
      title: title,
      footer: footer,
      padding: const EdgeInsets.all(18.0),
      onPressed: onPressed,
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SText.bodyMedium(title!, color: colorScheme.grey),
          ),
        GestureDetector(
          onTap: onPressed,
          child: Card(
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: child,
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: SText.bodySmall(
              footer!,
              color: colorScheme.grey,
              softWrap: true,
            ),
          ),
      ],
    );
  }
}
