import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:flutter/material.dart';

import '../ui_button.dart';

class _CustomExitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: GlobalManager.appRatio.deviceWidth,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            GlobalManager.strings.exitApp!,
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          UIButton(
            color: GlobalManager.colors.colorAccent,
            text: GlobalManager.strings.yes!,
            textSize: 14,
            textColor: Colors.white,
            fontWeight: FontWeight.bold,
            enableShadow: false,
            height: 40,
            onTap: () {
              pop(context, object: true);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          UIButton(
            color: Colors.white,
            text: GlobalManager.strings.no!,
            textSize: 14,
            textColor: Colors.black,
            fontWeight: FontWeight.bold,
            enableShadow: false,
            border: Border.all(
              color: GlobalManager.colors.grayABABAB,
            ),
            height: 40,
            onTap: () {
              pop(context);
            },
          ),
        ],
      ),
    );
  }
}

Future<T?> showCustomExitDialog<T>(BuildContext context) async {
  return await showGeneralDialog<T>(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(anim1),
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _CustomExitDialog(),
        ),
      );
    },
  );
}
