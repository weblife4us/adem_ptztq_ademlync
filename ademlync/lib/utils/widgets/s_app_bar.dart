import 'package:flutter/material.dart';

import '../../features/bluetooth/ble_app_bar_action.dart';
import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 'adem_info_dialog.dart';
import 's_button.dart';
import 's_icon.dart';
import 'svg_image.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? text;
  final String? subText;
  final Widget? leading;
  final double? leadingWidth;
  final bool isDisableAction;
  final bool hasAdemInfoAction;
  final bool isLoading;
  final Widget? actionImage;
  final VoidCallback? onActionPressed;
  final List<Widget>? actions;
  final Widget? child;

  const SAppBar({
    super.key,
    this.text,
    this.subText,
    this.leading,
    this.leadingWidth,
    this.isDisableAction = false,
    this.hasAdemInfoAction = false,
    this.isLoading = false,
    this.actionImage,
    this.actions,
    this.onActionPressed,
    this.child,
  }) : assert(text != null || child != null);

  SAppBar.withMenu(
    BuildContext parentContext, {
    super.key,
    this.text,
    this.subText,
    this.isDisableAction = false,
    this.actionImage,
    bool showBluetoothAction = false,
    List<Widget>? actions,
    this.onActionPressed,
    this.isLoading = false,
  }) : leading = GestureDetector(
         onTap: Scaffold.of(parentContext).openDrawer,
         child: const SIcon(Icons.menu_rounded),
       ),
       leadingWidth = 66.0,
       hasAdemInfoAction = false,
       child = null,
       actions = [
         if (showBluetoothAction) BleAppBarAction(parentContext),
         if (actions != null) ...actions,
       ];

  SAppBar.withSubmit(
    BuildContext context, {
    super.key,
    this.text,
    this.subText,
    this.hasAdemInfoAction = false,
    this.isLoading = false,
    String? actionText,
    isSubmitLoading = false,
    VoidCallback? onPressed,
  }) : leading = null,
       leadingWidth = 66.0,
       isDisableAction = false,
       actionImage = null,
       actions = [
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 8.0),
           child: SButton.text(
             text: actionText ?? locale.saveString,
             isLoading: isSubmitLoading,
             minimumSize: Size.zero,
             foregroundColor: colorScheme.white(context),
             onPressed: onPressed,
           ),
         ),
       ],
       onActionPressed = null,
       child = null;

  @override
  Widget build(BuildContext context) {
    assert(text != null || child != null);

    TextStyle textStyle(double fontSize, double height) {
      return TextStyle(
        fontFamily: 'Madera',
        fontSize: fontSize,
        height: height,
        fontWeight: FontWeight.bold,
        color: colorScheme.white(context),
      );
    }

    return AppBar(
      title:
          child ??
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: text,
              style: textStyle(20.0, 1.0),
              children: [
                if (subText != null)
                  TextSpan(text: '\n( $subText )', style: textStyle(16.0, 1.4)),
              ],
            ),
          ),
      automaticallyImplyLeading: true,
      leading: leading,
      leadingWidth: leadingWidth,
      actions: [
        if (actionImage != null)
          _Action(
            isDisable: isDisableAction || onActionPressed == null,
            onPressed: onActionPressed,
            child: actionImage,
          ),
        if (actions != null) ...actions!,
        if (hasAdemInfoAction)
          _Action(
            onPressed: !isLoading ? () => showAdemInfoDialog(context) : null,
            child: SvgImage(
              'information',
              color: colorScheme
                  .white(context)
                  .withValues(alpha: isLoading ? 0.4 : 1.0),
            ),
          ),
        const SizedBox(width: 12.0),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _Action extends StatelessWidget {
  const _Action({this.isDisable = false, this.onPressed, this.child});
  final bool isDisable;
  final void Function()? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisable ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Opacity(opacity: isDisable ? 0.4 : 1.0, child: child),
      ),
    );
  }
}
