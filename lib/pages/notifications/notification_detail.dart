import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/network/api.dart';
import 'package:anpha_petrol_smartgas/core/utils/date_time_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/core/utils/widget_utils.dart';
import 'package:anpha_petrol_smartgas/models/m_notifications.dart';
import 'package:anpha_petrol_smartgas/repositories/r_notification.dart';
import 'package:anpha_petrol_smartgas/widgets/loading_dot.dart';
import 'package:anpha_petrol_smartgas/widgets/ui_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationDetail extends StatefulWidget {
  final bool? shouldFetchFromApi;
  final MNotifications? notifyItem;
  final bool? isClassNotification;

  @override
  _NotificationDetailState createState() =>
      _NotificationDetailState();

  const NotificationDetail({
    required this.notifyItem,
    this.shouldFetchFromApi = true,
    this.isClassNotification = false,
    Key? key,
  }) : assert(shouldFetchFromApi != null && isClassNotification != null), super(key: key);
}

class _NotificationDetailState extends State<NotificationDetail> {
  final double _boxRadius = 7.0;
  final double _btnRadius = 5.0;
  final double _spacing = 16.0;
  bool _isLoading = false;
  MNotifications? notifyItem;

  @override
  void initState() {
    super.initState();
    if (widget.shouldFetchFromApi!) {
      getNotificationDetail();
    }
  }

  void getNotificationDetail() async {
    setState(() {
      _isLoading = true;
    });

    MNotifications? notifyItem;
    if (widget.isClassNotification!) {
      // notifyItem = await RNotification.getClassNotificationById(
      //   this.notifyItem.id,
      // );
    } else {
      notifyItem = await RNotification.getNotificationById(
        this.notifyItem!.id,
      );
    }

    setState(() {
      this.notifyItem = notifyItem;
      _isLoading = false;
    });
  }

  Widget _renderBody() {
    final _body = removeFigureTag(notifyItem?.body ?? '');

    return Container(
      margin: EdgeInsets.all(_spacing),
      decoration: BoxDecoration(color: GlobalManager.colors.bgLightGray),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(_boxRadius)),
          boxShadow: [GlobalManager.styles.customBoxShadowRB],
        ),
        child: _isLoading
            ? const LoadingIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _spacing,
                        _spacing,
                        _spacing,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notifyItem?.title ?? "",
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                fontSize: 16,
                                color: GlobalManager.colors.black333333,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 5,
                        left: _spacing,
                        right: _spacing,
                      ),
                      child: Text(
                        formatDateTime(
                          notifyItem?.createdAt,
                          formatDisplay: formatTimeDateConst,
                        ),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          color: GlobalManager.colors.gray808080,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.all(_spacing).copyWith(top: 0),
                      child: HtmlWidget(
                        _body,
                        textStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        webView: true,
                        baseUrl: Uri.parse(API.portalDomain),
                        onTapImage: (imageMetaData) {
                          WidgetUtils.openImageFromHtml(context, imageMetaData);
                        },
                      ),
                    ),
                    (notifyItem != null &&
                            !checkStringNullOrEmpty(
                                notifyItem!.actionTitle))
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: _spacing,
                              right: _spacing,
                              bottom: _spacing,
                            ),
                            child: UIButton(
                              radius: _btnRadius,
                              width: double.infinity,
                              height: 40,
                              color: GlobalManager.colors.colorAccent,
                              enableShadow: true,
                              boxShadow: GlobalManager.styles.customBoxShadowB,
                              text: notifyItem?.actionTitle ?? '',
                              textColor: Colors.white,
                              textSize: 16,
                              fontWeight: FontWeight.bold,
                              onTap: () => NotificationUtils.handleAction(
                                notifyItem?.action,
                                notifyItem?.payload,
                                context: context,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _renderReloadButton() {
    return SizedBox(
      width: 55,
      child: TextButton(
        onPressed: () async {
          if (isJustClicked()) return;
          getNotificationDetail();
        },
        style: GlobalManager.styles.defaultTextButtonStyle,
        child: const FaIcon(
          FontAwesomeIcons.arrowRotateRight,
          size: 17,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _wrapBodyWidget =
        NotificationListener<OverscrollIndicatorNotification>(
            child: _renderBody(),
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return false;
            });

    return Scaffold(
      backgroundColor: GlobalManager.colors.bgLightGray,
      appBar: AppBar(
        title: Text(
          GlobalManager.strings.notificationDetail!,
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
        actions: [
          _renderReloadButton(),
        ],
        centerTitle: true,
        backgroundColor: GlobalManager.colors.majorColor(),
        automaticallyImplyLeading: false,
      ),
      body: _wrapBodyWidget,
    );
  }
}
