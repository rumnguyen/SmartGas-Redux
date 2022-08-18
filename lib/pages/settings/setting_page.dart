import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _renderPageBody() {
    return Container();
  }

  PreferredSizeWidget? _renderAppBar(String title) {
    return CustomAppBar(
      title: title,
      enableLeadingIcon: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.grayF2F2F2,
      appBar: _renderAppBar(GlobalManager.strings.appSettings!),
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
}
