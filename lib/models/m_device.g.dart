// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MDevice _$MDeviceFromJson(Map<String, dynamic> json) => MDevice(
      id: json['id'] as int?,
      account_id: json['account_id'] as int?,
      account_code: json['account_code'] as String?,
      account_name: json['account_name'] as String?,
      warehouse_id: json['warehouse_id'] as int?,
      warehouse_name: json['warehouse_name'] as String?,
      type: json['type'] as int?,
      code: json['code'] as String?,
      status: json['status'] as int?,
      first_active: json['first_active'] as int?,
      updated_at: json['updated_at'] as int?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$MDeviceToJson(MDevice instance) => <String, dynamic>{
      'id': instance.id,
      'account_id': instance.account_id,
      'account_code': instance.account_code,
      'account_name': instance.account_name,
      'warehouse_id': instance.warehouse_id,
      'warehouse_name': instance.warehouse_name,
      'type': instance.type,
      'code': instance.code,
      'status': instance.status,
      'first_active': instance.first_active,
      'updated_at': instance.updated_at,
      'address': instance.address,
      'phone': instance.phone,
    };
