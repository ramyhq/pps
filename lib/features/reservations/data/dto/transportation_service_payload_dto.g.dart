// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transportation_service_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransportationServicePayloadDto _$TransportationServicePayloadDtoFromJson(
  Map<String, dynamic> json,
) => TransportationServicePayloadDto(
  pricingPerTrip: json['pricingPerTrip'] as bool,
  routeType: json['routeType'] as String,
  serviceRoute: json['serviceRoute'] as String?,
  supplierId: (json['supplierId'] as num?)?.toInt(),
  supplierName: json['supplierName'] as String?,
  termsAndConditions: json['termsAndConditions'] as String?,
  transactionNotes: json['transactionNotes'] as String?,
  providerRemarks: json['providerRemarks'] as String?,
  providerOptionDate: json['providerOptionDate'] as String?,
  trips: (json['trips'] as List<dynamic>)
      .map(
        (e) => TransportationTripPayloadDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  totalSale: json['totalSale'] as String,
  totalCost: json['totalCost'] as String,
);

Map<String, dynamic> _$TransportationServicePayloadDtoToJson(
  TransportationServicePayloadDto instance,
) => <String, dynamic>{
  'pricingPerTrip': instance.pricingPerTrip,
  'routeType': instance.routeType,
  'serviceRoute': instance.serviceRoute,
  'supplierId': instance.supplierId,
  'supplierName': instance.supplierName,
  'termsAndConditions': instance.termsAndConditions,
  'transactionNotes': instance.transactionNotes,
  'providerRemarks': instance.providerRemarks,
  'providerOptionDate': instance.providerOptionDate,
  'trips': instance.trips.map((e) => e.toJson()).toList(),
  'totalSale': instance.totalSale,
  'totalCost': instance.totalCost,
};

TransportationTripPayloadDto _$TransportationTripPayloadDtoFromJson(
  Map<String, dynamic> json,
) => TransportationTripPayloadDto(
  type: json['type'] as String,
  fromDestination: json['fromDestination'] as String,
  toDestination: json['toDestination'] as String,
  vehicle: json['vehicle'] as String,
  date: json['date'] as String,
  time: json['time'] as String,
  quantity: (json['quantity'] as num).toInt(),
  pax: (json['pax'] as num).toInt(),
  notes: json['notes'] as String?,
  salePerItem: json['salePerItem'] as String,
  costPerItem: json['costPerItem'] as String,
);

Map<String, dynamic> _$TransportationTripPayloadDtoToJson(
  TransportationTripPayloadDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'fromDestination': instance.fromDestination,
  'toDestination': instance.toDestination,
  'vehicle': instance.vehicle,
  'date': instance.date,
  'time': instance.time,
  'quantity': instance.quantity,
  'pax': instance.pax,
  'notes': instance.notes,
  'salePerItem': instance.salePerItem,
  'costPerItem': instance.costPerItem,
};
