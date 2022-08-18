import 'dart:io';

import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_alert_dialog.dart';

class NetworkDetector {
  static Future<bool> isNetworkConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // Connected
        showLog(msg: '[NETWORK] Connected');
        return true;
      }
    } on SocketException catch (_) {
      // Disconnected
      showLog(msg: '[NETWORK] Disconnected');
    }
    return false;
  }

  static Future<void> loopUntilHasNetwork() async {
    bool netStatus = false;

    await Future.doWhile(() async {
      await Future.delayed(
        const Duration(milliseconds: 4000),
        () async {
          bool status = await NetworkDetector.isNetworkConnected();
          if (status) netStatus = true;
        },
      );

      // True: Continue doWhile
      // False: Stop doWhile
      return !netStatus;
    });
  }

  static Future<void> alertUntilHasNetwork(BuildContext context) async {
    bool netStatus = false;

    await Future.doWhile(() async {
      await Future.delayed(
        const Duration(milliseconds: 2000),
        () async {
          bool status = await NetworkDetector.isNetworkConnected();

          if (status) {
            netStatus = true;
          } else {
            await showCustomAlertDialog(
              context,
              title: GlobalManager.strings.caution,
              content: GlobalManager.strings.errorNoInternet,
              firstButtonText: GlobalManager.strings.ok!.toUpperCase(),
              firstButtonFunction: () => pop(context),
            );
          }
        },
      );

      // True: Continue doWhile
      // False: Stop doWhile
      return !netStatus;
    });
  }

  static Future<void> alertNoNetwork(BuildContext context) async {
    return showCustomAlertDialog(context,
        title: GlobalManager.strings.warning,
        content: GlobalManager.strings.networkRequiredText,
        firstButtonFunction: () => pop(context),
        firstButtonText: GlobalManager.strings.close);
  }

  static Future<void> alertReconnectFailure(BuildContext context) async {
    return showCustomAlertDialog(context,
        title: GlobalManager.strings.error,
        content: GlobalManager.strings.reconnectError,
        firstButtonFunction: () => pop(context),
        firstButtonText: GlobalManager.strings.close);
  }
}
