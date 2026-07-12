import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class LocalManager {
  LocalManager({
    required this.accessToken,
    required this.tenantId,
    FlutterSecureStorage? secureStorage,
    Box<String>? settingsBox,
  }) : _secureStorage = secureStorage,
       _settingsBox = settingsBox;

  static const _accessTokenKey = 'access_token';
  static const _tenantIdKey = 'tenant_id';

  static Future<LocalManager> create({
    required String fallbackAccessToken,
    required String fallbackTenantId,
  }) async {
    const secureStorage = FlutterSecureStorage();
    final settingsBox = await Hive.openBox<String>('app_settings');

    return LocalManager(
      accessToken:
          await secureStorage.read(key: _accessTokenKey) ?? fallbackAccessToken,
      tenantId: settingsBox.get(_tenantIdKey) ?? fallbackTenantId,
      secureStorage: secureStorage,
      settingsBox: settingsBox,
    );
  }

  String accessToken;
  String tenantId;

  final FlutterSecureStorage? _secureStorage;
  final Box<String>? _settingsBox;

  Future<void> saveAccessToken(String value) async {
    accessToken = value;
    await _secureStorage?.write(key: _accessTokenKey, value: value);
  }

  Future<void> saveTenantId(String value) async {
    tenantId = value;
    await _settingsBox?.put(_tenantIdKey, value);
  }

  Future<void> saveSession({
    required String accessToken,
    required String tenantId,
  }) async {
    await saveAccessToken(accessToken);
    await saveTenantId(tenantId);
  }

  Future<void> clearSession() async {
    accessToken = '';
    tenantId = '';
    await _secureStorage?.delete(key: _accessTokenKey);
    await _settingsBox?.delete(_tenantIdKey);
  }
}
