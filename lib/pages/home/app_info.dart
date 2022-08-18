import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/widgets/active_dot.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  Widget _renderRowItem(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const ActiveDot(
          padding: EdgeInsets.only(
            top: 3,
            right: 10,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textScaleFactor: 1.0,
            maxLines: null,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          GlobalManager.strings.appName!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _renderRowItem("${GlobalManager.strings.version}: ${GlobalManager.clientVersion!.versionName}"),
        const SizedBox(height: 4),
        _renderRowItem(GlobalManager.strings.appDevelopedBy!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.bgLightGray,
      appBar: AppBar(
        title: Text(
          GlobalManager.strings.appInfo!,
          textScaleFactor: 1.0,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: TextButton(
          onPressed: () => pop(context),
          style: GlobalManager.styles.defaultTextButtonStyle,
          child: const FaIcon(
            FontAwesomeIcons.solidCircleLeft,
            size: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: GlobalManager.colors.majorColor(),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(7),
          ),
          boxShadow: [GlobalManager.styles.customBoxShadowRB],
          color: Colors.white,
        ),
        child: _renderBody(),
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
