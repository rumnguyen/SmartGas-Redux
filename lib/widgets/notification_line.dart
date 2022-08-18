import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/date_time_utils.dart';
import 'package:anpha_petrol_smartgas/widgets/active_dot.dart';
import 'package:flutter/material.dart';

/*
  ==============================
  NOTIFICATION LINE INSTRUCTION
  ==============================
  Container(
    margin: EdgeInsets.only(left: 10, right: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: NotificationLine(
      title: "Thay đổi lịch học môn giáo dục thể chất",
      message: "Vui lòng cập nhật lịch học giáo dục thế chất đối với các lớp H, A, F",
      createdAt: DateTime.now(),
      isUnRead: true,
      onPressed: () {
        print("Notification line is pressed");
      },
    ),
  )
*/

class NotificationLine extends StatelessWidget {
  final String? title;
  final String? message;
  final DateTime? createdAt;
  final bool? isUnRead;
  final Function? onPressed;

  NotificationLine({Key? key, 
    required this.title,
    required this.message,
    required this.createdAt,
    this.isUnRead = true,
    this.onPressed,
  }) : assert(title!.isNotEmpty && isUnRead != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget element = TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      style: GlobalManager.styles.defaultTextButtonStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              boxShadow: [GlobalManager.styles.customBoxShadowRB],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Title
                Text(
                  title!,
                  textScaleFactor: 1.0,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                // Datetime
                Text(
                  formatDateTime(
                    createdAt,
                    formatDisplay: formatTimeDateConst,
                  ),
                  textScaleFactor: 1.0,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: GlobalManager.colors.gray808080,
                  ),
                ),
                const SizedBox(height: 5),
                // Message
                Text(
                  message!,
                  textScaleFactor: 1.0,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, color: GlobalManager.colors.gray808080),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        element,
        (isUnRead!
            ? const ActiveDot(
                padding: EdgeInsets.only(
                  top: 8,
                  right: 8,
                ),
              )
            : Container()),
      ],
    );
  }
}
