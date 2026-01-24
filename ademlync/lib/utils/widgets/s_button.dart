import 'package:flutter/material.dart';

import 's_loading_animation.dart';

class SButton extends StatelessWidget {
  final SButtonType type;
  final String text;
  final Widget? icon;
  final double? loadingSize;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Size? minimumSize;
  final bool isLoading;
  final void Function()? onPressed;

  const SButton({
    super.key,
    required this.type,
    required this.text,
    this.icon,
    this.loadingSize,
    this.foregroundColor,
    this.backgroundColor,
    this.padding,
    this.minimumSize,
    this.isLoading = false,
    this.onPressed,
  });

  factory SButton.filled({
    required String text,
    bool isLoading = false,
    double? loadingSize,
    Color? foregroundColor,
    Color? backgroundColor,
    EdgeInsets? padding,
    Size? minimumSize,
    void Function()? onPressed,
  }) {
    return SButton(
      type: SButtonType.filled,
      text: text,
      padding: padding,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      minimumSize: minimumSize,
      loadingSize: loadingSize,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    );
  }

  factory SButton.outlined({
    required String text,
    bool isLoading = false,
    EdgeInsets? padding,
    Size? minimumSize,
    void Function()? onPressed,
  }) {
    return SButton(
      type: SButtonType.outlined,
      text: text,
      isLoading: isLoading,
      minimumSize: minimumSize,
      padding: padding,
      onPressed: isLoading ? null : onPressed,
    );
  }

  factory SButton.text({
    required String text,
    bool isLoading = false,
    Color? foregroundColor,
    Size? minimumSize,
    double? loadingSize,
    void Function()? onPressed,
  }) {
    return SButton(
      type: SButtonType.text,
      text: text,
      isLoading: isLoading,
      foregroundColor: foregroundColor,
      minimumSize: minimumSize,
      loadingSize: loadingSize,
      onPressed: isLoading ? null : onPressed,
    );
  }

  factory SButton.filledWithIcon({
    required String text,
    required Widget icon,
    void Function()? onPressed,
    Size? minimumSize,
  }) {
    return SButton(
      type: SButtonType.filledWithIcon,
      text: text,
      icon: icon,
      minimumSize: minimumSize,
      onPressed: onPressed,
    );
  }

  factory SButton.outlinedWithIcon({
    required String text,
    required Widget icon,
    void Function()? onPressed,
    Size? minimumSize,
  }) {
    return SButton(
      type: SButtonType.outlinedWithIcon,
      text: text,
      icon: icon,
      minimumSize: minimumSize,
      onPressed: onPressed,
    );
  }

  factory SButton.textWithIcon({
    required String text,
    required Widget icon,
    void Function()? onPressed,
  }) {
    return SButton(
      type: SButtonType.textWithIcon,
      text: text,
      icon: icon,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = isLoading
        ? SizedBox(
            width: loadingSize ?? 24.0,
            child: SLoadingAnimationStaggered(
              color: foregroundColor,
              size: loadingSize ?? 24.0,
            ),
          )
        : Text(text, softWrap: false, overflow: TextOverflow.fade);
    final minimumSize = this.minimumSize ?? const Size(double.maxFinite, 40.0);

    switch (type) {
      case SButtonType.filled:
        content = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor?.withValues(alpha: 0.4),
            minimumSize: minimumSize,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
          child: content,
        );
        break;
      case SButtonType.outlined:
        content = OutlinedButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
          child: content,
        );
        break;
      case SButtonType.text:
        content = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor,
            minimumSize: minimumSize,
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
          child: content,
        );
        break;
      case SButtonType.filledWithIcon:
        content = FilledButton.icon(
          onPressed: onPressed,
          label: content,
          icon: icon!,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 10.0,
            ),
            minimumSize: minimumSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
        );
      case SButtonType.outlinedWithIcon:
        content = OutlinedButton.icon(
          onPressed: onPressed,
          label: content,
          icon: icon!,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 10.0,
            ),
            minimumSize: minimumSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
        );
      case SButtonType.textWithIcon:
        content = TextButton.icon(
          onPressed: onPressed,
          label: content,
          icon: icon!,
        );
    }

    return Opacity(
      opacity: isLoading || onPressed == null ? 0.4 : 1.0,
      child: content,
    );
  }
}

enum SButtonType {
  filled,
  outlined,
  text,
  filledWithIcon,
  outlinedWithIcon,
  textWithIcon,
}
