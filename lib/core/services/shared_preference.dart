import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  SharedPreference._private();

  factory SharedPreference() {
    return _instance;
  }

  static final SharedPreference _instance = SharedPreference._private();

  static SharedPreferences? _preferences;

  static Future onInitialSharedPreferences() async {
    // SharedPreferences.setMockInitialValues({});
    _preferences = await SharedPreferences.getInstance();
  }

  void writeStorage(String key, value) {
    if (value is String) {
      _preferences!.setString(key, value);
    }
    if (value is bool) {
      _preferences!.setBool(key, value);
    }
    if (value is int) {
      _preferences!.setInt(key, value);
    }
    if (value is double) {
      _preferences!.setDouble(key, value);
    }
    if (value is List<String>) {
      _preferences!.setStringList(key, value);
    }
  }

  dynamic readStorage(String k) {
    final result = _preferences!.get(k);
    return result;
  }

  void removeValue(String k) {
    _preferences!.remove(k);
  }

  Future logOutStorage() async {
    await _preferences!.remove(SpKeys.userToken);
    await _preferences!.remove(SpKeys.email);
    await _preferences!.remove(SpKeys.userID);
    await _preferences!.remove(SpKeys.fcmToken);
    await _preferences!.remove(SpKeys.countAds);
  }
}
