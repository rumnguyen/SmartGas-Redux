import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/models/o_custom_cell_suffix_actions.dart';
import 'package:anpha_petrol_smartgas/models/o_custom_cell_text_item.dart';
import 'package:anpha_petrol_smartgas/pages/home/app_info.dart';
import 'package:anpha_petrol_smartgas/widgets/avatar_view.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_app_bar.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_text_cell.dart';
import 'package:anpha_petrol_smartgas/widgets/lite_rolling_switch/small_lite_rolling_switch.dart';
import 'package:flutter/material.dart';

class PersonalPage extends StatefulWidget {
  final bool enableLeading;

  PersonalPage({this.enableLeading = false, Key? key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>
    with AutomaticKeepAliveClientMixin {
  
  final double _spacing = 15.0;
  bool? _switchStatus;
  bool _isHandlingNotificationStatus = false;
  
  @override
  void initState() {
    super.initState();
    _initSwitchStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initSwitchStatus() async {
    bool? status = await HiveManager.getNotificationStatus();
    if (status == null) {
      status = true;
      HiveManager.setNotificationStatus(true);
    }
    setState(() {
      _switchStatus = status;
    });
  }

  Widget _buildAppNotifications() {
    return CustomTextCell(
      padding: EdgeInsets.all(_spacing),
      enableSplashColor: false,
      outlinedBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7.0),
          topRight: Radius.circular(7.0),
        ),
      ),
      textItems: [
        CustomCellTextItem(
          text: GlobalManager.strings.notifications,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        CustomCellTextItem(
          text: GlobalManager.strings.notificationsDescription,
          padding: const EdgeInsets.only(top: 5),
          style: TextStyle(
            color: GlobalManager.colors.gray808080,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
      avatarView: AvatarView(
        avatarImageURL: GlobalManager.myIcons.notificationColor,
        avatarImageSize: 35,
        enableSquareAvatarImage: true,
      ),
      fullBottomDivider: true,
      suffixActions: [
        CustomCellSuffixActions(
          enable: true,
          alignment: Alignment.topCenter,
          widget: SmallLiteRollingSwitch(
            value: _switchStatus ?? true,
            textOn: "",
            textOff: "",
            colorOn: GlobalManager.colors.colorAccent,
            colorOff: GlobalManager.colors.grayABABAB,
            iconOn: null,
            iconOff: null,
            textSize: 10,
            onTap: () {
              HiveManager.setNotificationStatus(_switchStatus ?? false);
              //TODO:
              updateNotification();
            },
            onChanged: (bool state) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                setState(() {
                  _switchStatus = state;
                });
              });
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildAppLanguage() {
  //   return CustomTextCell(
  //     padding: EdgeInsets.all(_spacing),
  //     outlinedBorder: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(
  //         Radius.circular(0),
  //       ),
  //     ),
  //     textItems: [
  //       CustomCellTextItem(
  //         text: GlobalManager.strings.language,
  //         style: const TextStyle(
  //           color: Colors.black,
  //           fontWeight: FontWeight.w600,
  //           fontSize: 16,
  //         ),
  //       ),
  //       CustomCellTextItem(
  //         text: GlobalManager.strings.languageDescription,
  //         padding: const EdgeInsets.only(top: 5),
  //         style: TextStyle(
  //           color: GlobalManager.colors.gray808080,
  //           fontWeight: FontWeight.normal,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ],
  //     avatarView: AvatarView(
  //       avatarImageURL: GlobalManager.myIcons.languageColor,
  //       avatarImageSize: 35,
  //       enableSquareAvatarImage: true,
  //     ),
  //     fullBottomDivider: true,
  //     onPressed: () async {
  //       String? lang = await showCustomLanguageDialog<String>(context);
  //       if (!checkStringNullOrEmpty(lang)) {
  //         SharedPrefManager.setData(R.sharedPrefKey.appLanguageKey, lang);
  //         await RUser.updateUserMainLanguage({
  //           "language": lang,
  //         });
  //         restartApp("");
  //       }
  //     },
  //   );
  // }

  Widget _buildAppInfo() {
    // bool newVersionAvailable =
    //     GlobalManager.clientVersion?.appVersion.newVersionAvailable ?? false;
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(0),
    );

    // if (!newVersionAvailable) {
      borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(7.0),
        bottomRight: Radius.circular(7.0),
      );
    // }

    return CustomTextCell(
      padding: EdgeInsets.all(_spacing),
      outlinedBorder: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      textItems: [
        CustomCellTextItem(
          text: GlobalManager.strings.appInfo,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        CustomCellTextItem(
          text: GlobalManager.strings.appInfoDesc,
          padding: const EdgeInsets.only(top: 5),
          style: TextStyle(
            color: GlobalManager.colors.gray808080,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
      avatarView: AvatarView(
        avatarImageURL: GlobalManager.myIcons.infoColor,
        avatarImageSize: 35,
        enableSquareAvatarImage: true,
      ),
      fullBottomDivider: false,
      onPressed: () async {
        pushPage(
          context,
          const AppInfoPage(),
        );
      },
    );
  }

  Widget _renderPageBody() {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(7.0)),
        boxShadow: [GlobalManager.styles.customBoxShadowRB],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Notifications
          _buildAppNotifications(),
          // Language
          // _buildAppLanguage(),
          // App info
          _buildAppInfo(),
          // New version available
          // _buildAppNewVersionAvailable(),
          // Privacy Policy
//          _buildAppPrivacyPolicy(),
        ],
      ),
    );
  }

  PreferredSizeWidget? _renderAppBar(String title) {
    return CustomAppBar(
      title: title,
      enableLeadingIcon: widget.enableLeading,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.grayF2F2F2,
      appBar: _renderAppBar(GlobalManager.strings.settings!),
      body: _renderPageBody(),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }

  Future<void> updateNotification() async {
    if (_isHandlingNotificationStatus) return;
    _isHandlingNotificationStatus = true;
    await Future.delayed(
      const Duration(seconds: 5),
          () async {
        if (_switchStatus ?? false) {
          await NotificationUtils.turnOnFirebaseMessagingNotifications();
        } else {
          await NotificationUtils.turnOffFirebaseMessagingNotifications();
        }
        _isHandlingNotificationStatus = false;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
