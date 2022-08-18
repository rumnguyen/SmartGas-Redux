class PermissionConstant {

  static const accountLookup = "account__LOOK_UP";
  static const accountSaleSearch = "account__SALE_SEARCH";
  static const accountViewProfile = "account__VIEW_PROFILE";
  static const accountSoftDelete = "account__SOFT_DELETE";
  static const accountFilter = "account__FILTER";
  static const accountCreate = "account__CREATE";
  static const accountUpdate = "account__UPDATE";

  static const accountingTransactionManagementAdvance =
      "accounting_transaction__MANAGEMENT_ADVANCED";
  static const accountingTransactionDetail = "accounting_transaction__DETAIL";
  static const accountingTransactionDelete = "accounting_transaction__DELETE";
  static const accountingTransactionFilter = "accounting_transaction__FILTER";
  static const accountingTransactionCreate = "accounting_transaction__CREATE";
  static const accountingTransactionUpdate = "accounting_transaction__UPDATE";

  static const accountingTransactionGroupManagementAdvance =
      "accounting_transaction_group__MANAGEMENT_ADVANCED";
  static const accountingTransactionGroupDetail =
      "accounting_transaction_group__DETAIL";
  static const accountingTransactionGroupDelete =
      "accounting_transaction_group__DELETE";
  static const accountingTransactionGroupFilter =
      "accounting_transaction_group__FILTER";
  static const accountingTransactionGroupCreate =
      "accounting_transaction_group__CREATE";
  static const accountingTransactionGroupUpdate =
      "accounting_transaction_group__UPDATE";

  static const campaignUpdateStatus = "campaign__UPDATE_STATUS";
  static const campaignDetail = "campaign__DETAIL";
  static const campaignDelete = "campaign__DELETE";
  static const campaignFilter = "campaign__FILTER";
  static const campaignCreate = "campaign__CREATE";
  static const campaignUpdate = "campaign__UPDATE";

  static const campaignHistoryUpdateStatus = "campaign_history__UPDATE_STATUS";
  static const campaignHistoryFilterAccount =
      "campaign_history__FILTER_ACCOUNT";
  static const campaignHistoryFilter = "campaign_history__FILTER";

  static const categorySoftDelete = "category__SOFT_DELETE";
  static const categoryFind = "category__FIND";
  static const categoryFilter = "category__FILTER";
  static const categoryCreate = "category__CREATE";
  static const categoryUpdate = "category__UPDATE";

  static const deviceGetLog = "device__GET_LOG";
  static const deviceSendLog = "device__SEND_LOG";
  static const deviceFix = "device__FIX";
  static const deviceRevoke = "device__REVOKE";
  static const deviceChange = "device__CHANGE";
  static const deviceSetup = "device__SET_UP";
  static const deviceSoftDelete = "device__SOFT_DELETE";
  static const deviceFilter = "device__FILTER";
  static const deviceCreate = "device__CREATE";
  static const deviceUpdate = "device__UPDATE";

  static const exportHistoryUpdateStatus = "export_history__UPDATE_STATUS";
  static const exportHistoryFind = "export_history__FIND";
  static const exportHistoryFilter = "export_history__FILTER";
  static const exportHistoryCreate = "export_history__CREATE";
  static const exportHistoryDetail = "export_history__DETAIL";

  static const generalAddressDetail = "general__ADDRESS_DETAIL";
  static const generalFindAddress = "general__FIND_ADDRESS";
  static const generalFindPartner = "general__FIND_PARTNER";
  static const generalInfo = "general__INFO";

  static const orderGetLog = "order__GET_LOG";
  static const orderShipperCancel = "order__SHIPPER_CANCEL";
  static const orderFind = "order__FIND";
  static const orderShipperUpdate = "order__SHIPPER_UPDATE";
  static const orderLastSuccess = "order__LAST_SUCCESS";
  static const orderCreateRetail = "order__CREATE_RETAIL";
  static const orderFilter = "order__FILTER";
  static const orderCreate = "order__CREATE";
  static const orderUpdate = "order__UPDATE";
  static const orderGeneralExport = "order__GENERAL_EXPORT";
  static const orderPrintExport = "order__PRINT_EXPORT";
  static const orderUploadPicture = "order__UPLOAD_PICTURE";

  static const paymentMethodSoftDelete = "payment_method__SOFT_DELETE";
  static const paymentMethodDetail = "payment_method__DETAIL";
  static const paymentMethodFilter = "payment_method__FILTER";
  static const paymentMethodCreate = "payment_method__CREATE";
  static const paymentMethodUpdate = "payment_method__UPDATE";

  static const privilegeDeleteRole = "privilege__DELETE_ROLE";
  static const privilegeFetchCurrentPermissions =
      "privilege__FETCH_CURRENT_PERMISSIONS";
  static const privilegeFilterRole = "privilege__FILTER_ROLE";
  static const privilegeCreateRole = "privilege__CREATE_ROLE";
  static const privilegeUpdateRole = "privilege__UPDATE_ROLE";
  static const privilegeFetchPermissions = "privilege__FETCH_PERMISSIONS";

  static const productSoftDelete = "product__SOFT_DELETE";
  static const productDetail = "product__DETAIL";
  static const productFilter = "product__FILTER";
  static const productCreate = "product__CREATE";
  static const productUpdate = "product__UPDATE";
  static const productFind = "product__FIND";

  static const providerSoftDelete = "provider__SOFT_DELETE";
  static const providerDetail = "provider__DETAIL";
  static const providerFilter = "provider__FILTER";
  static const providerCreate = "provider__CREATE";
  static const providerUpdate = "provider__UPDATE";
  static const providerFind = "provider__FIND";

  static const reportEndOfDate = "report__END_OF_DATE";

  static const shippingFilterAll = "shipping__FILTER_ALL";
  static const shippingDetail = "shipping__DETAIL";
  static const shippingManagerCancel = "shipping__MANAGER_CANCEL";
  static const shippingViewInfo = "shipping__VIEW_INFO";
  static const shippingFindByCode = "shipping__FIND_BY_CODE";
  static const shippingFindById = "shipping__FIND_BY_ID";
  static const shippingShipperConfirm = "shipping__SHIPPER_CONFIRM";
  static const shippingManagerConfirm = "shipping__MANAGER_CONFIRM";
  static const shippingFilter = "shipping__FILTER";
  static const shippingSubmitToken = "shipping__SUBMIT_TOKEN";
  static const shippingGetToken = "shipping__GET_TOKEN";

  static const staffUpdateWarehouse = "staff__UPDATE_WAREHOUSE";
  static const staffFind = "staff__FIND";
  static const staffFilter = "staff__FILTER";
  static const staffCreate = "staff__CREATE";
  static const staffUpdate = "staff__UPDATE";
  static const staffChangePassword = "staff__CHANGE_PASSWORD";
  static const staffGetProfile = "staff__GET_PROFILE";

  static const stockEventUpdateStatus = "stock_event__UPDATE_STATUS";
  static const stockEventFilter = "stock_event__FILTER";
  static const stockEventGetDetail = "stock_event__GET_DETAIL";
  static const stockEventImport = "stock_event__IMPORT";

  static const warehouseSoftDelete = "warehouse__SOFT_DELETE";
  static const warehouseDetail = "warehouse__DETAIL";
  static const warehouseFilter = "warehouse__FILTER";
  static const warehouseCreate = "warehouse__CREATE";
  static const warehouseUpdate = "warehouse__UPDATE";
  static const warehouseFind = "warehouse__FIND";

  static const warehouseInventoryViewByCode =
      "warehouse_inventory__VIEW_BY_CODE";
  static const warehouseInventoryFilter = "warehouse_inventory__FILTER";
  static const warehouseInventoryCreate = "warehouse_inventory__CREATE";

  static const permissionList = [
    warehouseInventoryViewByCode,
    warehouseInventoryFilter,
    warehouseInventoryCreate,

    warehouseSoftDelete,
    warehouseDetail,
    warehouseFilter,
    warehouseCreate,
    warehouseUpdate,
    warehouseFind,

    stockEventUpdateStatus,
    stockEventFilter,
    stockEventGetDetail,
    stockEventImport,

    staffUpdateWarehouse,
    staffFind,
    staffFilter,
    staffCreate,
    staffUpdate,
    staffChangePassword,
    staffGetProfile,

    shippingFilterAll,
    shippingDetail,
    shippingManagerCancel,
    shippingViewInfo,
    shippingFindByCode,
    shippingFindById,
    shippingShipperConfirm,
    shippingManagerConfirm,
    shippingFilter,
    shippingSubmitToken,
    shippingGetToken,

    reportEndOfDate,

    providerSoftDelete,
    providerDetail,
    providerFilter,
    providerCreate,
    providerUpdate,
    providerFind,

    productSoftDelete,
    productDetail,
    productFilter,
    productCreate,
    productUpdate,
    productFind,

    privilegeDeleteRole,
    privilegeFetchCurrentPermissions,
    privilegeFilterRole,
    privilegeCreateRole,
    privilegeUpdateRole,
    privilegeFetchPermissions,

    paymentMethodSoftDelete,
    paymentMethodDetail,
    paymentMethodFilter,
    paymentMethodCreate,
    paymentMethodUpdate,

    orderGetLog,
    orderShipperCancel,
    orderFind,
    orderShipperUpdate,
    orderLastSuccess,
    orderCreateRetail,
    orderFilter,
    orderUpdate,
    orderCreate,
    orderGeneralExport,
    orderPrintExport,
    orderUploadPicture,

    generalAddressDetail,
    generalFindAddress,
    generalFindPartner,
    generalInfo,

    exportHistoryUpdateStatus,
    exportHistoryFind,
    exportHistoryFilter,
    exportHistoryCreate,
    exportHistoryDetail,

    deviceGetLog,
    deviceSendLog,
    deviceFix,
    deviceRevoke,
    deviceChange,
    deviceSetup,
    deviceSoftDelete,
    deviceFilter,
    deviceCreate,
    deviceUpdate,

    categorySoftDelete,
    categoryFind,
    categoryFilter,
    categoryCreate,
    categoryUpdate,

    campaignHistoryUpdateStatus,
    campaignHistoryFilterAccount,
    campaignHistoryFilter,

    campaignUpdateStatus,
    campaignDetail,
    campaignDelete,
    campaignFilter,
    campaignCreate,
    campaignUpdate,

    accountLookup,
    accountSaleSearch,
    accountViewProfile,
    accountSoftDelete,
    accountFilter,
    accountCreate,
    accountUpdate,

    accountingTransactionManagementAdvance,
    accountingTransactionDetail,
    accountingTransactionDelete,
    accountingTransactionFilter,
    accountingTransactionCreate,
    accountingTransactionUpdate,

    accountingTransactionGroupManagementAdvance,
    accountingTransactionGroupDetail,
    accountingTransactionGroupDelete,
    accountingTransactionGroupFilter,
    accountingTransactionGroupCreate,
    accountingTransactionGroupUpdate,
  ];
}
