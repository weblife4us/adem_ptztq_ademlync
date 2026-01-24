import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static PreferenceUtils? _instance;
  static SharedPreferences? _preferences;

  PreferenceUtils._();

  /// Init the preference utils.
  static Future<PreferenceUtils> getInstance() async {
    if (_instance == null && _preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      _instance = PreferenceUtils._();
    }
    return _instance!;
  }

  /// Store the value as [String].
  static void setString(String k, String v) => _preferences?.setString(k, v);

  /// Store the value as [List] of [String].
  static void setStringList(String k, List<String> v) =>
      _preferences?.setStringList(k, v);

  /// Store the value as [bool].
  static void setBool(String k, bool v) => _preferences?.setBool(k, v);

  /// Store the value as [int].
  static void setInt(String k, int v) => _preferences?.setInt(k, v);

  /// Store the value as [double].
  static void setDouble(String k, double v) => _preferences?.setDouble(k, v);

  /// Retrieve the value as [String].
  static String? getString(String k) => _preferences?.getString(k);

  /// Retrieve the value as [List] of [String]
  static List<String>? getStringList(String k) =>
      _preferences?.getStringList(k);

  /// Retrieve the value as [bool].
  static bool? getBool(String k) => _preferences?.getBool(k);

  /// Retrieve the value as [int].
  static int? getInt(String k) => _preferences?.getInt(k);

  /// Retrieve the value as [double].
  static double? getDouble(String k) => _preferences?.getDouble(k);

  /// Remove all stored value.
  static void remove(String k) => _preferences?.remove(k);
}
