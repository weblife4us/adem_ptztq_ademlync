import 'package:flutter/material.dart';

import 's_button.dart';
import 'svg_image.dart';

class SSupportButton extends StatelessWidget {
  final String svg;
  final String text;
  final void Function()? onPressed;

  const SSupportButton.autoFill({super.key, required this.onPressed})
    : svg = 'auto_fill',
      text = 'Auto Fill';

  const SSupportButton.quickLook({super.key, required this.onPressed})
    : svg = 'search',
      text = 'Quick Look';

  const SSupportButton.timeSelect({super.key, required this.onPressed})
    : svg = 'calendar',
      text = 'Search';

  const SSupportButton.timeEdit({super.key, required this.onPressed})
    : svg = 'calendar',
      text = 'Edit';

  const SSupportButton.clean({super.key, required this.onPressed})
    : svg = 'clean',
      text = 'Clean';

  @override
  Widget build(BuildContext context) {
    return SButton.outlinedWithIcon(
      text: text,
      icon: SvgImage(svg, width: 20.0, height: 20.0),
      minimumSize: const Size(0.0, 0.0),
      onPressed: onPressed,
    );
  }
}
