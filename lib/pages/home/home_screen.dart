import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/my_stream_controller.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/pages/home/home_fragment.dart';
import 'package:anpha_petrol_smartgas/pages/notifications/notifications.dart';
import 'package:anpha_petrol_smartgas/pages/settings/personal_page.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_exit_dialog.dart';
import 'package:flutter/material.dart';

GlobalKey<_HomeScreenState> homeScreenGlobalKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeObject {
  int notificationQuantity = 0;
  int selectedPage = 0;
  bool featureFetched = false;
}

class _HomeScreenState extends State<HomeScreen> {
  final double _bottomBarHeight = 60;

  late List<Widget> _pageOptions;
  late PageController _pageController;
  final MyStreamController<_HomeObject> _homeObjectController =
      MyStreamController<_HomeObject>();
  final _HomeObject _valueStatus = _HomeObject();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageOptions = [
      HomeFragment(),
      PersonalPage(),
    ];
    _valueStatus.featureFetched = true;
  }

  @override
  void dispose() {
    _homeObjectController.close();
    super.dispose();
  }

  void _onPageChanged(int index) {
    int _selectedPage = _homeObjectController.value?.selectedPage ?? 0;
    if (_selectedPage == index) return;
    _valueStatus.selectedPage = _selectedPage;
    _homeObjectController.add(_valueStatus);
    // setState(() {
    //   _selectedPage = index;
    // });
  }

  void _changePageTab(int index) {
    _pageController.jumpToPage(index);
    _valueStatus.selectedPage = index;
    _homeObjectController.add(_valueStatus);
    // if (index == 1) {
    //   setState(() {
    //     _notificationQuantity = 0;
    //   });
    // }
  }

  void getNotificationCount() async {
    // String? lastIdString =
    //     SharedPrefManager.getData<String>(R.sharedPrefKey.lastNotificationId);
    // int lastId;
    // if (checkStringNullOrEmpty(lastIdString))
    //   lastId = 1;
    // else
    //   lastId = int.parse(lastIdString!);
    // Map<String, dynamic> mapCount = {'count': 0};
    // // await RNotification.getNotificationCount(lastId);
    //
    // if (checkMapIsNullOrEmpty(mapCount)) return;
    // setState(() {
    //   _notificationQuantity = mapCount["count"];
    // });

    int _count = 0;

    // String? jsonNotificationList = HiveManager.getData<String>(
    //     GlobalManager.sharedPrefKey.notificationListStatus);
    // if (!checkStringNullOrEmpty(jsonNotificationList)) {
    //   Map<String, dynamic> _notifyItemStatus =
    //   jsonDecode(jsonNotificationList!);
    //
    //   for (var item in _notifyItemStatus.entries) {
    //     if (!item.value) {
    //       ++_count;
    //     }
    //   }
    // }

    // setState(() {
    //   _notificationQuantity = _count;
    // });
    _valueStatus.notificationQuantity = _count;
    _homeObjectController.add(_valueStatus);
  }

  Widget _buildBottomTabBar(_HomeObject valueStatus) {
    return BottomAppBar(
      color: Colors.white,
      child: SizedBox(
        height: _bottomBarHeight,
        width: GlobalManager.appRatio.deviceWidth,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Home page
            _buildBottomObject(
              index: 0,
              text: GlobalManager.strings.home!,
              iconSize: 22,
              activeIconUrl: GlobalManager.myIcons.svgHomeSolid,
              inactiveIconUrl: GlobalManager.myIcons.svgHomeOutlined,
              func: _changePageTab,
              featureFetched: valueStatus.featureFetched,
              selectedPage: valueStatus.selectedPage,
            ),
            // Settings
            _buildBottomObject(
              index: 1,
              text: GlobalManager.strings.settings!,
              iconSize: 24,
              activeIconUrl: GlobalManager.myIcons.svgPersonalSolid,
              inactiveIconUrl: GlobalManager.myIcons.svgPersonalOutlined,
              func: _changePageTab,
              featureFetched: valueStatus.featureFetched,
              selectedPage: valueStatus.selectedPage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderNotificationWithQuantity({
    required int index,
    required int selectedPage,
    required int notificationQuantity,
  }) {
    bool sameIndex = selectedPage == index;

    Widget iconWidget = Container(
      width: 35,
      height: 25,
      alignment: Alignment.center,
      child: ImageCacheManager.getImage(
        url: (sameIndex ? GlobalManager.myIcons.svgNotiSolid : GlobalManager.myIcons.svgNotiOutlined),
        width: 22,
        height: 22,
        fit: BoxFit.cover,
        color: (sameIndex ? GlobalManager.colors.majorColor() : GlobalManager.colors.gray586575),
      ),
    );

    if (notificationQuantity == 0) {
      return iconWidget;
    }

    String content = notificationQuantity.toString();
    if (notificationQuantity >= 100) {
      content = "99+";
    }

    Widget quantityWidget = Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Text(
        content,
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 8,
        ),
      ),
    );

    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        iconWidget,
        quantityWidget,
      ],
    );
  }

  Widget _buildBottomObject({
    required String? text,
    required int index,
    required bool featureFetched,
    required selectedPage,
    bool hide = false,
    String? activeIconUrl,
    String? inactiveIconUrl,
    double? iconSize = 22,
    Widget? iconWidget,
    Function(int index)? func,
  }) {
    if (!featureFetched || hide) return Container();
    bool sameIndex = selectedPage == index;

    iconWidget ??= Container(
      width: 35,
      height: 25,
      alignment: Alignment.center,
      child: ImageCacheManager.getImage(
        url: (sameIndex ? activeIconUrl : inactiveIconUrl),
        width: iconSize,
        height: iconSize,
        fit: BoxFit.cover,
        color: (sameIndex
            ? GlobalManager.colors.majorColor()
            : GlobalManager.colors.gray586575),
      ),
    );

    return Expanded(
      child: TextButton(
        onPressed: () {
          if (func != null) {
            func.call(index);
          }
        },
        style: TextButton.styleFrom(
          textStyle: const TextStyle(color: Colors.white),
          primary: GlobalManager.colors.majorColor(opacity: 0.1),
          padding: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            iconWidget,
            const SizedBox(
              height: 5,
            ),
            Text(
              text ?? '',
              textScaleFactor: 1.0,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: (sameIndex
                    ? GlobalManager.colors.majorColor()
                    : GlobalManager.colors.gray586575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showCustomExitDialog<bool>(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            PageView.builder(
              itemCount: _pageOptions.length,
              itemBuilder: (context, index) {
                return _pageOptions[index];
              },
              controller: _pageController,
              onPageChanged: _onPageChanged,
              pageSnapping: false,
              physics: const NeverScrollableScrollPhysics(),
            )
          ],
        ),
        bottomNavigationBar: StreamBuilder<_HomeObject>(
          stream: _homeObjectController.stream,
          initialData: _valueStatus,
          builder: (ctx, snapshot) {
            printDefault('bottomNavigationBar ${snapshot.hasData}');
            if (!snapshot.hasData) return Container();
            return _buildBottomTabBar(snapshot.data!);
          },
        ),
      ),
    );
  }
}
