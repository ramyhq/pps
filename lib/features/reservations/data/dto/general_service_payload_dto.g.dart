// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_service_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralServicePayloadDto _$GeneralServicePayloadDtoFromJson(
  Map<String, dynamic> json,
) => GeneralServicePayloadDto(
  dateOfService: json['dateOfService'] as String,
  endDate: json['endDate'] as String,
  serviceName: json['serviceName'] as String,
  description: json['description'] as String,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  supplierId: (json['supplierId'] as num?)?.toInt(),
  salePerItem: json['salePerItem'] as String?,
  costPerItem: json['costPerItem'] as String?,
  totalSale: json['totalSale'] as String,
  totalCost: json['totalCost'] as String,
  termsAndConditions: json['termsAndConditions'] as String?,
  providerRemarks: json['providerRemarks'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$GeneralServicePayloadDtoToJson(
  GeneralServicePayloadDto instance,
) => <String, dynamic>{
  'dateOfService': instance.dateOfService,
  'endDate': instance.endDate,
  'serviceName': instance.serviceName,
  'description': instance.description,
  'quantity': instance.quantity,
  'supplierId': instance.supplierId,
  'salePerItem': instance.salePerItem,
  'costPerItem': instance.costPerItem,
  'totalSale': instance.totalSale,
  'totalCost': instance.totalCost,
  'termsAndConditions': instance.termsAndConditions,
  'providerRemarks': instance.providerRemarks,
  'notes': instance.notes,
};
