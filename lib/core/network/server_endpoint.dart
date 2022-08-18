class ServerEndpoint {
  /* APP VERSION */
  String pointGetAppVersion = "";

  /* ACCOUNT */
  String pointAccountSignIn = "";
  String pointAccountSignInByPhoneDebug = "";
  String pointAccountGetInfo = "";
  String pointAccountUpdateToken = "";
  String pointAccountUpdateInfo = "";
  String pointAccountUpdateUserPassword = "";
  String pointAccountUpdateLanguage = "";
  String pointAccountUpdateAvatar = "";
  String pointAccountGetPrivilege = "";
  String pointLookupAccount = "";
  String pointDevices = "";
  String pointDeviceHistories = "";
  String pointGetPaymentMethodList = "";
  String pointTasks = "";
  String pointTasksFail = "";
  String pointReceiveTask = "";
  String pointCancelTask = "";
  String pointCompleteTask = "";
  String pointUploadDeviceImage = "";
  String pointUploadContractImage = "";
  String pointUploadAvatarImage = "";
  String pointUploadOrderImage = "";
  String pointProducts = "";
  String pointCreateOrder = "";

  /* MAINTAIN */
  String pointDeviceSetup = "";
  String pointDeviceReplace = "";
  String pointDeviceRevoke = "";
  String pointDeviceRepair = "";

  /* NOTIFICATIONS */
  String pointGetNotifications = "";
  String pointGetUnreadNotificationCount = "";
  String pointGetNotificationById = "";

  /* DELIVERY */
  String pointGetDeliveryHistories = '';
  String pointGetDeliveryKpiReport = '';
  String pointPostShipperConfirmDeliveryOrder = '';
  String pointPostShipperReceiveDeliveryOrder = '';
  String pointGetDeliveryPackageDetail = '';
  String pointGetDeliveryOrderDetail = '';
  String pointPostShipperMakePaymentForOrder = '';
  String pointPostShipperCancelOrder = '';

  /* ORDER */
  String pointGetMyOrders = '';

  static final ServerEndpoint _instance = ServerEndpoint._privateConstructor();

  static ServerEndpoint get instance => _instance;

  ServerEndpoint._privateConstructor();

  factory ServerEndpoint() {
    // Init api key
    const String apiVersion = "v1";
    String apiKey = "";

    // if (appRole.index == AppRole.employee.index) {
    //   apiKey = "employees";
    // } else {
    //   throw Exception("Please pass the role of app appropriately");
    // }

    // Init necessary point
    /* APP VERSION */
    _instance.pointGetAppVersion = "/$apiVersion/$apiKey/companies/version";

    /* ACCOUNT */
    _instance.pointAccountSignIn = "/chat-viet/$apiVersion/staffs/sign-in";
    _instance.pointAccountSignInByPhoneDebug = "/auth/users/phone/debug";
    _instance.pointAccountGetInfo = "/chat-viet/$apiVersion/staffs/profile";
    _instance.pointAccountUpdateToken = "/chat-viet/$apiVersion/staffs/update-token";
    _instance.pointAccountUpdateInfo = "/$apiVersion/$apiKey/users/info";
    _instance.pointAccountUpdateLanguage =
        "/$apiVersion/$apiKey/users/language";
    _instance.pointAccountUpdateUserPassword =
        "/$apiVersion/$apiKey/users/password";
    _instance.pointAccountUpdateAvatar = "/$apiVersion/$apiKey/users/avatar";
    _instance.pointAccountGetPrivilege =
        "/chat-viet/$apiVersion/privileges/current-permissions";
    _instance.pointLookupAccount = "/chat-viet/$apiVersion/accounts/lookup";

    /* MAINTAIN */
    _instance.pointDeviceSetup =
        "/chat-viet/$apiVersion/devices/maintainer/set-up-device";
    _instance.pointDeviceRepair =
        "/chat-viet/$apiVersion/devices/maintainer/fix-device";
    _instance.pointDeviceReplace =
        "/chat-viet/$apiVersion/devices/maintainer/change-device";
    _instance.pointDeviceRevoke =
        "/chat-viet/$apiVersion/devices/maintainer/revoke-device";

    /* DEVICES */
    _instance.pointDevices = "/chat-viet/$apiVersion/devices";
    _instance.pointDeviceHistories = "/chat-viet/$apiVersion/device_histories";
    _instance.pointGetPaymentMethodList =
        '/chat-viet/$apiVersion/payment_methods';
    _instance.pointTasks = "/chat-viet/$apiVersion/device-tasks";
    _instance.pointTasksFail = "/chat-viet/$apiVersion/device-tasks/fail";
    _instance.pointReceiveTask = "/chat-viet/$apiVersion/device-tasks/receive";
    _instance.pointCancelTask = "/chat-viet/$apiVersion/device-tasks/cancel";
    _instance.pointCompleteTask = "/chat-viet/$apiVersion/device-tasks/complete";
    _instance.pointUploadDeviceImage =
        "/chat-viet/$apiVersion/upload-picture/device";
    _instance.pointUploadContractImage =
        "/chat-viet/$apiVersion/upload-picture/contract";
    _instance.pointUploadAvatarImage =
        "/chat-viet/$apiVersion/upload-picture/avatar";
    _instance.pointUploadOrderImage =
        "/chat-viet/$apiVersion/upload-picture/order";
    _instance.pointProducts = "/chat-viet/$apiVersion/products";
    _instance.pointCreateOrder = '/chat-viet/$apiVersion/orders';

    /* NOTIFICATIONS */
    _instance.pointGetNotifications = "/$apiVersion/$apiKey/notifications";
    _instance.pointGetUnreadNotificationCount =
        "/$apiVersion/$apiKey/notifications/unread/";
    _instance.pointGetNotificationById = "/$apiVersion/$apiKey/notifications/";

    /* DELIVERY */
    _instance.pointGetDeliveryHistories =
        "/chat-viet/$apiVersion/shippings/delivery_histories";
    _instance.pointGetDeliveryKpiReport =
        "/chat-viet/$apiVersion/report/shipper-kpi";
    _instance.pointPostShipperConfirmDeliveryOrder =
        '/chat-viet/$apiVersion/shippings/shipper/confirm';
    _instance.pointPostShipperReceiveDeliveryOrder =
        '/chat-viet/$apiVersion/shippings/submit_token';
    _instance.pointGetDeliveryPackageDetail =
        '/chat-viet/$apiVersion/shippings/detail';
    _instance.pointGetDeliveryOrderDetail =
        '/chat-viet/$apiVersion/orders/find/:orderId';
    _instance.pointPostShipperMakePaymentForOrder =
        '/chat-viet/$apiVersion/orders/shippers/update';
    _instance.pointPostShipperCancelOrder =
        '/chat-viet/$apiVersion/orders/shippers/cancel';

    /* ORDER */
    _instance.pointGetMyOrders = '/chat-viet/$apiVersion/orders/my-orders';

    return _instance;
  }
}
