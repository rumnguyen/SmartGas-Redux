import 'package:carousel_slider/carousel_slider.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/permission_constant.dart';
import 'package:anpha_petrol_smartgas/core/system_feature.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/m_banner_ad.dart';
import 'package:anpha_petrol_smartgas/models/m_user.dart';
import 'package:anpha_petrol_smartgas/models/o_feature_item.dart';
import 'package:anpha_petrol_smartgas/pages/home/admin_general_chart_page.dart';
import 'package:anpha_petrol_smartgas/pages/settings/profile_page.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/avatar_view.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_smart_refresh.dart';
import 'package:anpha_petrol_smartgas/widgets/feature_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment>
    with AutomaticKeepAliveClientMixin {
  final double _bigSpacing = GlobalManager.styles.bigSpacing;
  final double _mediumSpacing = GlobalManager.styles.mediumSpacing;
  final double _smallSpacing = GlobalManager.styles.smallSpacing;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ValueNotifier<MUser> _userProfileNotifier =
      ValueNotifier(RUser.currentUserInfo);
  final ValueNotifier<List<FeatureItem>?> _featureListNotifier =
      ValueNotifier(null);
  final ValueNotifier<List<MBannerAd>?> _bannerListNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> _dotIndicatorNotifier = ValueNotifier(0);
  final CarouselController _bannerController = CarouselController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshController.requestRefresh();
    });
    _initData();
  }

  @override
  void dispose() {
    _userProfileNotifier.dispose();
    _featureListNotifier.dispose();
    _bannerListNotifier.dispose();
    _dotIndicatorNotifier.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    _featureListNotifier.value = SystemFeatureUtils.instance.homeFeatureData();
    _bannerListNotifier.value = [
      MBannerAd(id: 1, image: "assets/images/banner1.jpeg"),
      MBannerAd(id: 2, image: "assets/images/banner2.jpeg"),
      MBannerAd(id: 3, image: "assets/images/banner3.jpeg"),
    ];
    await RUser.getUserInfo({});
    _userProfileNotifier.value = RUser.currentUserInfo;
  }

  Widget _renderAvatarRow() {
    return ValueListenableBuilder<MUser>(
      valueListenable: _userProfileNotifier,
      builder: (_, user, __) {
        String displayInfo = "${user.roleName}";
        if (!checkStringNullOrEmpty(user.warehouseName)) {
          displayInfo = "$displayInfo - ${user.warehouseName ?? ''}";
        }
        return Row(
          children: [
            SizedBox(
              width: _mediumSpacing,
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: TextButton(
                style: GlobalManager.styles.defaultTextButtonStyle,
                onPressed: () {},
                child: AvatarView(
                  avatarImageURL:
                      "https://asp-tmdt-images.s3.amazonaws.com/98247f23-b663-4ac8-857a-ef8a092e067e.jpg",
                  avatarImageSize: 45,
                  avatarBoxBorder: Border.all(
                    color: GlobalManager.colors.majorColor(),
                    width: 1.5,
                  ),
                  pressAvatarImage: () async {
                  },
                ),
              ),
            ),
            SizedBox(
              width: _bigSpacing,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phương Nguyễn',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    "Nhân viên lắp đặt",
                    textScaleFactor: 1.0,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _renderFeatures() {
    return ValueListenableBuilder<List<FeatureItem>?>(
      valueListenable: _featureListNotifier,
      builder: (_, features, __) {
        var _homeFeatureData = features;
        if (checkListIsNullOrEmpty(_homeFeatureData)) {
          return Container();
        }
        return Container(
          width: GlobalManager.appRatio.deviceWidth,
          margin: EdgeInsets.all(_bigSpacing).copyWith(top: 0),
          padding: EdgeInsets.all(_bigSpacing).copyWith(bottom: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [GlobalManager.styles.customBoxShadowAll],
            borderRadius: const BorderRadius.all(Radius.circular(7)),
          ),
          child: FeatureGridView(
            featureItems: _homeFeatureData!,
          ),
        );
      },
    );
  }

  Widget _renderCarouselBanner() {
    return ValueListenableBuilder<List<MBannerAd>?>(
        valueListenable: _bannerListNotifier,
        builder: (_, banners, __) {
          var _bannerAdsList = banners;

          if (checkListIsNullOrEmpty(_bannerAdsList)) {
            return Container();
          }

          Radius radius = const Radius.circular(7.0);
          BorderRadius borderRadius = BorderRadius.all(radius);

          return Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
            ),
            margin: EdgeInsets.only(bottom: _smallSpacing),
            padding: EdgeInsets.only(
              left: _bigSpacing,
              right: _bigSpacing,
            ),
            child: CarouselSlider(
              carouselController: _bannerController,
              options: CarouselOptions(
                  aspectRatio: 2.0,
                  autoPlay: true,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  autoPlayAnimationDuration: const Duration(seconds: 3),
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, _) {
                    _dotIndicatorNotifier.value = index;
                  }),
              items: _bannerAdsList!
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        NotificationUtils.handleAction(
                          item.action,
                          item.payload,
                          context: context,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: ImageCacheManager.getCachedImage02(
                          width: double.infinity,
                          url: item.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        });
  }

  // Widget _renderNotificationList() {
  //   return
  // }

  Widget _renderDotIndicator() {
    return ValueListenableBuilder(
      valueListenable: _dotIndicatorNotifier,
      builder: (_, val, __) {
        List<MBannerAd>? bannerList = _bannerListNotifier.value;
        if (checkListIsNullOrEmpty(bannerList)) {
          return const SizedBox();
        }
        int size = bannerList!.length;
        List<Widget> itemList = [];
        double radius = 6.0;
        for (int i = 0; i < size; i++) {
          double margin = i < size + 1 ? _smallSpacing : 0;
          itemList.add(
            Container(
              width: radius,
              height: radius,
              margin: EdgeInsets.only(right: margin),
              decoration: BoxDecoration(
                color: val == i
                    ? GlobalManager.colors.majorColor()
                    : GlobalManager.colors.grayABABAB,
                borderRadius: BorderRadius.all(Radius.circular(radius)),
              ),
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: itemList,
        );
      },
    );
  }

  Widget _renderPageBody() {
    double chartHeight = 510; // GlobalManager.appRatio.deviceHeight! * 2 / 3;
    return Padding(
      padding: EdgeInsets.symmetric(
        // horizontal: GlobalManager.styles.bigSpacing,
        vertical: GlobalManager.styles.bigSpacing,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: GlobalManager.appRatio.appBarHeight! -
                  GlobalManager.styles.bigSpacing,
            ),
            _renderAvatarRow(),
            const SizedBox(
              height: 24,
            ),
            _renderFeatures(),
            SizedBox(
              height: _smallSpacing,
            ),
            // if (SystemFeatureUtils.instance
            //     .existFeatureInRole(FeatureList.ADMIN_REPORT)) ...[
            //   AdminGeneralChartPage(),
            //   SizedBox(
            //     height: _bigSpacing,
            //   ),
            // ],
            _renderCarouselBanner(),
            _renderDotIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _gotoPage(Widget page) async {
    var result = await pushPage(
      context,
      page,
    );
    // if (result != null && result) {
    //   _getNecessaryData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget _buildElement = Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              color: GlobalManager.colors.majorColor(),
              width: double.infinity,
              height: 180,
            ),
            CustomSmartRefresh(
              child: _renderPageBody(),
              controller: _refreshController,
              enablePullUp: false,
              onRefresh: (cnt) async {
                await _initData();
                cnt.refreshCompleted();
              },
            ),
          ],
        ));

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
