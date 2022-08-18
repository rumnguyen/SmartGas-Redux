// ================ PRIVATE VARIABLES ================

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:anpha_petrol_smartgas/core/code_definition.dart';
import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/network/server_endpoint.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/system_feature.dart';
import 'package:anpha_petrol_smartgas/core/utils/location_detector.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/main.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_alert_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

String _systemCode = "";

// ================ MAIN ================

Future<void> initializeConfigs(BuildContext context) async {
  // GlobalManager.nfcReadType = ReadType.TagIdOnly;
  await HiveManager.initialize();
  GlobalManager.initAppRatio(context);
  LocationDetector.instance.initialize();
  // await DbManager.initialize();
  // await SharedPrefManager.initialize();
  await GlobalManager.initPackageAndDeviceInfo();
  initPushNotificationsStatus();
  // await GlobalManager.initAllBitmapMarkerIcon();
  RUser.initializeSharedPrefUser();
}

void initPushNotificationsStatus() async {
  bool? notiStatus = await HiveManager.getNotificationStatus();
  if (notiStatus == null) {
    await HiveManager.setNotificationStatus(true);
  }
}

Future<void> initializeCrashlytics({bool enableInDevMode = false}) async {
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(enableInDevMode);
  /**
   * Catch errors that happen inside Flutter context
   * */
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  /**
   * Catch errors that happen outside Flutter context
   * */
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStackTrace = pair;
      await FirebaseCrashlytics.instance
          .recordError(errorAndStackTrace.first, errorAndStackTrace.last);
    }).sendPort,
  );
}

Future<String?> getSelectedLanguage() async {
  return await HiveManager.getSelectedLanguageInfo();
}

void initDefaultLocale(String lang) {
  switch (lang) {
    case "en":
      Intl.defaultLocale = "en_US";
      break;
    case "vi":
    default:
      Intl.defaultLocale = "vi_VN";
  }
}

void showLog({
  required String msg,
  Level logLevel = Level.debug,
  bool skipLog = true,
}) {
  if (skipLog) return;
  switch (logLevel) {
    case Level.debug:
      GlobalManager.logger.d(msg);
      break;
    case Level.info:
      GlobalManager.logger.i(msg);
      break;
    case Level.error:
      GlobalManager.logger.e(msg);
      break;
    case Level.warning:
      GlobalManager.logger.w(msg);
      break;
    case Level.verbose:
      GlobalManager.logger.v(msg);
      break;
    default:
      GlobalManager.logger.wtf(msg);
      break;
  }
}

void setSystemCode(String sysCode) {
  _systemCode = sysCode;
}

bool _checkSystemStatus() {
  /*
    + True: It's fine
    + False: Not fine
  */

  if (_systemCode.isEmpty || _systemCode == LOG_OUT) return true;

  String? message;
  switch (_systemCode) {
    case MAINTENANCE:
      message = GlobalManager.strings.errorMessages?[MAINTENANCE];
      break;
    case ACCESS_DENY:
      message = GlobalManager.strings.errorMessages?[ACCESS_DENY];
      break;
    case FORCE_UPDATE:
      message = GlobalManager.strings.errorMessages?[FORCE_UPDATE];
      break;
    default:
      message = GlobalManager.strings.errorOccurred;
  }

  void _exitApp() {
    if (_systemCode == MAINTENANCE) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      });
    }
  }

  showCustomAlertDialog(
    navigatorKey.currentState!.overlay!.context,
    title: GlobalManager.strings.caution,
    content: message,
    firstButtonText: GlobalManager.strings.ok?.toUpperCase(),
    firstButtonFunction: () {
      pop(navigatorKey.currentState!.overlay!.context);
      _exitApp();
    },
  );

  return false;
}

void restartApp(String? sysCode) {
  if (sysCode == null) return;
  if (sysCode.isEmpty || sysCode.compareTo(_systemCode) != 0) {
    setSystemCode(sysCode);
    SmartGasApp.restartApp(sysCode);
    setSystemCode("");
  }
}

Future<void> loadCurrentLanguage() async {
  String lang = "vi";

  String? appLang = await HiveManager.getSelectedLanguageInfo();
  if (appLang != null) {
    lang = appLang;
  } else {
    HiveManager.setSelectedLanguageInfo(lang);
  }

  initDefaultLocale(lang);

  String jsonContent =
      await rootBundle.loadString("assets/localization/$lang.json");
  GlobalManager.initLocalization(lang, jsonContent);
}

Future<void> setLanguage(String? lang) async {
  if (lang == null || lang.isEmpty) {
    throw Exception("The param of setLanguage function mustn't be null");
  }

  // SharedPrefManager.setData(R.sharedPrefKey.selectedLanguageFirstTimeKey, true);
  HiveManager.setSelectedLanguageInfo(lang);

  initDefaultLocale(lang);

  String jsonContent =
      await rootBundle.loadString("assets/localization/$lang.json");
  GlobalManager.initLocalization(lang, jsonContent);
}

Future<void> initAppRoleAndEndpoint({
  AppRole? appRole,
}) async {
  // if (appRole == null) {
  //   int appRoleIndex = await HiveManager.getUserRoleIndex() ?? 0;
  //   GlobalManager.currentAppRoleIndex = appRoleIndex;
  //   appRole = getAppRoleTypeFromIndex(appRoleIndex);
  //   if (appRole == null) {
  //     HiveManager.cleanData();
  //     restartApp("");
  //     return;
  //   }
  // } else {
  //   int appRoleIndex = appRole.index;
  //   GlobalManager.currentAppRoleIndex = appRoleIndex;
  //   await HiveManager.setUserRoleIndex(appRoleIndex);
  // }
  ServerEndpoint();
  await RUser.getPermissionList();
  SystemFeatureUtils();
  NotificationUtils.initFirebaseToken();
}

Future<List<int>> extractFile(String filePath, {int? maxFileSize}) async {
  var fileUri = Uri.parse(filePath);

  var _fileAsByte = await File.fromUri(fileUri).readAsBytes();

  // Handle resize file[] bytes;
  if (maxFileSize != null &&
      maxFileSize >= 10000 &&
      _fileAsByte.lengthInBytes > maxFileSize) {
    var quality = ((maxFileSize / _fileAsByte.lengthInBytes) * 100).round();
    _fileAsByte = await FlutterImageCompress.compressWithList(_fileAsByte,
        quality: quality);
  }

  return _fileAsByte;
}

int hexaStringColorToInt(String hexaStringColor) {
  if (!hexaStringColor.startsWith("#")) {
    return 0xFF223771;
  } else {
    hexaStringColor = hexaStringColor.substring(1);
    hexaStringColor = "0xFF" + hexaStringColor;
    return int.parse(hexaStringColor);
  }
}

// ================ NAVIGATOR ================

Future<T?>? showPage<T>(BuildContext context, Widget page,
    {bool popUntilFirstRoutes = false}) {
  if (!_checkSystemStatus()) return null;
  if (popUntilFirstRoutes) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  Route<T> route = MaterialPageRoute(builder: (context) => page);
  return Navigator.of(context).pushReplacement(route);
}

Future<T?>? showPageWithRoute<T>(BuildContext context, Route<T> route,
    {bool popUntilFirstRoutes = false}) {
  if (!_checkSystemStatus()) return null;
  if (popUntilFirstRoutes) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  return Navigator.of(context).pushReplacement(route);
}

Future<T?>? pushPageWithNavState<T>(Widget page) {
  Route<T> route = MaterialPageRoute(builder: (_) => page);
  return navigatorKey.currentState!.push(route);
}

Future<T?>? pushPage<T>(BuildContext context, Widget page) {
  if (!_checkSystemStatus()) return null;
  Route<T> route = MaterialPageRoute(builder: (context) => page);
  return Navigator.of(context).push(route);
}

Future<T?>? pushPageWithRoute<T>(BuildContext context, Route<T> route) {
  if (!_checkSystemStatus()) return null;
  return Navigator.of(context).push(route);
}

void pop(BuildContext context, {bool rootNavigator = false, dynamic object}) {
  // if (rootNavigator == null) rootNavigator = false;
  if (Navigator.of(context).canPop()) {
    Navigator.of(context, rootNavigator: rootNavigator).pop(object);
  }
}

// Generates a cryptographically secure random nonce, to be included in a
// credential request.
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

// Returns the sha256 hash of [input] in hex notation.
// String sha256ofString(String input) {
//   final bytes = utf8.encode(input);
//   final digest = sha256.convert(bytes);
//   return digest.toString();
// }

// Check iOS version >= target
bool checkIOSVersionMatchMinimumTarget(int target) {
  if (!Platform.isIOS) return false;
  String deviceOS = GlobalManager.deviceOS;
  List<String> splitString = deviceOS.split(".");
  if (checkListIsNullOrEmpty(splitString)) return false;
  String first = splitString.first;
  int version = int.tryParse(first) ?? 0;
  return version >= target;
}

Map<int, Color> rgbToMaterialColor(int r, int g, int b) {
  return {
    50: Color.fromRGBO(r, g, b, .1),
    100: Color.fromRGBO(r, g, b, .2),
    200: Color.fromRGBO(r, g, b, .3),
    300: Color.fromRGBO(r, g, b, .4),
    400: Color.fromRGBO(r, g, b, .5),
    500: Color.fromRGBO(r, g, b, .6),
    600: Color.fromRGBO(r, g, b, .7),
    700: Color.fromRGBO(r, g, b, .8),
    800: Color.fromRGBO(r, g, b, .9),
    900: Color.fromRGBO(r, g, b, 1),
  };
}

void callPhoneDirectly(BuildContext context, String? phoneNumber) async {
  if (checkStringNullOrEmpty(phoneNumber)) return;
  String desc = GlobalManager.strings.callPhoneAsk!;
  showCustomAlertDialog(
    context,
    title: GlobalManager.strings.confirm,
    content: desc,
    highlightContent: '$phoneNumber?',
    contentAlign: TextAlign.center,
    firstButtonText: GlobalManager.strings.ok,
    firstButtonFunction: () async {
      pop(context);
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber!);
      printDefault('res $res');
    },
    secondButtonText: GlobalManager.strings.discard,
    secondButtonFunction: () => pop(context),
  );
}
