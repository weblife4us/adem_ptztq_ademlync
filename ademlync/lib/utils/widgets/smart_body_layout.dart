import 'package:flutter/material.dart';

import 's_button.dart';
import 's_loading_animation.dart';
import '../ui_specification.dart';

class SmartBodyLayout extends StatelessWidget {
  final bool isDataReady;
  final bool scrollEnabled;
  final bool enableDefaultPadding;
  final bool paddingForAllPlatform;
  final double maxWidth;
  final double spacing;
  final double horizontalPaddingForMobile;
  final double horizontalPaddingForTablet;
  final double? heightFactor;
  final ScrollPhysics? physics;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget>? bottomWidgets;
  final String? bottomBtnTitle;
  final bool isBottomBtnLoading;
  final bool isBottomBtnDisable;
  final VoidCallback? onBottomBtnPressed;
  final List<Widget>? children;
  final Widget? child;

  const SmartBodyLayout({
    super.key,
    this.isDataReady = true,
    this.scrollEnabled = true,
    this.enableDefaultPadding = true,
    this.paddingForAllPlatform = false,
    this.maxWidth = UISpecification.maxWidthForTablet,
    this.spacing = 24.0,
    this.horizontalPaddingForMobile = 24.0,
    this.horizontalPaddingForTablet = 0.0,
    this.heightFactor = 1.0,
    this.physics,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.bottomWidgets,
    this.bottomBtnTitle,
    this.isBottomBtnLoading = false,
    this.isBottomBtnDisable = false,
    this.onBottomBtnPressed,
    this.children,
    this.child,
  });

  @override
  Widget build(context) {
    late Widget contentWidget;

    if (isDataReady) {
      contentWidget = Column(
        spacing: spacing,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDataReady) const SLoadingAnimationStaggered(),
          if (isDataReady && child != null) child!,
          if (isDataReady && children != null) ...children!,
          if (bottomWidgets != null || bottomBtnTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              child: Column(
                spacing: 12.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bottomWidgets != null) ...bottomWidgets!,
                  if (bottomBtnTitle != null)
                    SButton.filled(
                      text: bottomBtnTitle!,
                      isLoading: isBottomBtnLoading,
                      onPressed: isBottomBtnDisable ? null : onBottomBtnPressed,
                    ),
                ],
              ),
            ),
        ],
      );

      /// Constrain the content width and apply horizontal padding based on platform
      contentWidget = ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: UISpecification.isTablet
                ? horizontalPaddingForTablet
                : horizontalPaddingForMobile,
          ),
          child: contentWidget,
        ),
      );

      /// Conditionally add a [SingleChildScrollView] based on [scrollEnabled].
      if (scrollEnabled) {
        contentWidget = SingleChildScrollView(
          physics: physics,

          /// Show top and bottom padding when scrollable.
          padding: enableDefaultPadding
              ? UISpecification.bodyPadding
              : EdgeInsets.zero,
          child: SizedBox(
            width: double.maxFinite,
            child: Center(child: contentWidget),
          ),
        );
      }
    } else {
      contentWidget = const SLoadingAnimationStaggered();
    }

    return SafeArea(
      child: Center(heightFactor: heightFactor, child: contentWidget),
    );
  }
}
