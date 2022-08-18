import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/m_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveManager {
  static FlutterSecureStorage? _secureStorage;

  static const String _boxCommonName = "_bcheckin_box_name";
  static const String _secureCommonKey = "_bcheckin_secure_key";

  // ----------------------------------------------------------------------
  // =========== SUPPORT FUNCTIONS ===========
  // ----------------------------------------------------------------------

  static Future<String> _getAppDocumentPath() async {
    Directory appDocument = await getApplicationDocumentsDirectory();
    return appDocument.path + "/hive_data";
  }

  static Future<void> _storeSecureKey(String secureKey) async {
    var containsEncryptionKey =
    await _secureStorage?.containsKey(key: secureKey);
    if (containsEncryptionKey == false) {
      var secureRecordKey = Hive.generateSecureKey();
      await _secureStorage?.write(
        key: secureKey,
        value: base64UrlEncode(secureRecordKey),
      );
    }
  }

  static Future<Uint8List> _getSecureKey(String secureKey) async {
    var result = await _secureStorage?.read(key: secureKey);
    if (checkStringNullOrEmpty(result)) {
      await initialize();
      result = await _secureStorage?.read(key: secureKey);
    }
    return base64Url.decode(result!);
  }

  // ----------------------------------------------------------------------
  // =========== CRUCIAL FUNCTIONS ===========
  // ----------------------------------------------------------------------

  static Future<void> initialize() async {
    if (_secureStorage != null) {
      return;
    }
    _secureStorage = const FlutterSecureStorage();
    await _storeSecureKey(_secureCommonKey);

    String path = await _getAppDocumentPath();
    Hive.init(path);
  }

  static void deleteAll() {
    _secureStorage?.deleteAll();
    Hive.deleteBoxFromDisk(_boxCommonName);
    Hive.deleteFromDisk();
  }

  static void closeAllBoxes() {
    Hive.close();
  }

  static Future<void> deleteAllData(List<String> keys) async {
    if (keys.isEmpty) {
      throw UnsupportedError('[HIVE_MANAGER] Invalid keys');
    }

    var encryptKey = await _getSecureKey(_secureCommonKey);
    Box box = await Hive.openBox(
      _boxCommonName,
      encryptionCipher: HiveAesCipher(encryptKey),
    );
    return box.deleteAll(keys);
  }

  static Future<void> deleteData(String key) async {
    if (key.isEmpty) {
      throw UnsupportedError('[HIVE_MANAGER] Invalid key');
    }

    var encryptKey = await _getSecureKey(_secureCommonKey);
    Box box = await Hive.openBox(
      _boxCommonName,
      encryptionCipher: HiveAesCipher(encryptKey),
    );
    return box.delete(key);
  }

  static Future<void> setData(String key, dynamic value) async {
    if (key.isEmpty) {
      throw UnsupportedError('[HIVE_MANAGER] Invalid key');
    }

    var encryptKey = await _getSecureKey(_secureCommonKey);
    Box box = await Hive.openBox(
      _boxCommonName,
      encryptionCipher: HiveAesCipher(encryptKey),
    );
    await box.put(key, value);
  }

  static Future<dynamic> getData(String key) async {
    if (key.isEmpty) {
      throw UnsupportedError('[HIVE_MANAGER] Invalid key');
    }

    var encryptKey = await _getSecureKey(_secureCommonKey);
    Box box = await Hive.openBox(
      _boxCommonName,
      encryptionCipher: HiveAesCipher(encryptKey),
    );
    return box.get(key);
  }

  // ----------------------------------------------------------------------
  // =========== PUBLIC KEY OF HIVE-MANAGER ===========
  // ----------------------------------------------------------------------

  static const keyUser = "key_user";
  static const String keyAppLanguage = "_app_language";
  static const String keyNotificationStatus = "_notification_status";
  static const String keyUserToken = "_user_token";
  static const String keyLastNotificationId = "_last_notification_id";
  static const String keyNotificationListStatus = "_notification_list_status";
  static const String keyUserRoleIndex = "_user_role_index";
  static const String keyRecentUsername = "recent_username";
  static const String keyShippingOrderImages = "_shipping_order_images";

  // ----------------------------------------------------------------------
  // =========== SPECIFIC FUNCTIONS ===========
  // ----------------------------------------------------------------------

  static Future<void> cleanData() async {
    if (await getCurrentUser() != null) {
      await deleteCurrentUser();
    }

    if (await getSelectedLanguageInfo() != null) {
      await deleteSelectedLanguageInfo();
    }

    if (await getNotificationStatus() != null) {
      await deleteNotificationStatus();
    }

    if (await getUserToken() != null) {
      await deleteUserToken();
    }

    if (await getLastNotificationId() != null) {
      await deleteLastNotificationId();
    }

    if (await getNotificationReadStatus() != null) {
      await deleteNotificationReadStatus();
    }

    if (await getShippingOrderImages() != null) {
      await deleteShippingOrderImages();
    }
  }

  // User profile
  static Future<void> setCurrentUser(String jsonProfile) async {
    String? _curJsonProfile = await getData(keyUser);

    if (checkStringNullOrEmpty(_curJsonProfile) ||
        _curJsonProfile != jsonProfile) {
      await setData(keyUser, jsonProfile);
    }
  }

  static Future<MUser?> getCurrentUser() async {
    String? _jsonProfile = await getData(keyUser);

    if (!checkStringNullOrEmpty(_jsonProfile)) {
      return MUser.fromJson(jsonDecode(_jsonProfile!));
    }

    return null;
  }

  static Future<void> deleteCurrentUser() async {
    await deleteData(keyUser);
  }

  // Language info
  static Future<void> setSelectedLanguageInfo(String lang) async {
    String? _lang = await getData(keyAppLanguage);

    if (checkStringNullOrEmpty(_lang) ||
        _lang != lang) {
      await setData(keyAppLanguage, _lang);
    }
  }

  static Future<String?> getSelectedLanguageInfo() async {
    String? _jsonInfo = await getData(keyAppLanguage);
    return _jsonInfo;
  }

  static Future<void> deleteSelectedLanguageInfo() async {
    await deleteData(keyAppLanguage);
  }

  static Future<String?> getRecentUsername() async {
    String? _jsonInfo = await getData(keyRecentUsername);
    return _jsonInfo;
  }

  static Future<void> setRecentUsername(String username) async {
    await setData(keyRecentUsername, username);
  }

  // Notification status
  static Future<void> setNotificationStatus(bool shouldShow) async {
    await setData(keyNotificationStatus, shouldShow);
  }

  static Future<bool?> getNotificationStatus() async {
    return await getData(keyNotificationStatus);
  }

  static Future<void> deleteNotificationStatus() async {
    await deleteData(keyNotificationStatus);
  }

  // User token
  static Future<void> setUserToken(String userToken) async {
    await setData(keyUserToken, userToken);
  }

  static Future<String?> getUserToken() async {
    return await getData(keyUserToken);
  }

  static Future<void> deleteUserToken() async {
    await deleteData(keyUserToken);
  }

  // Last notification id
  static Future<void> setLastNotificationId(String notiId) async {
    await setData(keyLastNotificationId, notiId);
  }

  static Future<String?> getLastNotificationId() async {
    return await getData(keyLastNotificationId);
  }

  static Future<void> deleteLastNotificationId() async {
    await deleteData(keyLastNotificationId);
  }

  // Notification list read status
  static Future<void> setNotificationReadStatus(Map<String, bool> notiMap) async {
    await setData(keyNotificationListStatus, notiMap);
  }

  static Future<Map<String, bool>?> getNotificationReadStatus() async {
    Map<dynamic, dynamic>? result = await getData(keyNotificationListStatus);
    if (result != null) return Map<String, bool>.from(result);
    return null;
  }

  static Future<void> deleteNotificationReadStatus() async {
    await deleteData(keyNotificationListStatus);
  }

  // User role index
  static Future<void> setUserRoleIndex(int userRoleIndex) async {
    await setData(keyUserRoleIndex, userRoleIndex);
  }

  static Future<int?> getUserRoleIndex() async {
    return await getData(keyUserRoleIndex);
  }

  static Future<void> deleteUserRoleIndex() async {
    await deleteData(keyUserRoleIndex);
  }

  // Shipping order images
  static Future<void> setShippingOrderImages(String images) async {
    await setData(keyShippingOrderImages, images);
  }

  static Future<Map<String, dynamic>?> getShippingOrderImages() async {
    Map<dynamic, dynamic>? result = await getData(keyShippingOrderImages);
    if (result != null) return Map<String, dynamic>.from(result);
    return null;
  }

  static Future<void> deleteShippingOrderImages() async {
    await deleteData(keyShippingOrderImages);
  }
}