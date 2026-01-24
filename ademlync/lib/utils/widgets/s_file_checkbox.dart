import 'package:ademlync_cloud/utils/enums.dart';
import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../functions.dart';
import 's_checkbox.dart';
import 's_icon.dart';
import 's_support_button.dart';
import 's_text.dart';
import 'svg_image.dart';

class SFileCheckbox extends StatelessWidget {
  final bool isActive;
  final String text;
  final bool isDisabled;
  final ExportFormat? fileFormat;
  final bool hasQuickLook;
  final bool isShowChecked;
  final void Function(bool) onChanged;
  final void Function()? onPressed;

  const SFileCheckbox({
    super.key,
    required this.isActive,
    required this.text,
    required this.isDisabled,
    this.isShowChecked = false,
    this.fileFormat,
    this.hasQuickLook = false,
    required this.onChanged,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        spacing: 8.0,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => onChanged(!isActive),
            child: Row(
              spacing: 8.0,
              children: [
                if (fileFormat?.svg case final svg?)
                  SvgImage(svg, width: 20.0, height: 20.0),
                Expanded(child: SText.bodyMedium(text, softWrap: true)),
                if (isShowChecked)
                  SIcon(
                    Icons.check_circle_rounded,
                    size: 14.0,
                    color: colorScheme.connected(context),
                  ),
                SCheckbox(
                  isActive: isActive,
                  isDisabled: isDisabled,
                  onPressed: onChanged,
                ),
              ],
            ),
          ),
          if (hasQuickLook && isActive)
            SSupportButton.quickLook(onPressed: onPressed),
        ],
      ),
    );
  }
}
