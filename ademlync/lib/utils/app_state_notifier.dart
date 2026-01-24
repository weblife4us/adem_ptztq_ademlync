part of './app_delegate.dart';

class AppStateNotifier extends ChangeNotifier {
  // Singleton
  AppStateNotifier._internal();
  static final _notifier = AppStateNotifier._internal();

  factory AppStateNotifier() => _notifier;

  /// Determine if system appearance is applied.
  bool get isSysAppearance => PreferenceUtils.getBool(sysAppearanceKey) ?? true;
  // bool get isSysAppearance => false;

  /// Determine if system text size is applied.
  // bool get isSysTextScale => PreferenceUtils.getBool(sysTextScaleKey) ?? true;
  bool get isSysTextScale => false;

  /// Determine if dark mode is applied.
  bool get isDark => PreferenceUtils.getBool(isDarkKey) ?? false;
  // bool get isDark => false;

  /// Get the text scale.
  // double get textScale => PreferenceUtils.getDouble(textScaleKey) ?? 1.0;
  double get textScale => 1.0;

  /// Get the media query.
  MediaQueryData get mediaQuery => MediaQuery.of(AppDelegate.rootContext!);

  /// Toggles the system appearance.
  void toggleSysAppearance() {
    PreferenceUtils.setBool(sysAppearanceKey, !isSysAppearance);
    if (isSysAppearance) applySysAppearance();
    notifyListeners();
  }

  /// Toggles the system text scale.
  void toggleSysTextScale() {
    PreferenceUtils.setBool(sysTextScaleKey, !isSysTextScale);
    if (isSysTextScale) applySysTextScale();
    notifyListeners();
  }

  /// Toggles the app appearance.
  void toggleAppearance() {
    PreferenceUtils.setBool(isDarkKey, !isDark);
    notifyListeners();
  }

  /// Applies the system appearance.
  void applySysAppearance() {
    PreferenceUtils.setBool(
      isDarkKey,
      mediaQuery.platformBrightness == Brightness.dark,
    );
  }

  /// Updates the app text scale.
  void updateTextScale(double val) {
    PreferenceUtils.setDouble(textScaleKey, val.clamped);
    notifyListeners();
  }

  /// Applies the system text scale.
  void applySysTextScale() {
    PreferenceUtils.setDouble(
      textScaleKey,
      mediaQuery.textScaler.scale(1.0).clamped,
    );
  }

  void Function() get notifyListener => notifyListeners;
}

extension _DoubleExt on double {
  double get clamped => clamp(minTextScale, maxTextScale).toDouble();
}
