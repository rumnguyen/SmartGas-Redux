import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/date_time_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/m_user.dart';
import 'package:anpha_petrol_smartgas/pages/signin/sign_in_page.dart';
import 'package:anpha_petrol_smartgas/providers/p_user.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/avatar_view.dart';
import 'package:anpha_petrol_smartgas/widgets/camera_picker/camera_picker.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_alert_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_gender_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_loading_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/mixed_view.dart';
import 'package:anpha_petrol_smartgas/widgets/ui_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final bool forceUpdate;

  ProfilePage({
    this.forceUpdate = false,
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final editNameController = TextEditingController();
  final editGenderController = TextEditingController();
  final editDateOfBirthController = TextEditingController();
  final editEmailController = TextEditingController();
  final editAddressController = TextEditingController();
  final editPhoneController = TextEditingController();
  final editRoleController = TextEditingController();

  final FocusNode editNameFocusNode = FocusNode();
  final FocusNode editEmailFocusNode = FocusNode();
  final FocusNode editAddressFocusNode = FocusNode();

  final double _textFieldHeight = 40;
  final double _bottomSectionHeight = 70;
  final double _buttonHeight = 40;
  final double _smallSpacing = 10.0;
  final double _bigSpacing = 15.0;

  final double _profileBackgroundHeight =
      GlobalManager.appRatio.statusBarHeight! + 100.0;
  final double _avatarSize = 100.0;
  final double _btnIconSize = 55.0;
  final double _logOutBtnHeight = 55.0;

  MUser? _userInfo;
  MUser? _currentInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = RUser.currentUserInfo;
    _currentInfo = _userInfo?.copyWith();
    _setValueOfTextFields(_userInfo);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setValueOfTextFields(MUser? info) {
    if (info == null) {
      return;
    }

    editNameController.text = info.name ?? '';
    editGenderController.text = genderEnum2String(info.gender);
    editDateOfBirthController.text = formatDateTime(info.birthday);
    editEmailController.text = info.email ?? '';
    editPhoneController.text = info.phone ?? '';
    editAddressController.text = info.address ?? '';
  }

  void _unFocusAllTextFields() {
    editNameFocusNode.unfocus();
    editEmailFocusNode.unfocus();
    editAddressFocusNode.unfocus();
  }

  void _getGenderDialog() async {
    _unFocusAllTextFields();

    await showCustomGenderDialog(
      context,
      initialGender: getGenderType(_userInfo?.gender),
      selectedGender: (selectedGender) {
        GenderType userGenderType = getGenderType(_userInfo?.gender);
        if (userGenderType.index == selectedGender.index) {
          return;
        }
        editGenderController.text = genderEnum2String(selectedGender.index);
        _currentInfo?.gender = selectedGender.index;
        pop(context);
      },
    );
  }

  void _getDobDialog() async {
    _unFocusAllTextFields();

    DateTime firstDate = DateTime(1940, 01, 01);
    DateTime initDate = DateTime(1990, 01, 01);

    if (!checkStringNullOrEmpty(editDateOfBirthController.text)) {
      DateTime? convertedValue = convertString2DateTime(
        editDateOfBirthController.text,
        formatConvert: formatDateConst,
      );

      if (convertedValue!.isAfter(firstDate)) {
        initDate = convertedValue;
      }
    }

    dynamic result = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primarySwatch: MaterialColor(
              0xFF213970,
              rgbToMaterialColor(33, 57, 112),
            ),
            splashColor: GlobalManager.colors.majorColor(opacity: 0.1),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      _currentInfo?.birthday = result;
      editDateOfBirthController.text = formatDateTime(result);
    }
  }

  Widget _renderAvatarField() {
    Widget _backButtonWidget() {
      if (widget.forceUpdate) {
        return Container();
      }
      return SizedBox(
        width: _btnIconSize,
        height: _btnIconSize,
        child: TextButton(
          onPressed: _didTapBack,
          style: TextButton.styleFrom(
            textStyle: const TextStyle(color: Colors.white),
            primary: Colors.white,
            padding: const EdgeInsets.all(0),
          ),
          child: const FaIcon(
            FontAwesomeIcons.solidCircleLeft,
            size: 20,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget _logOutButtonWidget() {
      return SizedBox(
        width: 100,
        height: _logOutBtnHeight,
        child: TextButton(
          onPressed: _didTapLogout,
          style: TextButton.styleFrom(
            textStyle: const TextStyle(color: Colors.white),
            primary: Colors.white,
            padding: const EdgeInsets.all(0),
          ),
          child: Text(
            GlobalManager.strings.logout!,
            textScaleFactor: 1.0,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: _profileBackgroundHeight,
          decoration: BoxDecoration(
            color: GlobalManager.colors.majorColor(),
          ),
        ),
        // Back button & Logout button
        Padding(
          padding: EdgeInsets.only(
            top: _smallSpacing,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _backButtonWidget(),
              _logOutButtonWidget(),
            ],
          ),
        ),
        // User avatar
        Padding(
          padding: EdgeInsets.only(
            top: _bigSpacing * 3 + GlobalManager.appRatio.statusBarHeight!,
          ),
          child: Consumer<PUser>(
            builder: (context, value, child) {
              return AvatarView(
                avatarImageURL: value.userInfo?.avatar ?? "",
                avatarImageSize: _avatarSize,
                avatarBoxBorder: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                supportImageURL: GlobalManager.myIcons.cameraGray,
                pressAvatarImage: () {
                  _updateAvatar(value.userInfo?.avatar);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _checkDataChanged() {
    return editNameController.text.trim() != _userInfo?.name ||
        editEmailController.text.trim() != _userInfo?.email ||
        editAddressController.text != (_userInfo?.address ?? '') ||
        _currentInfo?.birthday != _userInfo?.birthday ||
        _currentInfo?.gender != _userInfo?.gender;
  }

  bool _validateFields() {
    if (checkStringNullOrEmpty(editNameController.text)) {
      showToastDefault(msg: GlobalManager.strings.profileValidateName!);
      return false;
    }
    if (checkStringNullOrEmpty(_userInfo?.phone) &&
        checkStringNullOrEmpty(editPhoneController.text)) {
      showToastDefault(msg: GlobalManager.strings.profileValidatePhone!);
      return false;
    }

    if (checkStringNullOrEmpty(editDateOfBirthController.text)) {
      showToastDefault(msg: GlobalManager.strings.profileValidateDob!);
      return false;
    }

    return true;
  }

  Future<bool> _didTapBack() async {
    if (widget.forceUpdate) {
      return Future.value(false);
    }

    if (_checkDataChanged()) {
      _unFocusAllTextFields();
      await showCustomAlertDialog(
        context,
        title: GlobalManager.strings.warning,
        iconUrl: GlobalManager.myIcons.svgInfo,
        content: GlobalManager.strings.profileChangeQuestion,
        firstButtonText: GlobalManager.strings.yes!.toUpperCase(),
        firstButtonFunction: () {
          pop(context);
          pop(context);
        },
        secondButtonText: GlobalManager.strings.discard!.toUpperCase(),
        secondButtonFunction: () {
          pop(context);
        },
      );
    } else {
      pop(context);
    }

    return Future.value(false);
  }

  Future<void> _didTapLogout() async {
    await showCustomAlertDialog(
      context,
      title: GlobalManager.strings.warning,
      iconUrl: GlobalManager.myIcons.svgWarning,
      content: GlobalManager.strings.profileLogout,
      firstButtonText: GlobalManager.strings.yes!.toUpperCase(),
      firstButtonFunction: () async {
        RUser.logout();
        Widget startPage;
        // if (RUser.loginEnableFeatures[SELECT_COMPANY] == true) {
        //   startPage = CompanySelectionPage();
        // } else {
        startPage = const SignInPage();
        // }
        showPage(
          context,
          startPage,
          popUntilFirstRoutes: true,
        );
      },
      secondButtonText: GlobalManager.strings.no!.toUpperCase(),
      secondButtonFunction: () => pop(context),
    );
  }

  void _updateAvatar(String? currentImage) async {
    final CameraPicker _selectedCameraFile = CameraPicker();
    bool? result = await _selectedCameraFile.showCameraPickerActionSheet(
      context,
      enableClearSelectedFile: false,
      currentImage: currentImage,
    );

    if (result == null || !result) return;
    showCustomLoadingDialog(
      context,
      text: GlobalManager.strings.loading,
    );

    result = await _selectedCameraFile.cropImage(
      maxHeight: 500,
      maxWidth: 500,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: GlobalManager.strings.cropperTitle,
        toolbarColor: GlobalManager.colors.majorColor(),
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(title: GlobalManager.strings.cropperTitle),
    );

    if (!result) {
      pop(context);
      return;
    }

    context
        .read<PUser>()
        .updateAvatarUser(context, _selectedCameraFile.file?.path);
  }

  void _doUpdateProfile() async {
    if (!_validateFields()) {
      return;
    }

    String name = editNameController.text.trim();
    String address = editAddressController.text.trim();
    int? gender = _currentInfo?.gender;
    String? email = editEmailController.text.trim();
    DateTime? birthday = convertString2DateTime(
      editDateOfBirthController.text.trim(),
      formatConvert: formatDateConst,
    );

    birthday ??= DateTime.parse("0001-01-01");

    Map<String, dynamic> bodyData = {
      "name": name,
      "address": address,
      "gender": gender,
      "birthday": dtToUnix(birthday),
    };

    if (!checkStringNullOrEmpty(email)) {
      bodyData['email'] = email;
    }

    String phone = editPhoneController.text.trim();
    if (checkStringNullOrEmpty(_userInfo?.phone) &&
        !checkStringNullOrEmpty(phone)) {
      bodyData["phone"] = phone;
    }

    context.read<PUser>().updateUserInfo(context, bodyData).then((value) {
      if (value == false) return;
      _userInfo = context.read<PUser>().userInfo;
      _currentInfo = _userInfo;
      _setValueOfTextFields(_userInfo);

      if (widget.forceUpdate) {
        pop(context);
      }
    });
  }

  Widget _renderBodySection() {
    Widget __getTitleWidget(String title) {
      return Padding(
        padding: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        child: Text(
          title,
          textScaleFactor: 1.0,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GlobalManager.colors.black333333,
            fontSize: _bigSpacing,
          ),
        ),
      );
    }

    List<Widget> itemList = [
      // [FIELD] AVATAR
      _renderAvatarField(),
      // [TITLE]
      SizedBox(height: _bigSpacing),
      __getTitleWidget("${GlobalManager.strings.profileUserInfo}:"),
      SizedBox(height: _smallSpacing),
      // [FIELD] NAME
      MixedView(
        height: _textFieldHeight,
        margin: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        focusNode: editNameFocusNode,
        textController: editNameController,
        textHint: GlobalManager.strings.nameHint,
        leftIcon: FaIcon(
          FontAwesomeIcons.userAlt,
          size: 14,
          color: GlobalManager.colors.leftIconColor,
        ),
      ),
      SizedBox(height: _bigSpacing),
      // [FIELD] GENDER + BIRTHDAY
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: MixedView(
              isJustForViewing: true,
              height: _textFieldHeight,
              margin: EdgeInsets.only(
                left: _bigSpacing,
              ),
              textController: editGenderController,
              textHint: GlobalManager.strings.gender,
              leftIcon: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: FaIcon(
                  FontAwesomeIcons.transgender,
                  size: 16,
                  color: GlobalManager.colors.leftIconColor,
                ),
              ),
              onPressed: _getGenderDialog,
            ),
          ),
          SizedBox(width: _bigSpacing),
          Expanded(
            child: MixedView(
              isJustForViewing: true,
              height: _textFieldHeight,
              margin: EdgeInsets.only(
                right: _bigSpacing,
              ),
              textController: editDateOfBirthController,
              textHint: GlobalManager.strings.dateHint,
              leftIcon: FaIcon(
                FontAwesomeIcons.solidCalendarDays,
                size: 16,
                color: GlobalManager.colors.leftIconColor,
              ),
              onPressed: _getDobDialog,
            ),
          ),
        ],
      ),
      SizedBox(height: _bigSpacing),
      // [FIELD]  EMAIL
      MixedView(
        height: _textFieldHeight,
        margin: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        focusNode: editEmailFocusNode,
        textController: editEmailController,
        textHint: GlobalManager.strings.emailHint,
        leftIcon: FaIcon(
          FontAwesomeIcons.solidEnvelope,
          size: 16,
          color: GlobalManager.colors.leftIconColor,
        ),
      ),
      SizedBox(height: _bigSpacing),
      // [FIELD] PHONE
      MixedView(
        isJustForViewing: !checkStringNullOrEmpty(_userInfo?.phone),
        height: _textFieldHeight,
        margin: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        textController: editPhoneController,
        textHint: GlobalManager.strings.phoneNumberHint,
        textInputType: TextInputType.phone,
        leftIcon: FaIcon(
          FontAwesomeIcons.phoneFlip,
          size: 16,
          color: GlobalManager.colors.leftIconColor,
        ),
      ),
      SizedBox(height: _bigSpacing),
      // [TITLE] DEPARTMENT INFO
      Padding(
        padding: EdgeInsets.only(
          left: _bigSpacing,
          right: _bigSpacing,
        ),
        child: Text(
          "${GlobalManager.strings.role!}: ",
          textScaleFactor: 1.0,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: GlobalManager.colors.black333333,
          ),
        ),
      ),
      SizedBox(height: _smallSpacing),
      // [FIELD] ROLE
      MixedView(
        isJustForViewing: true,
        height: _textFieldHeight,
        margin: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        leftIcon: FaIcon(
          FontAwesomeIcons.briefcase,
          size: 16,
          color: GlobalManager.colors.leftIconColor,
        ),
        text: _currentInfo?.roleName ?? '-',
        textController: editRoleController,
      ),
      // [TITLE]
      SizedBox(height: _bigSpacing * 1.5),
      __getTitleWidget("${GlobalManager.strings.profileAddressInfo}:"),
      SizedBox(height: _smallSpacing),
      // [FIELD] ADDRESS
      Padding(
        padding: EdgeInsets.only(
          left: _bigSpacing,
          right: _bigSpacing,
        ),
        child: Text(
          GlobalManager.strings.profileAddressDescription!,
          textScaleFactor: 1.0,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: GlobalManager.colors.black333333,
          ),
        ),
      ),
      SizedBox(height: _smallSpacing),
      MixedView(
        height: _textFieldHeight,
        margin: EdgeInsets.only(left: _bigSpacing, right: _bigSpacing),
        focusNode: editAddressFocusNode,
        textController: editAddressController,
        textHint: GlobalManager.strings.profileAddressHint,
        leftIcon: FaIcon(
          FontAwesomeIcons.mapLocationDot,
          size: 16,
          color: GlobalManager.colors.leftIconColor,
        ),
      ),
      // [TITLE]
      SizedBox(height: _bigSpacing * 1.5),
    ];

    // todo: tempo hide
    // if (!widget.forceUpdate) {
    //   // [FIELD] CHANGE PASSWORD BUTTON
    //   itemList.addAll([
    //     getTitleWidget("${R.strings.profileLoginWithPassword}:"),
    //     Padding(
    //       padding: EdgeInsets.only(
    //         top: _smallSpacing,
    //         left: _bigSpacing,
    //         right: _bigSpacing,
    //         bottom: _bigSpacing * 1.5,
    //       ),
    //       child: Consumer<PUser>(
    //         builder: (context, value, child) {
    //           bool isPwCreated = value.userInfo?.createdPassword ?? false;
    //           return UIButton(
    //             text: isPwCreated
    //                 ? GlobalManager.strings.profileChangePassword!
    //                 : GlobalManager.strings.createPassword!,
    //             textColor: Colors.white,
    //             textSize: 14,
    //             color: GlobalManager.colors.majorColor(),
    //             width: double.infinity,
    //             height: _buttonHeight,
    //             fontWeight: FontWeight.bold,
    //             onTap: () async {
    //               var res = await pushPageWithRoute(
    //                 context,
    //                 SlidePageRoute(
    //                   page: PwEditorPage(
    //                     isCreatedNew: !isPwCreated,
    //                   ),
    //                   slideTo: "left",
    //                 ),
    //               );
    //               if (res == true) {
    //                 context
    //                     .read<PUser>()
    //                     .fetchUserInfo(context: context)
    //                     .then((_) {
    //                   _userInfo = context.read<PUser>().userInfo;
    //                   _currentInfo = _userInfo;
    //                   _setValueOfTextFields(_userInfo);
    //                 });
    //               }
    //             },
    //           );
    //         },
    //       ),
    //     ),
    //   ]);
    // }

    // double bottom = MediaQuery.of(context).viewInsets.bottom;
    double bottomPadding = _bottomSectionHeight;
    // if (bottom > 0) {
    //   bottomPadding = 0;
    // }

    return Container(
      height: GlobalManager.appRatio.deviceHeight,
      padding: EdgeInsets.only(
        bottom: bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: itemList,
        ),
      ),
    );
  }

  Widget _renderBottomSection() {
    return Container(
      height: _bottomSectionHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [GlobalManager.styles.customBoxShadowAll],
      ),
      padding: EdgeInsets.only(
        left: _bigSpacing,
        right: _bigSpacing,
      ),
      child: UIButton(
        radius: 5.0,
        color: GlobalManager.colors.colorAccent,
        height: _buttonHeight,
        fontWeight: FontWeight.bold,
        text: GlobalManager.strings.profileUpdate!,
        textSize: 16,
        enable: true,
        boxShadow: GlobalManager.styles.customBoxShadowB,
        onTap: () {
          _unFocusAllTextFields();
          _doUpdateProfile();
        },
      ),
    );
  }

  Widget _renderPageBody() {
    Widget bodySection = _renderBodySection();
    Widget bottomSection = _renderBottomSection();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        bodySection,
        bottomSection,
      ],
    );
  }

  PreferredSizeWidget? _renderAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size(0, 0),
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.grayF2F2F2,
      appBar: _renderAppBar(GlobalManager.strings.profileUserInfo!),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: _renderPageBody(),
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: WillPopScope(
        onWillPop: _didTapBack,
        child: _buildElement,
      ),
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }
}
