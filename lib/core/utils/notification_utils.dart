import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anpha_petrol_smartgas/animations/slide_page_route.dart';
import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/main.dart';
import 'package:anpha_petrol_smartgas/models/m_notifications.dart';
import 'package:anpha_petrol_smartgas/pages/notifications/notification_detail.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/web_inapp_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationUtils {
  static const String GENERAL_CHANNEL_ID = "general_channel";
  static const String GENERAL_CHANNEL_NAME = "General";
  static const String GENERAL_CHANNEL_DESCRIPTION =
      "All general events from SmartGas";

  static Future<void> initFirebaseToken() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _updateNotification(message.notification, message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _updateNotification(message.notification, message.data, pushLocal: false);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        isAppRunning = false;
        _updateNotification(message.notification, message.data,
            pushLocal: false);
      }
    });

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
          sound: true, badge: true, alert: true, provisional: true);
    }

    bool? notifyStatus =
        await HiveManager.getNotificationStatus();
    String? userToken =
      await HiveManager.getUserToken();

    if (notifyStatus != null &&
        notifyStatus &&
        !checkStringNullOrEmpty(userToken)) {
      FirebaseMessaging.instance.getToken().then((String? token) {
        assert(token != null);
        showLog(
            msg:
                "firebase messaging token: $token, deviceId: ${GlobalManager.deviceId}, deviceModel: ${GlobalManager.modelName}",
            skipLog: false);
        var updateUserToken = RUser.updateUserToken({
          "token": token,
          "deviceModel": GlobalManager.modelName,
          "deviceId": GlobalManager.deviceId,
          "osVersion": GlobalManager.deviceOS,
        });
        showLog(
            msg:
                "update user token notifyStatus: $token success: $updateUserToken");
      });
    }
  }

  static Future<void> initializeLocalNotification() async {
    /**
     * Initialize local notification here
     * */
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_notification');
    // Note: permissions aren't requested here just to demonstrate that can be
    // done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class

    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        showLog(msg: "onDidReceiveLocalNotification()");
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      showLog(msg: "onSelectNotification() + $payload");
      if (checkStringNullOrEmpty(payload)) return;
      MNotifications notification =
          MNotifications.fromJson(json.decode(payload!));
      showLog(msg: "onSelectNotification() + handleNotifyItem()");
      handleNotifyItem(notification);
    });
  }

  static void _updateNotification(
      RemoteNotification? notifyItem, Map<String, dynamic> data,
      {bool pushLocal = true}) async {
    String? userToken =
        await HiveManager.getUserToken();
    if (checkMapIsNullOrEmpty(data) || checkStringNullOrEmpty(userToken)) {
      return;
    }
    MNotifications notificationItem = MNotifications(
      id: data['id'] == null ? 0 : (int.tryParse(data['id']) ?? 0),
      action: data["action"],
      payload: data["payload"],
      directAction: data["directAction"] == "1",
      title: notifyItem!.title,
      body: notifyItem.body,
      picture: data['image'],
    );
    List<MNotifications> items = [];
    items.add(notificationItem);

    printDefault('Update notification ===> ${notificationItem.toJson()}');

    updateLastNotificationId(items);
    addNotificationListStatus(items);
    if (pushLocal) {
      pushLocalNotification(notificationItem);
    } else {
      handleNotifyItem(notificationItem);
    }
  }

  static Future<void> pushLocalNotification(MNotifications notifyItem) async {
    String? picturePath;

    StyleInformation? styleInformation = checkStringNullOrEmpty(notifyItem.body)
        ? null
        : BigTextStyleInformation(notifyItem.body!);

    if (Platform.isAndroid && !checkStringNullOrEmpty(notifyItem.picture)) {
      picturePath =
          await ImageCacheManager.getImageLocalPath(notifyItem.picture);
      if (!checkStringNullOrEmpty(picturePath)) {
        styleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(picturePath!),
            contentTitle: notifyItem.body);
      }
    }
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      GENERAL_CHANNEL_ID,
      GENERAL_CHANNEL_NAME,
      channelDescription: GENERAL_CHANNEL_DESCRIPTION,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
      styleInformation: styleInformation,
      color: GlobalManager.colors.majorColor(),
    );

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    Random random = Random();
    int maxInt32Bit = 2147483647;
    int notifyId = random.nextInt(maxInt32Bit - 1) + 1;
    await flutterLocalNotificationsPlugin.show(
      notifyId,
      notifyItem.title,
      notifyItem.body,
      platformChannelSpecifics,
      payload: json.encode(notifyItem.toJson()),
    );
  }

  static void handleNotifyItem(MNotifications notifyItem) {
    if (notifyItem.directAction!) {
      try {
        if (notifyItem.action ==
            enumMapper2String(
                ActionType.JUST_OPEN_APP.toString())) {
          // LibraryManagementUtils.handleLibraryBorrowingNotification(notifyItem);
        // } else if (notifyItem.action ==
        //     enumMapper2String(ActionType
        //         .LIBRARY_OPEN_BORROWING_REGISTRATION_DETAIL
        //         .toString())) {
        //   LibraryManagementUtils.handleLibraryBorrowingRegistrationNotification(
        //       notifyItem);
        // } else if (notifyItem.action ==
        //     enumMapper2String(ActionType.LIBRARY_OPEN_CARD_LIST.toString())) {
        //   LibraryManagementUtils.handleLibraryCardListNotification(notifyItem);
        } else {
          handleAction(notifyItem.action, notifyItem.payload);

          // ---- Library Running Record Notification Handle ----- //
          // Widget? runningRecordPage = RunningRecordLibraryNotificationHandler
          //     .pushPageFromNotificationItem(
          //         notification: MRunningRecordNotification(
          //           id: notifyItem.id,
          //           action: notifyItem.action,
          //           isRead: false,
          //           message: notifyItem.message,
          //           payload: notifyItem.payload,
          //         ),
          //         pushPage: false);
          // if (runningRecordPage != null) {
          //   if (isAppRunning) {
          //     pushPageWithNavState(runningRecordPage);
          //   } else {
          //     nextScreenAfterInit = runningRecordPage;
          //   }
          // }

          // ----------------------------------------------------- //
        }
      } on Exception catch (e) {
        showToastDefault(msg: GlobalManager.strings.errorOccurred!);
        showLog(msg: "An error occur: ${e.toString()}", logLevel: Level.error);
      }
    } else {
      Widget page = NotificationDetail(
        notifyItem: notifyItem,
        shouldFetchFromApi: true,
      );

      if (isAppRunning) {
        pushPageWithNavState(page);
      } else {
        nextScreenAfterInit = page;
      }
    }
  }

  static void updateLastNotificationId(List<MNotifications> notifyItems) async {
    try {
      String? lastIdString =
          await HiveManager.getLastNotificationId();
      MNotifications lastItem = notifyItems[notifyItems.length - 1];
      if (lastItem.id == 0) return;
      if (checkStringNullOrEmpty(lastIdString)) {
        HiveManager.setLastNotificationId(lastItem.id.toString());
      } else {
        int lastId = int.parse(lastIdString!);
        if (lastItem.id! > lastId) {
          HiveManager.setLastNotificationId(lastItem.id.toString());
        }
      }
    } catch (e) {
      showLog(msg: e.toString());
    }
  }

  static Future<void> addNotificationListStatus(
      List<MNotifications> notifyItems, {bool addNew = false}) async {
    /** {"id": "<read_status>"}
     * read_status = true : read
     *             = false : unread
     * eg: {"1": false, "2": true}
     **/

    Map<String, bool>? notifyItemStatus = await HiveManager.getNotificationReadStatus();
    notifyItemStatus ??= {};

    if (addNew) {
      for (MNotifications noti in notifyItems) {
        if (!notifyItemStatus.containsKey(noti.id)) {
          notifyItemStatus.remove(noti.id);
        }
      }
    }
    for (final MNotifications notifyItem in notifyItems) {
      if (!notifyItemStatus.containsKey(notifyItem.id.toString())) {
        notifyItemStatus.addAll({notifyItem.id.toString(): false});
      }
    }

    if (notifyItemStatus.containsKey("0")) notifyItemStatus.remove("0");

    await HiveManager.setNotificationReadStatus(Map<String, bool>.from(notifyItemStatus));
  }

  static Future<List<MNotifications>> getNotificationStatus(
      List<MNotifications> notifyItems) async {
    Map<String, bool>? notifyItemStatus = await HiveManager.getNotificationReadStatus();
    if (checkMapIsNullOrEmpty(notifyItemStatus)) return [];

    for (final MNotifications notifyItem in notifyItems) {
      if (notifyItemStatus!.containsKey(notifyItem.id.toString())) {
        notifyItem.readStatus =
            notifyItemStatus[notifyItem.id.toString()] as bool;
      }
    }

    return notifyItems;
  }

  static Future<void> updateNotificationStatus(
      List<MNotifications> notifyItems) async {

    Map<String, bool>? notifyItemStatus = await HiveManager.getNotificationReadStatus();
    if (checkMapIsNullOrEmpty(notifyItemStatus)) return;
    for (final MNotifications notifyItem in notifyItems) {
      if (notifyItemStatus!.containsKey(notifyItem.id.toString())) {
        notifyItemStatus[notifyItem.id.toString()] = notifyItem.readStatus ?? false;
      }
    }
    await HiveManager.setNotificationReadStatus(notifyItemStatus!);
  }

  // static Future<void> updateNewNotificationStatusForFeatures(
  //     String iconTitle, {
  //       int count = -1,
  //     }) async {
  //   /** {"iconTitle": "is_new"}
  //    * is_new = true/false
  //    * eg: {"OPEN_VEHICLE": false, "OPEN_STUDENT": true}
  //    **/
  //
  //   Map<String, bool>? notifyItemStatus = await HiveManager.getNotificationReadStatus();
  //   notifyItemStatus ??= {};
  //
  //   if (!checkStringNullOrEmpty(iconTitle)) {
  //     notifyItemStatus[iconTitle] = count;
  //     FeatureGridViewController.notificationStatuses = notifyItemStatus;
  //   }
  //
  //   String json = jsonEncode(notifyItemStatus);
  //   SharedPrefManager.setData(
  //     GlobalManager.sharedPrefKey.newNotificationListForFeatures,
  //     json,
  //   );
  //
  //   FeatureGridViewController.streamUpdateNotificationBadge?.add(true);
  // }

  // static Future<void> getNewNotificationStatusForFeatures() async {
  //   /** {"icon title": "count"}
  //    * is_new = true/false
  //    * -1: not show counter text
  //    * eg: {"Xe đưa đón": -1}
  //    **/
  //
  //   LibraryManagementUtils.getLibraryNotificationCount();
  //
  //   Map<String, dynamic> notifyItemStatus;
  //   String jsonNotificationList = SharedPrefManager.getData<String>(
  //     GlobalManager.sharedPrefKey.newNotificationListForFeatures,
  //   );
  //
  //   if (checkStringNullOrEmpty(jsonNotificationList)) {
  //     notifyItemStatus = {};
  //   } else {
  //     notifyItemStatus = await jsonDecode(jsonNotificationList);
  //   }
  //
  //   if (!checkMapIsNullOrEmpty(notifyItemStatus)) {
  //     FeatureGridViewController.notificationStatuses = notifyItemStatus;
  //   }
  // }

  static Future<void> turnOnFirebaseMessagingNotifications() async {
    showLog(msg: "Turn on notification");
    String? token = await FirebaseMessaging.instance.getToken();
    assert(token != null);
    var updateUserToken = await RUser.updateUserToken({
      "token": token,
      "deviceModel": GlobalManager.modelName,
      "deviceId": GlobalManager.deviceId,
      "osVersion": GlobalManager.deviceOS,
    });
    showLog(msg: "Update user token: $token success: $updateUserToken");
  }

  static Future<void> turnOffFirebaseMessagingNotifications() async {
    showLog(msg: "Turn off notification");
    await FirebaseMessaging.instance.deleteToken();
  }

  static void handleAction(String? action, String? payload,
      {BuildContext? context}) async {
    if (action == enumMapper2String(ActionType.OPEN_URL.toString())) {
      Uri uri = Uri.parse(payload ?? "");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showToastDefault(msg: GlobalManager.strings.errorOccurred!);
        showLog(msg: "Could not launch $payload");
      }
    } else if (action ==
        enumMapper2String(ActionType.OPEN_URL_INAPP.toString())) {
      Uri uri = Uri.parse(payload ?? '');
      if (await canLaunchUrl(uri) && context != null) {
        pushPageWithRoute(
          context,
          SlidePageRoute(
            slideTo: 'left',
            page: WebInAppPage(
              appBarTitle: "Web",
              webUrl: payload!,
            ),
          ),
        );
      } else {
        showToastDefault(msg: GlobalManager.strings.errorOccurred!);
        showLog(msg: "Could not launch $payload");
      }
    } else if (action == enumMapper2String(ActionType.CALL.toString())) {
      String url = "tel:$payload";
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showToastDefault(msg: GlobalManager.strings.errorOccurred!);
        showLog(msg: "Could not launch $payload");
      }
    }
  }
}
