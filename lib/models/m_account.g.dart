// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_account.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension MAccountCopyWith on MAccount {
  MAccount copyWith({
    int? bag,
    int? created_at,
    String? device_code,
    String? display_name,
    String? district_name,
    int? gender,
    int? id,
    int? lat,
    int? lng,
    String? location,
    String? phone_number,
    String? province_name,
    int? reward_point,
    int? status,
    int? total_quantity,
    int? total_spending,
    int? updated_at,
    String? ward_name,
    double? weight_available,
  }) {
    return MAccount(
      bag: bag ?? this.bag,
      created_at: created_at ?? this.created_at,
      device_code: device_code ?? this.device_code,
      display_name: display_name ?? this.display_name,
      district_name: district_name ?? this.district_name,
      gender: gender ?? this.gender,
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      location: location ?? this.location,
      phone_number: phone_number ?? this.phone_number,
      province_name: province_name ?? this.province_name,
      reward_point: reward_point ?? this.reward_point,
      status: status ?? this.status,
      total_quantity: total_quantity ?? this.total_quantity,
      total_spending: total_spending ?? this.total_spending,
      updated_at: updated_at ?? this.updated_at,
      ward_name: ward_name ?? this.ward_name,
      weight_available: weight_available ?? this.weight_available,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MAccount _$MAccountFromJson(Map<String, dynamic> json) => MAccount(
      id: json['id'] as int?,
      province_name: json['province_name'] as String?,
      district_name: json['district_name'] as String?,
      ward_name: json['ward_name'] as String?,
      location: json['location'] as String?,
      phone_number: json['phone_number'] as String?,
      display_name: json['display_name'] as String?,
      gender: json['gender'] as int?,
      status: json['status'] as int?,
      bag: json['bag'] as int?,
      reward_point: json['reward_point'] as int?,
      total_spending: json['total_spending'] as int?,
      total_quantity: json['total_quantity'] as int?,
      weight_available: (json['weight_available'] as num?)?.toDouble(),
      created_at: json['created_at'] as int?,
      updated_at: json['updated_at'] as int?,
      lat: json['lat'] as int?,
      lng: json['lng'] as int?,
      device_code: json['device_code'] as String?,
    );

Map<String, dynamic> _$MAccountToJson(MAccount instance) => <String, dynamic>{
      'id': instance.id,
      'province_name': instance.province_name,
      'district_name': instance.district_name,
      'ward_name': instance.ward_name,
      'location': instance.location,
      'phone_number': instance.phone_number,
      'display_name': instance.display_name,
      'gender': instance.gender,
      'status': instance.status,
      'bag': instance.bag,
      'reward_point': instance.reward_point,
      'total_spending': instance.total_spending,
      'total_quantity': instance.total_quantity,
      'weight_available': instance.weight_available,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'lat': instance.lat,
      'lng': instance.lng,
      'device_code': instance.device_code,
    };
