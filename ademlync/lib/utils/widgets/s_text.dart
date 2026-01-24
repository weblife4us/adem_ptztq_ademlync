import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';

class SText extends StatelessWidget {
  final STextStyle type;
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final bool softWrap;

  const SText(
    this.text, {
    super.key,
    required this.type,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  });

  const SText.headlineMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.headlineMedium;

  const SText.titleLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.titleLarge;

  const SText.titleMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.titleMedium;

  const SText.titleSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.titleSmall;

  const SText.bodyMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.bodyMedium;

  const SText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.fade,
    this.softWrap = false,
  }) : type = STextStyle.bodySmall;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      style: type.style.copyWith(
        color: color ?? colorScheme.text(context),
        height: 1.2,
      ),
    );
  }
}

enum STextStyle {
  headlineMedium,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyMedium,
  bodySmall;

  TextStyle get style {
    return {
      STextStyle.headlineMedium: textTheme.headlineMedium,
      STextStyle.titleLarge: textTheme.titleLarge,
      STextStyle.titleMedium: textTheme.titleMedium,
      STextStyle.titleSmall: textTheme.titleSmall,
      STextStyle.bodyMedium: textTheme.bodyMedium,
      STextStyle.bodySmall: textTheme.bodySmall,
    }[this]!;
  }
}
