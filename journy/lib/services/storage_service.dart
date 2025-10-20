import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> write(String key, dynamic value) async {
    if (value is bool) await _prefs.setBool(key, value);
    if (value is int) await _prefs.setInt(key, value);
    if (value is double) await _prefs.setDouble(key, value);
    if (value is String) await _prefs.setString(key, value);
  }

  static Future<void> remove(String key) async => _prefs.remove(key);

  static T? read<T>(String key) => _prefs.get(key) as T?;

  static Future<void> clear() async => _prefs.clear();
}
