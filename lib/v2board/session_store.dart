import 'package:shared_preferences/shared_preferences.dart';

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

abstract interface class V2BoardSessionRepository {
  Future<String?> readAuthData();

  Future<void> saveAuthData(String authData);

  Future<void> clearAuthData();
}

class V2BoardSessionStore implements V2BoardSessionRepository {
  static const _authDataKey = 'v2board.authData';
  static const _managedProfileIdKey = 'v2board.managedProfileId';

  final SharedPreferencesLoader _load;

  V2BoardSessionStore({SharedPreferencesLoader? load})
    : _load = load ?? SharedPreferences.getInstance;

  @override
  Future<String?> readAuthData() async {
    return (await _load()).getString(_authDataKey);
  }

  @override
  Future<void> saveAuthData(String authData) async {
    await (await _load()).setString(_authDataKey, authData);
  }

  @override
  Future<void> clearAuthData() async {
    await (await _load()).remove(_authDataKey);
  }

  Future<int?> readManagedProfileId() async {
    return (await _load()).getInt(_managedProfileIdKey);
  }

  Future<void> saveManagedProfileId(int profileId) async {
    await (await _load()).setInt(_managedProfileIdKey, profileId);
  }
}

final v2BoardSessionStore = V2BoardSessionStore();
