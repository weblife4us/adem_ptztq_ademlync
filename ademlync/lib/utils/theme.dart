import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_color_scheme.dart';

ThemeData theme(BuildContext context, {required bool isDark}) {
  final colorScheme = Theme.of(context).colorScheme;

  final borderRadius = BorderRadius.circular(8.0);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: colorScheme.rometDKBlue(context),
      onSurface: colorScheme.grey,
      surface: colorScheme.rometDKBlue(context),
    ),

    scaffoldBackgroundColor: colorScheme.appBackground(context),
    iconTheme: IconThemeData(color: colorScheme.white(context)),
    fontFamily: 'MinionPro',
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    canvasColor: colorScheme.cardBackground(context), // Drop down menu color
    splashFactory: NoSplash.splashFactory,

    dialogTheme: DialogThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.cardBackground(context),
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.barBackground(context),
      titleTextStyle: TextStyle(
        fontFamily: 'Madera',
        fontSize: 20.0,
        height: 1.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.white(context),
      ),
      iconTheme: IconThemeData(color: colorScheme.white(context)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => colorScheme.white(context),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? colorScheme.accentGold(context)
            : colorScheme.subCardBackground(context),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => Colors.transparent,
      ),
      trackOutlineWidth: WidgetStateProperty.resolveWith((s) => 1.2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),

    cardTheme: CardThemeData(
      color: colorScheme.cardBackground(context),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.0,
      margin: EdgeInsets.zero,
    ),

    checkboxTheme: CheckboxThemeData(
      visualDensity: VisualDensity.compact,
      checkColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? colorScheme.black
            : Colors.transparent,
      ),
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? colorScheme.accentGold(context)
            : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      side: WidgetStateBorderSide.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const BorderSide(color: Colors.transparent)
            : BorderSide(width: 1.2, color: colorScheme.grey),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: colorScheme.divider(context),
      space: 4.0,
      thickness: 1.2,
    ),

    buttonTheme: const ButtonThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.buttonForeground(context),
        backgroundColor: colorScheme.buttonBackground(context),
        iconColor: colorScheme.buttonForeground(context),
        disabledForegroundColor: colorScheme
            .buttonForeground(context)
            .withValues(alpha: 0.4),
        disabledBackgroundColor: colorScheme
            .buttonBackground(context)
            .withValues(alpha: 0.4),
        minimumSize: const Size(double.maxFinite, 40.0),
        shadowColor: colorScheme.white(context),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.text(context),
        iconColor: colorScheme.text(context),
        disabledForegroundColor: colorScheme
            .text(context)
            .withValues(alpha: 0.4),
        minimumSize: const Size(double.maxFinite, 40.0),
        side: BorderSide(width: 1.2, color: colorScheme.text(context)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        iconColor: colorScheme.text(context),
        foregroundColor: colorScheme.text(context),
        disabledForegroundColor: colorScheme
            .text(context)
            .withValues(alpha: 0.4),
        padding: const EdgeInsets.all(4.0),
        minimumSize: const Size(0.0, 0.0),
      ),
    ),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Madera',
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      titleLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      titleSmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      // Default text style
      bodyMedium: TextStyle(
        fontSize: 16.0,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      bodySmall: TextStyle(
        fontSize: 14.0,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      // Default button text style
      labelLarge: const TextStyle(
        fontSize: 16.0,
        height: 1.0,
        fontWeight: FontWeight.bold,
      ),
    ),

    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        dateTimePickerTextStyle: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: colorScheme.text(context),
          height: 1.0,
          fontFamily: 'MinionPro',
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.cardBackground(context),
    ),

    drawerTheme: DrawerThemeData(
      backgroundColor: colorScheme.barBackground(context),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(4.0),
      hintStyle: TextStyle(
        fontSize: 16.0,
        color: colorScheme.text(context).withValues(alpha: 0.5),
        height: 1.0,
      ),
      hintFadeDuration: const Duration(milliseconds: 400),
      errorStyle: TextStyle(
        fontSize: 14.0,
        height: 0.4,
        color: colorScheme.warning(context),
      ),
      labelStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        height: 1.0,
        color: colorScheme.border(context),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.border(context), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.border(context), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.warning(context), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.warning(context), width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: colorScheme.border(context).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.cardBackground(context),
      inactiveTrackColor: colorScheme.cardBackground(context),
      thumbColor: colorScheme.white(context),
      trackHeight: 3.0,
      overlayShape: SliderComponentShape.noOverlay,
      tickMarkShape: _VerticalTickMarkShape(),
      trackShape: const RectangularSliderTrackShape(),
      overlayColor: Colors.transparent,
    ),

    dataTableTheme: DataTableThemeData(
      dataTextStyle: TextStyle(
        fontSize: 16.0,
        height: 1.0,
        color: colorScheme.text(context),
      ),
      headingTextStyle: TextStyle(
        fontSize: 14.0,
        height: 1.0,
        color: colorScheme.grey,
      ),
      // dataRowMinHeight: 20.0,
      // dataRowMaxHeight: 20.0,
      dividerThickness: 2.0,
    ),
  );
}

class _VerticalTickMarkShape extends SliderTickMarkShape {
  @override
  Size getPreferredSize({
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
  }) {
    return const Size(5.0, 20.0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final paint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..strokeWidth = 3.0;

    context.canvas.drawLine(
      center - const Offset(0, 6),
      center + const Offset(0, 6),
      paint,
    );
  }
}
