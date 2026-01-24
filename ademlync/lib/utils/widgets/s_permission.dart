import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';
import 'svg_image.dart';

class SPermission extends StatelessWidget {
  final List<String> value;
  final bool Function(String) isActiveBuilder;

  const SPermission({
    super.key,
    required this.value,
    required this.isActiveBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in value) _Item(text: o, isActive: isActiveBuilder(o)),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String text;
  final bool isActive;

  const _Item({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Row(
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: colorScheme.text(context),
              shape: BoxShape.circle,
            ),
          ),
          const Gap(8.0),
          Expanded(child: SText.bodyMedium(text, softWrap: true)),
          if (isActive) const SvgImage('tick', width: 20.0, height: 20.0),
        ],
      ),
    );
  }
}
