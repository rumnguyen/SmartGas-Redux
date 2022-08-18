import 'dart:ui';

import 'package:anpha_petrol_smartgas/core/global_manager.dart';

enum PlatformType {
  Unknown,
  Android,
  iOS,
}

enum AppRole {
  ADMIN,
  SALE_MANAGER,
  DELIVERY,
  MAINTAINER,
  ACCOUNT,
  WAREHOUSE_MANAGER,
}

// AppRole? getAppRoleTypeFromIndex(int? index) {
//   if (index == AppRole.employee.index) {
//     return AppRole.employee;
//   } else if (index == AppRole.staff.index) {
//     return AppRole.staff;
//   }
//
//   return null;
// }

String enumMapper2String(String enumString) {
  return enumString.split(".").last;
}

enum GenderType {
  Unknown,
  Male,
  Female,
}

enum ActionType {
  JUST_OPEN_APP,
  CALL,
  OPEN_URL,
  OPEN_URL_INAPP,
}

enum SignInMethodType {
  PHONE_NUMBER,
  GOOGLE,
  APPLE,
  FACEBOOK,
  ACCOUNT,
}

enum BitmapMarkerIcon {
  vehicleMarkerIcon,
  vehicleRoundMarkerIcon,
  vehicleBearingMarkerIcon,
  stationMarkerIcon,
  stationLightBackwardIcon,
  stationLightForwardIcon,
  stationLightActiveIcon,
  miniMarkerWhiteShadow,
}

enum LookupAccountStatus {
  block,
  active,
  inactive,
  installing,
  revoked,
  unknown
}

String genderEnum2String(int? genderInd) {
  if (genderInd == null) return GlobalManager.strings.unknown!;
  if (genderInd == GenderType.Male.index) {
    return GlobalManager.strings.male!;
  } else if (genderInd == GenderType.Female.index) {
    return GlobalManager.strings.female!;
  } else {
    return GlobalManager.strings.unknown!;
  }
}

GenderType getGenderType(int? index) {
  switch (index) {
    case 0:
      return GenderType.Unknown;
    case 1:
      return GenderType.Male;
    case 2:
      return GenderType.Female;
    default:
      return GenderType.Unknown;
  }
}

LookupAccountStatus getLookupAccountStatus(int status) {
  switch (status) {
    case 1:
      return LookupAccountStatus.block;
    case 2:
      return LookupAccountStatus.active;
    case 3:
      return LookupAccountStatus.inactive;
    case 4:
      return LookupAccountStatus.installing;
    case 5:
      return LookupAccountStatus.revoked;
    default:
      return LookupAccountStatus.unknown;
  }
}

String getLookupAccountStatusText(int status) {
  LookupAccountStatus statusEnum = getLookupAccountStatus(status);
  switch (statusEnum) {
    case LookupAccountStatus.block:
      return GlobalManager.strings.lookupAccountStatusBlock!;
    case LookupAccountStatus.active:
      return GlobalManager.strings.lookupAccountStatusActive!;
    case LookupAccountStatus.inactive:
      return GlobalManager.strings.lookupAccountStatusInactive!;
    case LookupAccountStatus.installing:
      return GlobalManager.strings.lookupAccountStatusInstalling!;
    case LookupAccountStatus.revoked:
      return GlobalManager.strings.lookupAccountStatusRevoke!;
    case LookupAccountStatus.unknown:
      return "";
  }
}

extension LookupAccountStatusExt on LookupAccountStatus {
  String get name {
    switch (this) {
      case LookupAccountStatus.block:
        return GlobalManager.strings.lookupAccountStatusBlock!;
      case LookupAccountStatus.active:
        return GlobalManager.strings.lookupAccountStatusActive!;
      case LookupAccountStatus.inactive:
        return GlobalManager.strings.lookupAccountStatusInactive!;
      case LookupAccountStatus.installing:
        return GlobalManager.strings.lookupAccountStatusInstalling!;
      case LookupAccountStatus.revoked:
        return GlobalManager.strings.lookupAccountStatusRevoke!;
      case LookupAccountStatus.unknown:
        return "";
    }
  }

  int? get value {
    switch (this) {
      case LookupAccountStatus.block:
        return 1;
      case LookupAccountStatus.active:
        return 2;
      case LookupAccountStatus.inactive:
        return 3;
      case LookupAccountStatus.installing:
        return 4;
      case LookupAccountStatus.revoked:
        return 5;
      case LookupAccountStatus.unknown:
        return null;
    }
  }
}

class StationDirectionType {
  static const int all = -1;
  static const int forward = 1;
  static const int backward = 0;
}

class EmployeeType {
  static const int normal = 0;
  static const int superManager = 1;
  static const int bmsManager = 2;
  static const int checkInManager = 3;
}

class DeviceOrderStatusType {
  static const int available = -1;
  static const int processing = 0;
  static const int completed = 1;
}

class DeviceStatusType {
  static const int defaultStatus = 0;
  static const int connected = 1;
  static const int disconnected = 2;
  static const int needToFix = 3;
  static const int emptyEnergy = 4;

  static getText(int status) {
    switch (status) {
      case DeviceStatusType.connected:
        return "Connected";
      case DeviceStatusType.disconnected:
        return "Disconnected";
      case DeviceStatusType.needToFix:
        return "Fix";
      case DeviceStatusType.emptyEnergy:
        return "Empty Energy";
      default:
        return "Default";
    }
  }

  static Color getColor(int status) {
    switch (status) {
      case DeviceStatusType.connected:
        return GlobalManager.colors.green56C38F;
      case DeviceStatusType.disconnected:
        return GlobalManager.colors.redE74C3C;
      case DeviceStatusType.needToFix:
        return GlobalManager.colors.yellowEAB625;
      case DeviceStatusType.emptyEnergy:
        return GlobalManager.colors.yellowEAB625;
      default:
        return GlobalManager.colors.blue3E9AF6;
    }
  }

  static Color getBorderColor(int status) {
    switch (status) {
      case DeviceStatusType.connected:
        return GlobalManager.colors.greenADEACD;
      case DeviceStatusType.disconnected:
        return GlobalManager.colors.redE74C3C;
      case DeviceStatusType.needToFix:
        return GlobalManager.colors.yellowFDDF8D;
      case DeviceStatusType.emptyEnergy:
        return GlobalManager.colors.yellowFDDF8D;
      default:
        return GlobalManager.colors.blue3E9AF6;
    }
  }
}

class DeviceOwnerType {
  static const int all = -1;
  static const int available = 0;
  static const int busy = 1;

  static getText(int status) {
    switch (status) {
      case DeviceOwnerType.all:
        return GlobalManager.strings.deviceOwnerFilterAll;
      case DeviceOwnerType.busy:
        return GlobalManager.strings.deviceOwnerFilterBusy;
      case DeviceOwnerType.available:
        return GlobalManager.strings.deviceOwnerFilterAvailable;
      default:
        return "";
    }
  }
}

class DeviceTaskType {
  static const int empty = 0;
  static const int setup = 1;
  static const int revoke = 2;
  static const int fix = 3;
  static const int check = 4;

  static getText(int status) {
    switch (status) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.setup;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.revoke;
      case DeviceTaskType.fix:
        return GlobalManager.strings.repair;
      default:
        return "";
    }
  }
}

class DeviceTaskStatus {
  static const int pending = 0;
  static const int processing = 1;
  static const int success = 2;

  static String getText(int? taskType, int? status,
      {bool filter = false, isMe = false}) {
    switch (taskType) {
      case DeviceTaskType.setup:
        switch (status) {
          case DeviceTaskStatus.pending:
            return filter
                ? GlobalManager.strings.deviceTaskSetupWaiting!
                : GlobalManager.strings.deviceTaskSetupPending!;
          case DeviceTaskStatus.processing:
            return isMe
                ? GlobalManager.strings.deviceTaskSetupProcessingCancel!
                : GlobalManager.strings.deviceTaskSetupProcessing!;
          case DeviceTaskStatus.success:
            return GlobalManager.strings.deviceTaskSetupSuccess!;
          default:
            return "";
        }
      case DeviceTaskType.revoke:
        switch (status) {
          case DeviceTaskStatus.pending:
            return filter
                ? GlobalManager.strings.deviceTaskRevokeWaiting!
                : GlobalManager.strings.deviceTaskRevokePending!;
          case DeviceTaskStatus.processing:
            return isMe
                ? GlobalManager.strings.deviceTaskRevokeProcessingCancel!
                : GlobalManager.strings.deviceTaskRevokeProcessing!;
          case DeviceTaskStatus.success:
            return GlobalManager.strings.deviceTaskRevokeSuccess!;
          default:
            return "";
        }
      case DeviceTaskType.fix:
        switch (status) {
          case DeviceTaskStatus.pending:
            return filter
                ? GlobalManager.strings.deviceTaskFixWaiting!
                : GlobalManager.strings.deviceTaskFixPending!;
          case DeviceTaskStatus.processing:
            return isMe
                ? GlobalManager.strings.deviceTaskFixProcessingCancel!
                : GlobalManager.strings.deviceTaskFixProcessing!;
          case DeviceTaskStatus.success:
            return GlobalManager.strings.deviceTaskFixSuccess!;
          default:
            return "";
        }
      default:
        return "";
    }
  }

  static Color getColor(int? status, bool isMe) {
    switch (status) {
      case DeviceTaskStatus.pending:
        return GlobalManager.colors.orangeFF9234;
      case DeviceTaskStatus.processing:
        return isMe
            ? GlobalManager.colors.purpleC490E4
            : GlobalManager.colors.colorAccent;
      case DeviceTaskStatus.success:
        return GlobalManager.colors.green56C38F;
      default:
        return GlobalManager.colors.majorColor();
    }
  }
}

class DeliveryStatusType {
  static const deliveryStatusNone = -2;
  static const deliveryStatusPending = 0;
  static const deliveryStatusSuccess = 1;
  static const deliveryStatusFail = 2;
}

enum UploadImageType { avatar, device, order, contract }

class GiftType {
  static const product = 1;

  // todo: need define here
  static const other = 2;
}

class OrderCancellationType {
  static const orderCanceledTypeNextShift = 1;
  static const orderCanceledTypeReSchedule = 2;
  static const orderCanceledTypeByCustomer = 3;
  static const orderCanceledTypeByShipper = 4;
  static const orderCanceledTypeUnableContact = 5;
}

class ShiftTypeInDay {
  static const morningShift = 1;
  static const afternoonShift = 2;
}

class PaymentMethodType {
  static const int cash = 1;
  static const int atm = 2;
  static const int bankTransfer = 3;
  static const int momo = 4;
  static const int ZaloPay = 5;
  static const int VNPay = 6;
}

class ShippingType {
  static const int deliveryNowIn2h = 2;
  static const int deliveryWithShift = 1;
}

class DeviceTaskCancellationType {
  static const reSchedule = 1;
  static const unableContact = 2;
  static const byCustomer = 3;
  static const other = 4;
}
