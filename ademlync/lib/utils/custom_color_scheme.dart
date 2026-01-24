import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_delegate.dart';

extension CustomColorScheme on ColorScheme {
  Color get grey => const Color(0xff707070);
  Color get black => const Color(0xff000000);
  Color get _rometDKBlue => const Color(0xff0c2340);
  Color get _accentGold => const Color(0xffffcd00);
  Color get _connected => const Color(0xff56E126);
  Color get _warning => const Color(0xffB3261E);
  Color get _background => const Color(0xffF2F2F7);
  Color get _cardBackground => const Color(0xffFFFFFF);
  Color get _subCardBackground => const Color(0xffE9E9EB);
  Color get _divider => const Color(0xffEAEAEA);
  Color get _white => const Color(0xffFFFFFF);

  Color appBackground(BuildContext context) => _dark(context, _background, 1.0);
  Color cardBackground(BuildContext context) =>
      _dark(context, _cardBackground, 0.9);
  Color subCardBackground(BuildContext context) =>
      _dark(context, _subCardBackground, 0.84);
  Color border(BuildContext context) => context.isDark ? grey : black;
  Color barBackground(BuildContext context) => rometDKBlue(context);
  Color divider(BuildContext context) => _dark(context, _divider, 0.8);

  Color buttonForeground(BuildContext context) => white(context);
  Color buttonBackground(BuildContext context) => rometDKBlue(context);

  Color navigationBarActiveText(BuildContext context) => white(context);
  Color navigationBarActiveBackground(BuildContext context) =>
      rometDKBlue(context);

  Color text(BuildContext context) =>
      context.isDark ? white(context) : colorScheme.black;
  Color logo(BuildContext context) =>
      context.isDark ? white(context) : rometDKBlue(context);

  Color white(BuildContext context) => _dark(context, _white, 0.15);
  Color rometDKBlue(BuildContext context) => _dark(context, _rometDKBlue, 0.1);
  Color accentGold(BuildContext context) => _dark(context, _accentGold, 0.1);
  Color connected(BuildContext context) => _dark(context, _connected, 0.1);
  Color warning(BuildContext context) => _dark(context, _warning, 0.1);
}

extension _BuildContextExt on BuildContext {
  bool get isDark => Provider.of<AppStateNotifier>(this).isDark;
}

Color _dark(BuildContext context, Color color, double offset) {
  final factor = context.isDark ? offset : 0.0;

  return Color.fromRGBO(
    mapColor(color.r, factor),
    mapColor(color.g, factor),
    mapColor(color.b, factor),
    1,
  );
}

int mapColor(double code, double factor) {
  return ((code * 255) * (1 - factor)).round();
}
