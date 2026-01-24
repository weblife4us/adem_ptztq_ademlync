import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';

class SLoadingAnimationStaggered extends StatelessWidget {
  final double size;
  final Color? color;

  const SLoadingAnimationStaggered({super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: color ?? colorScheme.text(context),
        size: size,
      ),
    );
  }
}

class SLoadingAnimationWave extends StatelessWidget {
  const SLoadingAnimationWave({super.key, this.size = 24.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: colorScheme.text(context),
        size: size,
      ),
    );
  }
}

class SLoadingAnimationThreeArchedCircle extends StatelessWidget {
  const SLoadingAnimationThreeArchedCircle({super.key, this.size = 24.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
        color: colorScheme.text(context),
        size: size,
      ),
    );
  }
}
