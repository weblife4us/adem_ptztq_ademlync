import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_style_text.dart';
import 's_text.dart';
import 'svg_image.dart';

class SDecoration extends StatelessWidget {
  final String? icon;
  final String? header;
  final String? headerSuffix;
  final String? subHeader;
  final bool isDisable;
  final double spacing;
  final STextStyle? type;
  final Widget? child;

  const SDecoration({
    super.key,
    this.icon,
    this.header,
    this.headerSuffix,
    this.subHeader,
    this.isDisable = false,
    this.spacing = 4.0,
    this.type,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: spacing,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null || header != null || subHeader != null)
          Row(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) SvgImage(icon!),
              if (header != null)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: SStyleText(
                          header!,
                          softWrap: true,
                          textStyle: type?.style ?? STextStyle.bodyMedium.style,
                          tagTextStyle: STextStyle.titleMedium.style,
                        ),
                      ),
                      if (headerSuffix != null)
                        SText.titleMedium(' — ${headerSuffix!}'),
                    ],
                  ),
                ),
              if (subHeader != null)
                Expanded(
                  child: SStyleText(
                    subHeader!,
                    textStyle: STextStyle.bodySmall.style,
                    tagTextStyle: STextStyle.titleSmall.style,
                    textColor: colorScheme.grey,
                    softWrap: true,
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        if (child != null)
          Opacity(opacity: isDisable ? 0.4 : 1.0, child: child!),
      ],
    );
  }
}
