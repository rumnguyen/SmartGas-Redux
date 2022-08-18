import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'm_device.g.dart';

@JsonSerializable()
class MDevice {
  int? id;
  int? account_id;
  String? account_code;
  String? account_name;
  int? warehouse_id;
  String? warehouse_name;
  int? type;
  String? code;
  int? status;
  int? first_active;
  int? updated_at;
  String? address;
  String? phone;

  MDevice(
      {required this.id,
      this.account_id,
      this.account_code,
      this.account_name,
      this.warehouse_id,
      this.warehouse_name,
      this.type,
      this.code,
      this.status,
      this.first_active,
      this.updated_at,
      this.address,
      this.phone,
      });

  factory MDevice.fromJson(Map<String, dynamic> json) =>
      _$MDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$MDeviceToJson(this);

  Color getStatusColor() {
    return DeviceStatusType.getColor(status ?? 0);
  }

  String getStatusText() {
    return DeviceStatusType.getText(status ?? 0);
  }
}
