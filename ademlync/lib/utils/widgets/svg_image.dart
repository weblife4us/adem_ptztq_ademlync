import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';

class SvgImage extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color? color;

  const SvgImage(
    this.name, {
    super.key,
    this.width = 24.0,
    this.height = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/svg/$name.svg',
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(
        color ?? colorScheme.text(context),
        BlendMode.srcIn,
      ),
    );
  }
}
