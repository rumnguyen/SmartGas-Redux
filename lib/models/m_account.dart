import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'm_account.g.dart';

@JsonSerializable()
@CopyWith()
class MAccount {
  int? id;
  String? province_name;
  String? district_name;
  String? ward_name;
  String? location;
  String? phone_number;
  String? display_name;
  int? gender;
  int? status;
  int? bag;
  int? reward_point;
  int? total_spending;
  int? total_quantity;
  double? weight_available;
  int? created_at;
  int? updated_at;
  int? lat;
  int? lng;
  String? device_code;

  MAccount({
    required this.id,
    this.province_name,
    this.district_name,
    this.ward_name,
    this.location,
    this.phone_number,
    this.display_name,
    this.gender,
    this.status,
    this.bag,
    this.reward_point,
    this.total_spending,
    this.total_quantity,
    this.weight_available,
    this.created_at,
    this.updated_at,
    this.lat,
    this.lng,
    this.device_code
  });

  factory MAccount.fromJson(Map<String, dynamic> json) =>
      _$MAccountFromJson(json);

  Map<String, dynamic> toJson() => _$MAccountToJson(this);

  Color getStatusColor() {
    LookupAccountStatus statusEnum = getLookupAccountStatus(status ?? 0);
    switch (statusEnum) {
      case LookupAccountStatus.block:
        return GlobalManager.colors.black2C394B;
      case LookupAccountStatus.active:
        return GlobalManager.colors.green56C38F;
      case LookupAccountStatus.inactive:
        return GlobalManager.colors.redEC1E37;
      case LookupAccountStatus.installing:
        return GlobalManager.colors.purpleC490E4;
      case LookupAccountStatus.revoked:
        return GlobalManager.colors.orangeFF9234;
      case LookupAccountStatus.unknown:
        return GlobalManager.colors.black2C394B;
    }
  }

}
