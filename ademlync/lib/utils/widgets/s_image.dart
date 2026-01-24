import 'package:flutter/material.dart';

class SImage extends StatelessWidget {
  final String filename;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const SImage({
    BuildContext? context,
    super.key,
    required this.filename,
    this.width,
    this.height,
    this.fit = BoxFit.scaleDown,
    this.color,
  });

  const SImage.logo({super.key, this.height, this.color})
    : filename = 'logo_romet',
      width = double.maxFinite,
      fit = BoxFit.fitWidth;

  String _getPath(String filename) {
    return 'assets/images/$filename.png';
  }

  Size? get _size =>
      width != null && height != null ? Size(width!, height!) : null;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getPath(filename),
      width: _size == null ? width : _size!.width,
      height: _size == null ? height : _size!.height,
      fit: fit,
      color: color,
    );
  }
}
