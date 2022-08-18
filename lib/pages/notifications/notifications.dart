import 'package:anpha_petrol_smartgas/animations/slide_page_route.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/core/utils/widget_utils.dart';
import 'package:anpha_petrol_smartgas/models/m_notifications.dart';
import 'package:anpha_petrol_smartgas/pages/home/home_screen.dart';
import 'package:anpha_petrol_smartgas/pages/notifications/notification_detail.dart';
import 'package:anpha_petrol_smartgas/providers/p_notification.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_app_bar.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_smart_refresh.dart';
import 'package:anpha_petrol_smartgas/widgets/notification_line.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  final bool enableLeading;
  const Notifications({this.enableLeading = false, Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshController.requestRefresh();
    });
  }

  Widget _renderBodyContent() {
    return Consumer<PNotification>(
      builder: (context, value, child) {
        var notificationList = value.notifications;
        return CustomSmartRefresh(
          controller: _refreshController,
          enablePullUp: value.enableLoad,
          onLoading: (cont) => value
              .getNotificationList(loadMore: true)
              .whenComplete(() => cont.loadComplete()),
          onRefresh: (cont) => value
              .getNotificationList()
              .whenComplete(() => cont.refreshCompleted()),
          child: _buildListItem(notificationList),
        );
      },
    );
  }

  Widget _buildListItem(List<MNotifications> notificationList) {
    if (checkListIsNullOrEmpty(notificationList)) {
      return WidgetUtils.renderEmptyData(
        imgUrl: GlobalManager.images.emptyNotification,
        height: 200,
      );
    }
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: notificationList.length,
      itemBuilder: (BuildContext ctx, int index) {
        MNotifications notifyItem = notificationList[index];
        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            top: (index == 0 ? 16 : 0),
            bottom: 16,
          ),
          child: NotificationLine(
            title: notifyItem.title,
            createdAt: notifyItem.createdAt,
            message: notifyItem.message,
            isUnRead: !notifyItem.readStatus!,
            onPressed: () {
              List<MNotifications> items = [];
              notifyItem.readStatus = true;
              items.add(notifyItem);
              NotificationUtils.updateNotificationStatus(items);
              setState(() {
                notificationList[index].readStatus = true;
              });

              homeScreenGlobalKey.currentState?.getNotificationCount();
              // if (notifyItem.formSetID != 0) {
              //   pushPageWithRoute(
              //     context,
              //     SlidePageRoute(
              //       page: FormDetailScreen(
              //         formSetID: notifyItem.formSetID,
              //         notificationID: notifyItem.id,
              //       ),
              //       slideTo: "left",
              //     ),
              //   );
              //   return;
              // }
              if (notifyItem.directAction ?? false) {
                NotificationUtils.handleAction(
                  notifyItem.action!,
                  notifyItem.payload!,
                  context: context,
                );
              } else {
                pushPageWithRoute(
                  context,
                  SlidePageRoute(
                    page: NotificationDetail(
                      notifyItem: notifyItem,
                      shouldFetchFromApi: true,
                    ),
                    slideTo: "left",
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
  PreferredSizeWidget? _renderAppBar(String title) {
    return CustomAppBar(
      title: title,
      enableLeadingIcon: widget.enableLeading,
      actions: [
        SizedBox(
          width: 50,
          child: TextButton(
            onPressed: context.read<PNotification>().didTapCheckedAll,
            style: GlobalManager.styles.defaultTextButtonStyle,
            child: ImageCacheManager.getImage(
              url: GlobalManager.myIcons.checkedAllWhite,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget _buildElement = Scaffold(
      backgroundColor: Colors.white,
      appBar: _renderAppBar(GlobalManager.strings.news!),
      body: _renderBodyContent(),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
