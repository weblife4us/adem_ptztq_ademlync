import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SStyleText extends StatelessWidget {
  final String text;
  final FontFeature? fontFeature;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final TextStyle? tagTextStyle;
  final Color? textColor;
  final double? textHeight;
  final bool softWrap;
  final TextOverflow? overflow;

  const SStyleText(
    this.text, {
    super.key,
    this.textAlign,
    this.textStyle,
    this.tagTextStyle,
    this.textColor,
    this.textHeight,
    this.softWrap = false,
    this.overflow = TextOverflow.visible,
  }) : fontFeature = null;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? STextStyle.bodyMedium.style;
    final tagStyle = tagTextStyle ?? style;

    return StyledText(
      text: text,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      style: style.copyWith(
        color: textColor ?? colorScheme.text(context),
        height: textHeight,
      ),
      tags: {
        'g': StyledTextTag(
          style: tagStyle.copyWith(
            color: textColor ?? colorScheme.text(context),
          ),
        ),
        'd': StyledTextTag(
          style: tagStyle.copyWith(
            fontFeatures: [const FontFeature.subscripts()],
            color: textColor ?? colorScheme.text(context),
          ),
        ),
        'u': StyledTextTag(
          style: tagStyle.copyWith(
            fontFeatures: [const FontFeature.superscripts()],
            color: textColor ?? colorScheme.text(context),
          ),
        ),
      },
    );
  }
}
