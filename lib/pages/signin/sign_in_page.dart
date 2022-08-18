import 'package:anpha_petrol_smartgas/animations/slide_page_route.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/pages/home/home_screen.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/app_logo_heading.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_alert_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_loading_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_text_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _userNameEditingController =
      TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();

  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final double _buttonHeight = 48;
  final double _radius = 8.0;
  final double _spacing = 16.0;

  @override
  void initState() {
    super.initState();
  }

  void getRecentUsername() async {
    String? username = await HiveManager.getRecentUsername();
    if (username?.isNotEmpty ?? false) {
      _userNameEditingController.text = username!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderBG() {
    return ImageCacheManager.getCachedImage02(
        url: GlobalManager.images.bgSignIn);
  }

  Widget _renderUserNameField() {
    return CustomTextField(
      hintText: GlobalManager.strings.loginWithAccountHint!,
      textController: _userNameEditingController,
      focusNode: _userNameFocusNode,
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.next,
      prefixIcon: Padding(
        padding: EdgeInsets.only(top: 12, left: _spacing,),
        child: FaIcon(
          FontAwesomeIcons.solidUser,
          size: 20,
          color: GlobalManager.colors.gray44494D,
        ),
      ),
      borderTextFormFieldColor: GlobalManager.colors.grayBBBFCA,
      height: 48,
    );
  }

  Widget _renderPwField() {
    return CustomTextField(
      hintText: GlobalManager.strings.loginWithPasswordHint!,
      textController: _passwordEditingController,
      focusNode: _passwordFocusNode,
      protectPassword: true,
      textInputType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Padding(
        padding: EdgeInsets.only(top: 12, left: _spacing,),
        child: FaIcon(
          FontAwesomeIcons.unlockKeyhole,
          size: 20,
          color: GlobalManager.colors.gray44494D,
        ),
      ),
      borderTextFormFieldColor: GlobalManager.colors.grayBBBFCA,
      height: 48,
    );
  }

  bool _validateField() {
    String username = _userNameEditingController.text.trim();
    if (username.isEmpty) {
      showToastDefault(msg: GlobalManager.strings.loginWithUserNameEmpty!);
      return false;
    }

    String password = _passwordEditingController.text.trim();
    if (password.isEmpty) {
      showToastDefault(msg: GlobalManager.strings.loginWithPasswordEmpty!);
      return false;
    }

    if (password.length < 6) {
      showToastDefault(msg: GlobalManager.strings.passwordTooShort!);
      return false;
    }

    return true;
  }

  Widget _renderActionButton() {
    return Container(
      height: _buttonHeight,
      width: GlobalManager.appRatio.deviceWidth! - 2*_spacing,
      margin: EdgeInsets.only(top: _spacing),
      padding: EdgeInsets.symmetric(horizontal: _spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_spacing)),
        color: GlobalManager.colors.majorColor(),
      ),
      child: TextButton(
        onPressed: () async {
          showPageWithRoute(
            context,
            SlidePageRoute(
              page: const HomeScreen(),
              slideTo: "left",
            ),
            popUntilFirstRoutes: true,
          );
          return;

          if (_validateField()) {
            showCustomLoadingDialog(context);
            String userName = _userNameEditingController.text.trim();
            String password = _passwordEditingController.text.trim();
            var _result = await RUser.signInWithAccount(username: userName, pw: password);
            if (_result.success) {
              await HiveManager.setRecentUsername(userName);
              pop(context);
              showPageWithRoute(
                context,
                SlidePageRoute(
                  page: const HomeScreen(),
                  slideTo: "left",
                ),
                popUntilFirstRoutes: true,
              );
            } else {
              pop(context);
              showCustomAlertDialog(
                context,
                title: GlobalManager.strings.error,
                // dialogIcon: R.images.errorDialog,
                content: _result.systemMessage,
                // exitButtonFunction: () => pop(context),
                firstButtonText: GlobalManager.strings.ok,
                firstButtonFunction: () {
                  pop(context, object: false);
                },
              );
            }
          }

        },
        style: GlobalManager.styles.defaultTextButtonStyle,
        child: Text(
          GlobalManager.strings.login!.toUpperCase(),
          textScaleFactor: 1.0,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _renderBodyContent() {
    return Column(
      children: [
        _renderUserNameField(),
        _renderPwField(),
        _renderActionButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // double bottom = MediaQuery.of(context).viewInsets.bottom;
    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 150,),
              AppLogoHeading(),
              SizedBox(height: _spacing,),
              _renderBodyContent(),
            ],
          ),
        ),
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }
}
