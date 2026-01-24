import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SToggleBar extends StatelessWidget {
  const SToggleBar({
    super.key,
    required this.activeIndex,
    required this.onPressed,
    required this.barHeaders,
    required this.children,
  });
  final int activeIndex;
  final void Function(int) onPressed;
  final List<String> barHeaders;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: IndexedStack(index: activeIndex, children: children),
        ),
        _Bar(
          barHeaders: barHeaders,
          activeIndex: activeIndex,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.barHeaders,
    required this.activeIndex,
    required this.onPressed,
  });
  final List<String> barHeaders;
  final int activeIndex;
  final void Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.rometDKBlue(context),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12.0),
          ),
        ),
        child: Center(
          child: IntrinsicWidth(
            child: Row(
              spacing: 4.0,
              children: [
                for (var e in barHeaders)
                  Expanded(
                    child: _Item(
                      text: e,
                      isActive: barHeaders.indexOf(e) == activeIndex,
                      onPressed: () => onPressed(barHeaders.indexOf(e)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.text, required this.isActive, this.onPressed});
  final String text;
  final bool isActive;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
        child: SText.headlineMedium(
          text,
          textAlign: TextAlign.center,
          // color: isActive ? colorScheme.textWhite : colorScheme.textLightGrey,
        ),
      ),
    );
  }
}
