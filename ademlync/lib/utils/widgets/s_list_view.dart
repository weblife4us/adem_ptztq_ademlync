import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';
import 'svg_image.dart';

class SListView<T> extends StatelessWidget {
  final List<T> value;
  final String? header;
  final String? footer;
  final bool hasArrow;
  final String Function(T) textBuilder;
  final String Function(T)? iconBuilder;
  final Color Function(T)? colorBuilder;
  final bool Function(T)? disableChecker;
  final void Function(T)? onPressed;

  const SListView({
    super.key,
    required this.value,
    this.header,
    this.footer,
    this.hasArrow = true,
    required this.textBuilder,
    this.iconBuilder,
    this.colorBuilder,
    this.disableChecker,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null && value.isNotEmpty) _Header(header!),
        _Decoration(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, i) {
              final o = value[i];
              final text = textBuilder(o);
              final icon = iconBuilder != null ? iconBuilder!(o) : null;
              final color = colorBuilder != null ? colorBuilder!(o) : null;

              return _Item(
                text,
                icon: icon,
                color: color,
                hasArrow: hasArrow,
                isDisabled: disableChecker == null ? false : disableChecker!(o),
                onPressed: onPressed == null ? null : () => onPressed!(o),
              );
            },
            separatorBuilder: (_, _) {
              return Divider(
                indent: iconBuilder == null ? 24.0 : 54.0,
                endIndent: 18.0,
              );
            },
            itemCount: value.length,
          ),
        ),
        if (footer != null && value.isNotEmpty) _Footer(footer!),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String text;

  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 4.0),
      child: SText.bodyMedium(text, color: colorScheme.grey),
    );
  }
}

class _Footer extends StatelessWidget {
  final String text;

  const _Footer(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: SText.bodySmall(text, color: colorScheme.grey, softWrap: true),
    );
  }
}

class _Decoration extends StatelessWidget {
  final Widget child;

  const _Decoration({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.0),
        color: colorScheme.cardBackground(context),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: child,
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String text;
  final String? icon;
  final Color? color;
  final bool hasArrow;
  final bool isDisabled;
  final void Function()? onPressed;

  const _Item(
    this.text, {
    this.icon,
    this.color,
    this.hasArrow = true,
    this.isDisabled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onPressed,
      child: Opacity(
        opacity: isDisabled || onPressed == null ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Row(
            spacing: 12.0,
            children: [
              if (icon != null)
                SvgImage(icon!, width: 24.0, height: 24.0, color: color),

              Expanded(
                child: SText.bodyMedium(text, color: color, softWrap: true),
              ),

              if (hasArrow)
                SvgImage(
                  'arrow-right',
                  width: 20.0,
                  height: 20.0,
                  color: colorScheme.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
