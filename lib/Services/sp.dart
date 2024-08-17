import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _email = 'email';
  static const String _rememberMe = 'rememberMe';

  Future<void> saveLoginDetails(
      String email, String password, bool rememberMe) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_email, email);
    await prefs.setBool(_rememberMe, rememberMe);
  }

  Future<Map<String, dynamic>> loadLoginDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_email);
    bool rememberMe = prefs.getBool(_rememberMe) ?? false;

    return {
      'email': email,
      'rememberMe': rememberMe,
    };
  }

  Future<void> clearLoginDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_email);
    await prefs.remove(_rememberMe);
  }
}
