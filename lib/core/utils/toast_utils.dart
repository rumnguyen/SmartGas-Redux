import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastDefault({
  required String msg,
  ToastGravity gravity = ToastGravity.BOTTOM,
  Toast toastLength = Toast.LENGTH_SHORT,
  Color? bgColor,
  Color? textColor,
}) {
  bgColor ??= GlobalManager.colors.colorAccent;
  textColor ??= Colors.white;

  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: gravity,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}

void printDefault(dynamic msg) {
  if (kDebugMode) {
    print("===>$msg");
  }
}
