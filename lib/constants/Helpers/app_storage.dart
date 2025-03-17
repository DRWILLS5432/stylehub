import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Key for storing the password
  static const String _passwordKey = 'user_password';

  // Save the password to SharedPreferences
  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }

  // Retrieve the password from SharedPreferences
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // Clear the password from SharedPreferences
  static Future<void> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }
}
