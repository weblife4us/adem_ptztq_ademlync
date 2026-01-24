import 'package:ademlync_device/ademlync_device.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../ui_specification.dart';
import 's_style_text.dart';
import 's_text.dart';
import 'svg_image.dart';

class SDropdownButton<T> extends StatefulWidget {
  final T? value;
  final int? index;
  final List<T> items;
  final bool isEdited;
  final bool isDisable;
  final bool softWrap;
  final TextOverflow? overflow;
  final String? prefixString;
  final String Function(T)? stringBuilder;
  final void Function(T?) onChanged;

  const SDropdownButton({
    super.key,
    required this.value,
    this.index,
    required this.items,
    this.isEdited = false,
    this.isDisable = false,
    this.softWrap = false,
    this.overflow,
    this.prefixString,
    required this.stringBuilder,
    required this.onChanged,
  }) : assert((T != String && stringBuilder != null) || T == String);

  @override
  State<SDropdownButton<T>> createState() => _SDropdownButtonState<T>();
}

class _SDropdownButtonState<T> extends State<SDropdownButton<T>> {
  bool _isMenuOpen = false;

  bool get _isEdited => widget.isEdited;
  bool get _isDisable => widget.isDisable;
  int? get _index => widget.index;
  bool get _softWrap => widget.softWrap;
  TextOverflow? get _overflow => widget.overflow;

  @override
  Widget build(BuildContext context) {
    final fillColor = _isEdited
        ? colorScheme.accentGold(context)
        : Colors.transparent;
    final textColor = _isEdited ? colorScheme.black : colorScheme.text(context);

    final text = widget.value != null
        ? widget.stringBuilder!(widget.value as T)
        : (widget.prefixString ?? locale.notSetString);

    return DropdownButtonHideUnderline(
      child: Opacity(
        opacity: _isDisable ? 0.4 : 1.0,
        child: DropdownButton2(
          dropdownStyleData: DropdownStyleData(
            useRootNavigator: true,
            maxHeight: UISpecification.screenHeight / 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: colorScheme.cardBackground(context),
            ),
            offset: const Offset(0.0, -8.0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all(5.0),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
            height: 40.0,
          ),
          value: widget.value,
          isDense: true,
          isExpanded: true,
          alignment: Alignment.center,
          items: [
            for (var e in widget.items)
              DropdownMenuItem<T>(
                value: e,
                alignment: Alignment.centerRight,
                child: Container(
                  decoration:
                      widget.value == e ||
                          (widget.value == null && e == IntervalLogField.notSet)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: colorScheme.subCardBackground(context),
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: SStyleText(
                      e is String ? e : widget.stringBuilder!(e),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
          ],
          customButton: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: colorScheme.border(context),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              if (_index != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SText.bodyMedium(_index!.toString()),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SStyleText(
                        text,
                        textAlign: TextAlign.center,
                        textColor: textColor,
                        textStyle: STextStyle.titleMedium.style,
                        softWrap: _softWrap,
                        overflow: _overflow,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isMenuOpen ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgImage('arrow-down', color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onMenuStateChange: (b) => setState(() => _isMenuOpen = b),
          onChanged: _isDisable ? null : widget.onChanged,
        ),
      ),
    );
  }
}
