import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String keySelectedCurrency = "selected_currency";
  static const String keySelectedSizeUnit = "selected_dimesion_unit";
  static const String keySelectedWeightUnit = "selected_weight_unit";

  // Sauvegarder les valeurs sélectionnées
  static Future<void> saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySelectedCurrency, currency);
  }

  static Future<void> saveSelectedSizeUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySelectedSizeUnit, unit);
  }

  static Future<void> saveSelectedWeightUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySelectedWeightUnit, unit);
  }

  // Récupérer les dernières valeurs sélectionnées
  static Future<String?> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keySelectedCurrency);
  }

  static Future<String?> getSelectedSizeUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keySelectedSizeUnit);
  }

  static Future<String?> getSelectedWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keySelectedWeightUnit);
  }
}
