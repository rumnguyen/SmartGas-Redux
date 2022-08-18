import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/permission_constant.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/main.dart';
import 'package:anpha_petrol_smartgas/models/o_feature_item.dart';
import 'package:anpha_petrol_smartgas/pages/account/lookup_account_page.dart';
import 'package:anpha_petrol_smartgas/pages/delivery/delivery_list_page.dart';
import 'package:anpha_petrol_smartgas/pages/devices/devices_main_page.dart';
import 'package:anpha_petrol_smartgas/pages/order/customer_order_histories_page.dart';
import 'package:anpha_petrol_smartgas/pages/report/report_main_page.dart';
import 'package:anpha_petrol_smartgas/pages/report/shipper_report_page.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/web_inapp_page.dart';
import 'package:flutter/material.dart';

class FeatureList {
  static const String INTRODUCTION = "INTRODUCTION";
  static const String CUSTOMER_LOOKUP = "CUSTOMER_LOOKUP";
  static const String DEVICES = "DEVICES";
  static const String HISTORY = "HISTORY";
  static const String DELIVERY = "DELIVERY";
  static const String ORDER = "ORDER";
  static const String REPORT = "REPORT";
  static const String ADMIN_REPORT = "ADMIN_REPORT";
}

class SystemFeatureUtils {
  static final SystemFeatureUtils _instance =
      SystemFeatureUtils._privateConstructor();

  SystemFeatureUtils._privateConstructor();

  static SystemFeatureUtils get instance => _instance;

  factory SystemFeatureUtils() {
    return _instance;
  }

  // CORE FUNC
  List<FeatureItem> homeFeatureData() {
    List<FeatureItem> featureList = [];

    List<String> homeFeatures = [
      FeatureList.INTRODUCTION,
      FeatureList.CUSTOMER_LOOKUP,
      FeatureList.DEVICES,
      FeatureList.ADMIN_REPORT,
    ];

    for (var featureConst in homeFeatures) {
      var item = _getFeatureItemWidget(featureConst);
      if (item != null) {
        featureList.add(item);
      }
    }

    return featureList;
  }

  bool existFeatureInRole(String featureConstant) {
    switch (featureConstant) {
      case FeatureList.INTRODUCTION:
        return true;
      case FeatureList.CUSTOMER_LOOKUP:
        return RUser.userPermissionList
            .contains(PermissionConstant.accountLookup);
      case FeatureList.DEVICES:
        return RUser.userPermissionList
                .contains(PermissionConstant.deviceSetup) ||
            RUser.userPermissionList
                .contains(PermissionConstant.deviceChange) ||
            RUser.userPermissionList
                .contains(PermissionConstant.deviceRevoke) ||
            RUser.userPermissionList.contains(PermissionConstant.deviceFix);
      case FeatureList.DELIVERY:
        return RUser.userPermissionList
            .contains(PermissionConstant.shippingSubmitToken);
      // todo: remove hardcode here
      case FeatureList.HISTORY:
        return true; //RUser.userPermissionList.contains(PermissionConstant.shippingViewInfo);
      case FeatureList.ORDER:
        return RUser.userPermissionList
            .contains(PermissionConstant.orderCreate);
      case FeatureList.REPORT:
      // todo: remove hardcode here
        return true;
      case FeatureList.ADMIN_REPORT:
      // todo: remove hardcode here
        return true;
    }
    return false;
  }

  FeatureItem? _getFeatureItemWidget(String featureConst) {
    String? title;
    String? imgURL;
    Widget? page;
    String? msg = GlobalManager.strings.developingFeature;
    VoidCallback? onPressed;

    switch (featureConst) {
      case FeatureList.INTRODUCTION:
        {
          title = GlobalManager.strings.introduction;
          imgURL = GlobalManager.myIcons.logoSmartGas;
          var webUrl = "https://anphapetrol.store";
          page = WebInAppPage(
            appBarTitle: GlobalManager.strings.introduction!,
            webUrl: webUrl,
          );
        }
        break;
      case FeatureList.CUSTOMER_LOOKUP:
        {
          title = GlobalManager.strings.customer;
          imgURL = GlobalManager.myIcons.svgSearchPeople;
          page = Container();
        }
        break;
      case FeatureList.DEVICES:
        {
          title = GlobalManager.strings.device;
          imgURL = GlobalManager.myIcons.svgBags;
          page = DevicesMainPage();
        }
        break;
      case FeatureList.DELIVERY:
        {
          title = GlobalManager.strings.delivery;
          imgURL = GlobalManager.myIcons.svgDelivery;
          page = DeliveryListPage();
        }
        break;
      case FeatureList.HISTORY:
        {
          title = GlobalManager.strings.history;
          imgURL = GlobalManager.myIcons.svgHistory;
        }
        break;
      case FeatureList.ORDER:
        {
          title = GlobalManager.strings.makeAnOrder;
          imgURL = GlobalManager.myIcons.svgAddToCart;
          // page = CustomerOrderEditorPage();
          page = const CustomerOrderHistoriesPage();
        }
        break;
      case FeatureList.REPORT:
        {
          title = GlobalManager.strings.report;
          imgURL = GlobalManager.myIcons.svgIconReport;
          page = ReportMainPage();
        }
        break;
      case FeatureList.ADMIN_REPORT:
        {
          title = "Quản trị";
          imgURL = GlobalManager.myIcons.svgAdmin;

          var webUrl = "http://speedaiot.ddns.net:8000";
          page = WebInAppPage(
            appBarTitle: "Quản trị",
            webUrl: webUrl,
          );
        }
        break;
    }

    return FeatureItem(
      title: title,
      imgURL: imgURL,
      imgSize: 36,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          return;
        }

        if (page == null) {
          showToastDefault(msg: msg!);
        } else {
          Route route = MaterialPageRoute(builder: (context) => page!);
          navigatorKey.currentState!.push(
            route,
          );
        }
      },
    );
  }
}
