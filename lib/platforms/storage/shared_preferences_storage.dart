import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_template/core/storage/key_value_storage.dart';

/// [KeyValueStorage] implementation backed by `shared_preferences`.
class SharedPreferencesStorage implements KeyValueStorage {
  final SharedPreferences _prefs;

  const SharedPreferencesStorage(this._prefs);

  @override
  Future<String?> readString({required String key}) async =>
      _prefs.getString(key);

  @override
  Future<bool> writeString({
    required String key,
    required String value,
  }) async =>
      _prefs.setString(key, value);

  @override
  Future<int?> readInt({required String key}) async => _prefs.getInt(key);

  @override
  Future<bool> writeInt({required String key, required int value}) async =>
      _prefs.setInt(key, value);

  @override
  Future<bool?> readBool({required String key}) async => _prefs.getBool(key);

  @override
  Future<bool> writeBool({required String key, required bool value}) async =>
      _prefs.setBool(key, value);

  @override
  Future<bool> remove({required String key}) async => _prefs.remove(key);

  @override
  Future<bool> clear() async => _prefs.clear();
}
