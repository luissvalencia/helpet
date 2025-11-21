import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _keyId = 'user_id';
  static const _keyName = 'nombre';
  static const _keyTipo = 'tipo_usuario';

  static Future<void> saveUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, data['id']);
    await prefs.setString(_keyName, data['nombre']);
    await prefs.setString(_keyTipo, data['tipo']);
  }

  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyId) ?? 0;
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? '';
  }

  static Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTipo) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
