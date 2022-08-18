import 'dart:convert';
import 'dart:io';

import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/m_payment_method.dart';
import 'package:anpha_petrol_smartgas/models/m_string.dart';
import 'package:anpha_petrol_smartgas/models/o_client_version.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';

class GlobalManager {
  static String applicationId = "com.rumnguyen.example.smartgas";

  static MString strings = MString();
  static _AppRatio appRatio = _AppRatio();
  static final _Colors colors = _Colors();
  static final _Constants constants = _Constants();
  static final _Images images = _Images();
  static final _Icons myIcons = _Icons();

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static _Styles styles = _Styles();
  static String currentAppLanguage = "vi";
  static int? currentAppRoleIndex;
  static PackageInfo? packageInfo;
  static ClientVersion? clientVersion;
  static bool isSuperStaff = false;
  static String modelName = "";
  static String deviceId = "";
  static String deviceOS = "";
  static Map<int, MPaymentMethod>? paymentMethodList;

  static final Map<String, String> _modelMapper = {
    "i386": "32-bit Simulator",
    "x86_64": "64-bit Simulator",

    // Output on an iPhone
    "iPhone1,1": "iPhone",
    "iPhone1,2": "iPhone 3G",
    "iPhone2,1": "iPhone 3GS",
    "iPhone3,1": "iPhone 4 (GSM)",
    "iPhone3,3": "iPhone 4 (CDMA/Verizon/Sprint)",
    "iPhone4,1": "iPhone 4S",
    "iPhone5,1": "iPhone 5 (model A1428, AT&T/Canada)",
    "iPhone5,2": "iPhone 5 (model A1429, everything else)",
    "iPhone5,3": "iPhone 5c (model A1456, A1532 | GSM)",
    "iPhone5,4":
    "iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)",
    "iPhone6,1": "iPhone 5s (model A1433, A1533 | GSM)",
    "iPhone6,2":
    "iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)",
    "iPhone7,1": "iPhone 6 Plus",
    "iPhone7,2": "iPhone 6",
    "iPhone8,1": "iPhone 6S",
    "iPhone8,2": "iPhone 6S Plus",
    "iPhone8,4": "iPhone SE",
    "iPhone9,1": "iPhone 7 (CDMA)",
    "iPhone9,3": "iPhone 7 (GSM)",
    "iPhone9,2": "iPhone 7 Plus (CDMA)",
    "iPhone9,4": "iPhone 7 Plus (GSM)",
    "iPhone10,1": "iPhone 8 (CDMA)",
    "iPhone10,4": "iPhone 8 (GSM)",
    "iPhone10,2": "iPhone 8 Plus (CDMA)",
    "iPhone10,5": "iPhone 8 Plus (GSM)",
    "iPhone10,3": "iPhone X (CDMA)",
    "iPhone10,6": "iPhone X (GSM)",
    "iPhone11,2": "iPhone XS",
    "iPhone11,4": "iPhone XS Max",
    "iPhone11,6": "iPhone XS Max China",
    "iPhone11,8": "iPhone XR",
    "iPhone12,1": "iPhone 11",
    "iPhone12,3": "iPhone 11 Pro",
    "iPhone12,5": "iPhone 11 Pro Max",
    "iPhone12,8": "iPhone SE 2nd Gen",
    "iPhone13,1": "iPhone 12 Mini",
    "iPhone13,2": "iPhone 12",
    "iPhone13,3": "iPhone 12 Pro",
    "iPhone13,4": "iPhone 12 Pro Max",

    //iPad 1
    "iPad1,1": "iPad - Wifi (model A1219)",
    "iPad1,2": "iPad - Wifi + Cellular (model A1337)",

    //iPad 2
    "iPad2,1": "Wifi (model A1395)",
    "iPad2,2": "GSM (model A1396)",
    "iPad2,3": "3G (model A1397)",
    "iPad2,4": "Wifi (model A1395)",

    // iPad Mini
    "iPad2,5": "Wifi (model A1432)",
    "iPad2,6": "Wifi + Cellular (model  A1454)",
    "iPad2,7": "Wifi + Cellular (model  A1455)",

    //iPad 3
    "iPad3,1": "Wifi (model A1416)",
    "iPad3,2": "Wifi + Cellular (model  A1403)",
    "iPad3,3": "Wifi + Cellular (model  A1430)",

    //iPad 4
    "iPad3,4": "Wifi (model A1458)",
    "iPad3,5": "Wifi + Cellular (model  A1459)",
    "iPad3,6": "Wifi + Cellular (model  A1460)",

    //iPad AIR
    "iPad4,1": "Wifi (model A1474)",
    "iPad4,2": "Wifi + Cellular (model A1475)",
    "iPad4,3": "Wifi + Cellular (model A1476)",

    // iPad Mini 2
    "iPad4,4": "Wifi (model A1489)",
    "iPad4,5": "Wifi + Cellular (model A1490)",
    "iPad4,6": "Wifi + Cellular (model A1491)",

    // iPad Mini 3
    "iPad4,7": "Wifi (model A1599)",
    "iPad4,8": "Wifi + Cellular (model A1600)",
    "iPad4,9": "Wifi + Cellular (model A1601)",

    // iPad Mini 4
    "iPad5,1": "Wifi (model A1538)",
    "iPad5,2": "Wifi + Cellular (model A1550)",

    //iPad AIR 2
    "iPad5,3": "Wifi (model A1566)",
    "iPad5,4": "Wifi + Cellular (model A1567)",

    // iPad PRO 9.7"
    "iPad6,3": "Wifi (model A1673)",
    "iPad6,4": "Wifi + Cellular (model A1674)",
    "iPad6,5": "Wifi + Cellular (model A1675)",

    //iPad PRO 12.9"
    "iPad6,7": "Wifi (model A1584)",
    "iPad6,8": "Wifi + Cellular (model A1652)",

    //iPad (5th generation)
    "iPad6,11": "Wifi (model A1822)",
    "iPad6,12": "Wifi + Cellular (model A1823)",

    //iPad PRO 12.9" (2nd Gen)
    "iPad7,1": "Wifi (model A1670)",
    "iPad7,2": "Wifi + Cellular (model A1671)",
    "iPad7,3": "Wifi + Cellular (model A1821)",

    //iPad PRO 10.5"
    "iPad7,4": "Wifi (model A1701)",
    "iPad7,5": "Wifi + Cellular (model A1709)",

    //iPod Touch
    "iPod1,1": "iPod Touch",
    "iPod2,1": "iPod Touch Second Generation",
    "iPod3,1": "iPod Touch Third Generation",
    "iPod4,1": "iPod Touch Fourth Generation",
    "iPod7,1": "iPod Touch 6th Generation",

    // Apple Watch
    "Watch1,1": "Apple Watch 38mm case",
    "Watch1,2": "Apple Watch 38mm case",
    "Watch2,6": "Apple Watch Series 1 38mm case",
    "Watch2,7": "Apple Watch Series 1 42mm case",
    "Watch2,3": "Apple Watch Series 2 38mm case",
    "Watch2,4": "Apple Watch Series 2 42mm case",
    "Watch3,1": "Apple Watch Series 3 38mm case (GPS+Cellular)",
    "Watch3,2": "Apple Watch Series 3 42mm case (GPS+Cellular)",
    "Watch3,3": "Apple Watch Series 3 38mm case (GPS)",
    "Watch3,4": "Apple Watch Series 3 42mm case (GPS)",
    "Watch4,1": "Apple Watch Series 4 40mm case (GPS)",
    "Watch4,2": "Apple Watch Series 4 44mm case (GPS)",
    "Watch4,3": "Apple Watch Series 4 40mm case (GPS+Cellular)",
    "Watch4,4": "Apple Watch Series 4 44mm case (GPS+Cellular)"
  };

  static final Logger logger = Logger(
    printer: PrettyPrinter(
      errorMethodCount: 8,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: false,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false,
      // Should each log print contain a timestamp
    ),
  );

  static void initLocalization(String lang, String jsonContent) {
    currentAppLanguage = lang;
    if (!checkStringNullOrEmpty(jsonContent)) {
      GlobalManager.strings = MString.fromJson(json.decode(jsonContent));
    }
  }

  static Future<void> initPackageAndDeviceInfo() async {
    packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      clientVersion = ClientVersion(
        platformIndex: PlatformType.Android.index,
        versionCode: packageInfo?.buildNumber,
        versionName: packageInfo?.version,
      );

      var androidInfo = await deviceInfoPlugin.androidInfo;
      modelName =
      "${androidInfo.manufacturer.toUpperCase()} ${androidInfo.model}";
      deviceId = androidInfo.androidId;
      deviceOS = androidInfo.version.release;
      // currentAndroidSdkInt = androidInfo.version.sdkInt;
    } else if (Platform.isIOS) {
      clientVersion = ClientVersion(
        platformIndex: PlatformType.iOS.index,
        versionCode: packageInfo?.buildNumber,
        versionName: packageInfo?.version,
      );

      var iOSInfo = await deviceInfoPlugin.iosInfo;
      modelName = _modelMapper[iOSInfo.utsname.machine] ?? "";
      deviceId = iOSInfo.identifierForVendor;
      deviceOS = iOSInfo.systemVersion;
    }
  }

  static void initAppRatio(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    appRatio.setUpAppRatio(
      size.width,
      size.height,
      devicePixelRatio,
      textScaleFactor,
      statusBarHeight,
    );
  }

  // static AppRole? getAppRole() => getAppRoleTypeFromIndex(currentAppRoleIndex);
}

class _Constants {
  final int chunkSizeInitLocalMapData = 100;
  final double mapRotationDurationSeconds = 0.5;
  final int countdownDurationSeconds = 60;
  final int getObjectStatusDurationSeconds = 5;
  final int getStudentListDurationSeconds = 4;
  final int warnStaffStudentComeHomeDurationSeconds = 10;

  final String schoolMarkerMetaKey = "schoolMarker";
  final String vehicleMarkerMetaKey = "vehicleMarker";
  final String vehicleBearingMarkerMetaKey = "vehicleBearingMarker";
  final String studentMarkerMetaKey = "studentMarker";
  final String stationMarkerMetaKey = "stationMarker";

  final String shouldReloadScreenKey = "_should_reload_screen";
  final String dateEmpty = "01/01/0001";

  // Log events
  final String eventLocationSharingAction = "action_location_sharing";
  final String eventStopLocationSharingAction = "action_stop_location_sharing";
  final String eventSeeVehicleOnMapAction = "vehicle_on_map";
  final String eventNfcChangeStudentStatusAction =
      "action_nfc_change_student_status";
  final String eventChangeStudentStatusManuallyAction =
      "action_change_student_status";
  final String eventChangeVehicleStatusAction = "action_change_vehicle_status";
  final String eventRestartServiceAfterDestroyedNotByStaff =
      "action_restart_location_sharing";
  final String eventRestartLocationSharingErrorAction =
      "action_stop_location_sharing_error";

  // todo: need to update prefix key
  final String checkInQRCodePrefixKey = 'D';
  final String bmsQRCodePrefixKey = 'C';

  // bms
  final String routeStationMarkerMetaKey = "routeStationMarker";
  final String routeStationMiniMarkerMetaKey = "routeStationMiniMarker";
  final String routePathLineMetaKey = "routePathLineMetaKey";
}

class _AppRatio {
  double? deviceWidth;
  double? deviceHeight;
  double? devicePixelRatio;
  double? textScaleFactor;
  double? statusBarHeight;
  double? appBarHeight;

  void setUpAppRatio(double deviceWidth, double deviceHeight,
      double devicePixelRatio, double textScaleFactor, double statusBarHeight) {
    this.deviceWidth = deviceWidth.roundToDouble();
    this.deviceHeight = deviceHeight.roundToDouble();
    this.devicePixelRatio = devicePixelRatio.roundToDouble();
    this.textScaleFactor = textScaleFactor.roundToDouble();
    this.statusBarHeight = statusBarHeight.roundToDouble();
    appBarHeight = AppBar().preferredSize.height;
  }
}

class _Colors {
  // Major color
  Color _majorColor = const Color(0xFF00923f);

  Color majorColor({double opacity = 1.0}) {
    return _majorColor.withOpacity(opacity);
  }

  void setMajorColor(Color color) {
    _majorColor = color;
  }

  // Gray colors
  Color grayABABAB = const Color(0xFFABABAB);
  Color gray808080 = const Color(0xFF808080);
  Color grayF0F0F0 = const Color(0xFFF0F0F0);
  Color gray586575 = const Color(0xFF586575);
  Color grayF2F2F2 = const Color(0xFFF2F2F2);
  Color grayD5D5D5 = const Color(0xFFD5D5D5);
  Color grayCCCCCC = const Color(0xFFCCCCCC);
  Color grayF1F1F1 = const Color(0xFFF1F1F1);
  Color gray5F5F5F = const Color(0xFF5F5F5F);
  Color redF0284a = const Color(0xFFf0284a);
  Color gray636E72 = const Color(0xff636e72);
  Color grayE5E5E5 = const Color(0xFFE5E5E5);

  // Background colors
  Color bgWhite = const Color(0xFFFFFFFF);
  Color bgLightGray = const Color(0xFFDEDEDE);
  Color bgLightGreyF5F6F8 = const Color(0xffF5F6F8);
  Color bgMajor = const Color(0xFFF5F8FF);
  Color bgGrayFDFDFD = const Color(0xFFFDFDFD);

  // Other common colors
  Color colorAccent = const Color(0xFFFE0100);
  Color normalGreen = const Color(0xFF5D9547);
  Color leftIconColor = const Color(0xFF636E72);
  Color black333333 = const Color(0xFF333333);
  Color redFF0000 = const Color(0xFFFF0000);
  Color grayEFEFEF = const Color(0xFFEFEFEF);
  Color grayE6E6E6 = const Color(0xFFE6E6E6);
  Color blue0984E3 = const Color(0xFF0984E3);
  Color redE74C3C = const Color(0xFFE74C3C);
  Color grayFCFCFC = const Color(0xffFCFCFC);
  Color blueGray = const Color(0xFF8998AC);
  Color black2C394B = const Color(0XFF2C394B);
  Color black334756 = const Color(0XFF334756);
  Color blue4178D4 = const Color(0xFF4178D4);
  Color blue005082 = const Color(0xFF005082);
  Color orangeFF9234 = const Color(0xFFFF9234);
  Color gray64748B = const Color(0xff64748B);
  Color grayAEAEB2 = const Color(0xffAEAEB2);
  Color black3D4B5E = const Color(0xFF3D4B5E);
  Color green03C60D = const Color(0xFF03C60D);
  Color redC80401 = const Color(0xFFC80401);
  Color yellowFCB641 = const Color(0xFFFCB641);
  Color neutralGrey2 = const Color(0xff3D4B5E);
  Color gray8E8E93 = const Color(0xff8E8E93);
  Color grayFFB5B4B4 = const Color(0xFFB5B4B4);
  Color orangeDB6E27 = const Color(0xFFDB6E27);
  Color grayD1D1D6 = const Color(0xffD1D1D6);
  Color gray44494D = const Color(0xff44494D);
  Color grayBBBFCA = const Color(0xffBBBFCA);
  Color blue476EFE = const Color(0xff476EFE);
  Color green22CC9C = const Color(0xff22CC9C);
  Color redFF6951 = const Color(0xffFF6951);
  Color orangeFCAD2D = const Color(0xffFCAD2D);
  Color blue25373f = const Color(0xff25373f);
  Color green56C38F = const Color(0xff56C38F);
  Color greenADEACD = const Color(0xffADEACD);
  Color redEC1E37 = const Color(0xffEC1E37);
  Color purpleC490E4 = const Color(0xffC490E4);
  Color grayE8E8E8 = const Color(0xFFE8E8E8);
  Color blue4DC4FF = const Color(0xFF4DC4FF);
  Color blue323668 = const Color(0xFF323668);
  Color orangeFFB454 = const Color(0xFFFFB454);
  Color blue32B0E2 = const Color(0xFF32B0E2);
  Color grayF5F5F8 = const Color(0xFFF5F5F8);
  Color gray888889 = const Color(0xFF888889);
  Color grayCDCDCD = const Color(0xFFCDCDCD);
  Color grayE9E9E9 = const Color(0xFFE9E9E9);
  Color black052525 = const Color(0xFF052525);
  Color blue3E9AF6 = const Color(0xff3E9AF6);
  Color yellowEAB625 = const Color(0xFFEAB625);
  Color yellowFDDF8D = const Color(0xFFFDDF8D);
  Color grayF1F2F2 = const Color(0xffF1F2F2);
  Color grayCBD5E1 = const Color(0XFFCBD5E1);
  Color grayE6E5EE = const Color(0XFFE6E5EE);
  Color yellowF9EFB7 = const Color(0XFFF9EFB7);
  Color greenDCF0EC = const Color(0XFFDCF0EC);
  Color grayD0D0D0 = const Color(0XFFD0D0D0);
  Color purpleDCD9EE = const Color(0XFFDCD9EE);
  Color purple5243AA = const Color(0XFF5243AA);
  Color grayCAC1C1 = const Color(0XFFCAC1C1);
  Color grayD9D9D9 = const Color(0XFFD9D9D9);
  Color redF8576A = const Color(0XFFF8576A);
  Color orangeFFAA20 = const Color(0XFFFFAA20);
  Color green54B670 = const Color(0XFF54B670);
  Color orangeF8E4D3 = const Color(0XFFF8E4D3);
  Color grayEFF2F7 = const Color(0XFFEFF2F7);
  Color grayC7C7CC = const Color(0XffC7C7CC);
  Color orangeFFD591 = const Color(0xffFFD591);
  Color orangeFFF7E6 = const Color(0xffFFF7E6);
  Color blue91D5FF = const Color(0xff91D5FF);
  Color blueE6F7FF = const Color(0xffE6F7FF);
  Color brownD46B08 = const Color(0xffD46B08);
  Color blue096DD9 = const Color(0xff096DD9);
  Color blue1F78F2 = const Color(0xff1F78F2);
  Color greenDDF9DC = const Color(0xffDDF9DC);
  Color green32BEA6 = const Color(0xff32BEA6);
  Color grayF5F8FC = const Color(0XffF5F8FC);
  Color green58B3541 = const Color(0xff58B354);
  Color grayB5B4B4 = const Color(0XffB5B4B4);
}

class _Icons {
  final String englishColor = 'assets/icons/en.png';
  final String vietnameseColor = 'assets/icons/vn.png';

  final String fiveStarsColor = 'assets/icons/icon-5stars-color.png';
  final String adminColor = 'assets/icons/icon-admin-color.png';
  final String notificationColor = 'assets/icons/icon-notifications-color.svg';
  final String homeGray = 'assets/icons/icon-home-gray.png';
  final String homeOrange = 'assets/icons/icon-home-orange.png';
  final String chatGray = 'assets/icons/icon-chat-gray.png';
  final String chatOrange = 'assets/icons/icon-chat-orange.png';
  final String settingsGray = 'assets/icons/icon-settings-gray.png';
  final String settingsOrange = 'assets/icons/icon-settings-orange.png';
  final String languageColor = 'assets/icons/icon-language-color.png';
  final String checkedAllWhite = 'assets/icons/icon-checked-all.png';
  final String infoColor = 'assets/icons/icon-info-color.svg';
  final String qrColor = 'assets/icons/icon-scan-color.png';
  final String calendarColor = 'assets/icons/icon-calendar-color.png';
  final String gpsColor = 'assets/icons/icon-gps-color.png';
  final String nfcCardBlack = 'assets/icons/icon-nfc-card-black.png';
  final String newsGray = 'assets/icons/icon-news-gray.png';
  final String newsOrange = 'assets/icons/icon-news-color.png';
  final String newVersionColor = 'assets/icons/icon-new-version-color.png';
  final String cameraGray = 'assets/icons/icon-camera-gray.png';
  final String feedbackColor = 'assets/icons/icon-feedback-color.png';
  final String contactColor = 'assets/icons/icon-contact-color.png';

  // Svg
  final String svgChatOutlined =
      'assets/icons/bottom_nav/icon_chat_outlined.svg';
  final String svgChatSolid = 'assets/icons/bottom_nav/icon_chat_solid.svg';
  final String svgHomeOutlined =
      'assets/icons/bottom_nav/icon_home_outlined.svg';
  final String svgHomeSolid = 'assets/icons/bottom_nav/icon_home_solid.svg';
  final String svgNewsOutlined =
      'assets/icons/bottom_nav/icon_news_outlined.svg';
  final String svgNewsSolid = 'assets/icons/bottom_nav/icon_news_solid.svg';
  final String svgSettingOutlined =
      'assets/icons/bottom_nav/icon_setting_outlined.svg';
  final String svgSettingSolid =
      'assets/icons/bottom_nav/icon_setting_solid.svg';
  final String svgPersonalOutlined =
      'assets/icons/bottom_nav/icon_personal_outlined.svg';
  final String svgPersonalSolid =
      'assets/icons/bottom_nav/icon_personal_solid.svg';
  final String svgNotiOutlined =
      'assets/icons/bottom_nav/icon_noti_outlined.svg';
  final String svgNotiSolid = 'assets/icons/bottom_nav/icon_noti_solid.svg';
  final String svgSearchPeople = 'assets/icons/icon_search_people.svg';
  final String svgSearch = 'assets/icons/icon-search.svg';
  final String svgBags = 'assets/icons/icon_bags.svg';
  final String svgProfileUser = 'assets/icons/icon_user_default.svg';
  final String svgOfficeBuilding = 'assets/icons/icon_office_building.svg';
  final String logoSmartGas = 'assets/icons/logo-smart-gas-app.svg';
  final String svgHistory = 'assets/icons/icon_history.svg';
  final String svgDelivery = 'assets/icons/icon_delivery.svg';
  final String svgSetup2 = 'assets/icons/icon-setup.svg';
  final String svgBlock = 'assets/icons/lookup/icon_block.svg';
  final String svgCheckCircle = 'assets/icons/lookup/icon_check_circle.svg';
  final String svgClose = 'assets/icons/lookup/icon_close.svg';
  final String svgCloseCircle = 'assets/icons/lookup/icon_close_circle.svg';
  final String svgDropdown = 'assets/icons/lookup/icon_dropdown.svg';
  final String svgFilter = 'assets/icons/lookup/icon_filter.svg';
  final String svgRefresh = 'assets/icons/lookup/icon_refresh.svg';
  final String svgSetting = 'assets/icons/lookup/icon_setting.svg';
  final String svgCodeScan = 'assets/icons/icon_code_scan.svg';
  final String svgAddToCart = 'assets/icons/icon_add_to_cart.svg';

  final String svgMaintenance = 'assets/icons/icon_maintenance.svg';
  final String svgSetup = 'assets/icons/icon_setup.svg';
  final String svgSetupMaintain = 'assets/icons/icon_setup_maintain.svg';
  final String svgRevoke = 'assets/icons/icon_revoke.svg';
  final String svgError = 'assets/icons/icon_error.svg';
  final String svgWarning = 'assets/icons/icon_warning.svg';
  final String svgCheck = 'assets/icons/icon_check.svg';
  final String svgCheckStatus = 'assets/icons/icon_check_status.svg';
  final String svgInfo = 'assets/icons/icon_info.svg';
  final String svgChat = 'assets/icons/icon-chat.svg';
  final String svgSend = 'assets/icons/icon-send.svg';
  final String svgPhone = 'assets/icons/icon-phone.svg';
  final String svgCircle = 'assets/icons/icon-circle.svg';
  final String svgArrowLeftToRight =
      'assets/icons/icon_arrow_left_to_right.svg';
  final String svgImage = 'assets/icons/icon_image.svg';
  final String svgMoneyColor = 'assets/icons/icon-money-color.svg';
  final String svgCardPaymentColor = 'assets/icons/icon-card-payment.svg';
  final String svgMomo = "assets/icons/icon-momo.svg";
  final String svgVNPay = "assets/icons/icon-vnpay.svg";
  final String svgZaloPay = "assets/icons/icon-zalopay.svg";
  final String svgIconHistory = "assets/icons/icon-history.svg";
  final String svgIconHistoryDevice = "assets/icons/icon_history_device.svg";
  final String svgIconReport = "assets/icons/icon-business-report.svg";
  final String svgBag = "assets/icons/icon-bag.svg";
  final String svgDeliveryReport = "assets/icons/icon-delivery-report.svg";
  final String svgCalendarGray = "assets/icons/icon-calendar-gray.svg";
  final String svgAdmin = "assets/icons/icon_admin.svg";
}

class _Images {
  // bSmartCity logo images
  final String appLogo = 'assets/images/logo.png';
  final String logoHeading = 'assets/images/logo-heading.png';

  // Common images
  final String defaultImage = 'assets/images/default-image.png';
  final String defaultAvatar = 'assets/images/default-avatar.png';
  final String defaultCompanyBackground = 'assets/images/khuonviencongty.png';
  final String background = 'assets/images/background.png';
  final String newVersionImage = 'assets/images/new-version-img.png';
  final String profileBackground = 'assets/images/profile-bg.png';
  final String signInMethodBackground =
      'assets/images/background_signin_method_screen.png';
  final String bgHeader = "assets/images/bg_header.png";
  final String bgSignIn = "assets/images/bg-login.png";

  // Gif
  final String gifLoading = 'assets/images/loading1.gif';
  final String gifCircleLoading = 'assets/images/circle-loading.gif';
  final String gifSuccess = 'assets/images/success.gif';
  final String gifFail = 'assets/images/fail.gif';
  final String gifAnimationSignal = 'assets/images/animation_signal.gif';
  final String gifNfcScanning = 'assets/images/nfc_scan.gif';
  final String defaultEmployeeImage = 'assets/images/nhanvien.png';
  final String noDataColor = 'assets/images/no-data.png';

  // Onboarding images
  final String onboarding01 = 'assets/images/onboarding-01.png';
  final String onboarding02 = 'assets/images/onboarding-02.png';
  final String onboarding03 = 'assets/images/onboarding-03.png';
  final String onboarding04 = 'assets/images/onboarding-04.png';

  // Sign in images
  final String googleLogo = 'assets/images/google.png';
  final String accountIcon = 'assets/images/accountIcon.svg';
  final String mobileIcon = 'assets/images/mobileIcon.svg';

  final String defaultImagePlaceholder = 'assets/images/image-place-holder.png';
  final String emptyNotification = 'assets/images/empty_notification.svg';

  final String imageGallery = 'assets/images/image-gallery.svg';
  final String mbbank = 'assets/images/mbbank.png';
  final String vietcombank = 'assets/images/vietcombank.png';
}

class _Styles {
  final double bigSpacing = 16.0;
  final double bigSpacing2 = 24.0;
  final double mediumSpacing = 12.0;
  final double smallSpacing = 8.0;
  final double radius = 8.0;

  final BoxShadow containerShadow = BoxShadow(
    offset: const Offset(0, 2.0),
    blurRadius: 8.0,
    color: Colors.black.withOpacity(0.1),
  );

  final BoxShadow customBoxShadowRB = const BoxShadow(
    offset: Offset(2.0, 2.0),
    blurRadius: 3.0,
    color: Color.fromRGBO(33, 57, 112, 0.15),
  );

  final BoxShadow customBoxShadowAll = const BoxShadow(
    offset: Offset(0.0, 0.0),
    blurRadius: 3.0,
    color: Color.fromRGBO(33, 57, 112, 0.15),
  );

  final BoxShadow customBoxShadowSelectLanguages = const BoxShadow(
    offset: Offset(0.0, 0.0),
    blurRadius: 4.0,
    color: Color.fromRGBO(235, 235, 235, 1),
  );

  final BoxShadow customBoxShadowB = const BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 3.0,
    color: Color.fromRGBO(33, 57, 112, 0.15),
  );

  final BoxShadow customOrangeBoxShadowB = const BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 2.0,
    color: Color.fromRGBO(244, 121, 32, 0.3),
  );

  final BoxShadow customOrangeBoxShadowRB = const BoxShadow(
    offset: Offset(2.0, 2.0),
    blurRadius: 2.0,
    color: Color.fromRGBO(244, 121, 32, 0.3),
  );

  final BoxShadow customOrangeBoxShadowAll = const BoxShadow(
    offset: Offset(0.0, 0.0),
    blurRadius: 2.0,
    color: Color.fromRGBO(244, 121, 32, 0.3),
  );

  final TextStyle defaultTextStyle = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 15,
    color: Colors.black,
  );

  final ButtonStyle defaultTextButtonStyle = TextButton.styleFrom(
    textStyle: const TextStyle(color: Colors.white),
    primary: GlobalManager.colors.majorColor(),
    padding: const EdgeInsets.all(0),
  );

  final ButtonStyle defaultTextButtonStyleWithShape = TextButton.styleFrom(
    textStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.all(0),
    primary: GlobalManager.colors.majorColor(opacity: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      side: BorderSide(
        color: GlobalManager.colors.grayABABAB,
        width: 1,
      ),
    ),
  );

  ButtonStyle customBtnStyle(
      {TextStyle? textStyle,
        OutlinedBorder? shape,
        Color? overlayColor,
        Color? backgroundColor,
        EdgeInsets? padding}) {
    return ButtonStyle(
        textStyle: _handleToMaterialStateProperty<TextStyle?>(textStyle),
        shape: _handleToMaterialStateProperty<OutlinedBorder?>(shape),
        overlayColor: _handleToMaterialStateProperty<Color?>(overlayColor),
        padding: _handleToMaterialStateProperty<EdgeInsets?>(padding),
        backgroundColor:
        _handleToMaterialStateProperty<Color?>(backgroundColor));
  }

  MaterialStateProperty<T>? _handleToMaterialStateProperty<T>(T value) =>
      value != null ? MaterialStateProperty.all(value) : null;

}