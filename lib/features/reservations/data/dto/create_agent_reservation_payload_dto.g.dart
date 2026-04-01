// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_agent_reservation_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAgentReservationPayloadDto _$CreateAgentReservationPayloadDtoFromJson(
  Map<String, dynamic> json,
) => CreateAgentReservationPayloadDto(
  arrivalDate: json['arrivalDate'] as String,
  departureDate: json['departureDate'] as String,
  isManualRate: json['isManualRate'] as bool,
  isPricesWithoutVat: json['isPricesWithoutVat'] as bool,
  hotelId: (json['hotelId'] as num?)?.toInt(),
  hotelName: json['hotelName'] as String?,
  hotelCity: json['hotelCity'] as String?,
  supplierId: (json['supplierId'] as num?)?.toInt(),
  supplierName: json['supplierName'] as String?,
  selectedRoomType: json['selectedRoomType'] as String?,
  selectedMealPlan: json['selectedMealPlan'] as String?,
  roomRates: (json['roomRates'] as List<dynamic>)
      .map(
        (e) => CreateAgentReservationRoomRateDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  roomsSummary: (json['roomsSummary'] as List<dynamic>)
      .map(
        (e) => CreateAgentReservationRoomSummaryDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  totalPax: (json['totalPax'] as num).toInt(),
  totalSale: json['totalSale'] as String,
  totalCost: json['totalCost'] as String,
);

Map<String, dynamic> _$CreateAgentReservationPayloadDtoToJson(
  CreateAgentReservationPayloadDto instance,
) => <String, dynamic>{
  'arrivalDate': instance.arrivalDate,
  'departureDate': instance.departureDate,
  'isManualRate': instance.isManualRate,
  'isPricesWithoutVat': instance.isPricesWithoutVat,
  'hotelId': instance.hotelId,
  'hotelName': instance.hotelName,
  'hotelCity': instance.hotelCity,
  'supplierId': instance.supplierId,
  'supplierName': instance.supplierName,
  'selectedRoomType': instance.selectedRoomType,
  'selectedMealPlan': instance.selectedMealPlan,
  'roomRates': instance.roomRates.map((e) => e.toJson()).toList(),
  'roomsSummary': instance.roomsSummary.map((e) => e.toJson()).toList(),
  'totalPax': instance.totalPax,
  'totalSale': instance.totalSale,
  'totalCost': instance.totalCost,
};

CreateAgentReservationRoomRateDto _$CreateAgentReservationRoomRateDtoFromJson(
  Map<String, dynamic> json,
) => CreateAgentReservationRoomRateDto(
  date: json['date'] as String,
  saleRoom: json['saleRoom'] as String,
  saleMealPerPax: json['saleMealPerPax'] as String,
  costRoom: json['costRoom'] as String,
  costMealPerPax: json['costMealPerPax'] as String,
);

Map<String, dynamic> _$CreateAgentReservationRoomRateDtoToJson(
  CreateAgentReservationRoomRateDto instance,
) => <String, dynamic>{
  'date': instance.date,
  'saleRoom': instance.saleRoom,
  'saleMealPerPax': instance.saleMealPerPax,
  'costRoom': instance.costRoom,
  'costMealPerPax': instance.costMealPerPax,
};

CreateAgentReservationRoomSummaryDto
_$CreateAgentReservationRoomSummaryDtoFromJson(Map<String, dynamic> json) =>
    CreateAgentReservationRoomSummaryDto(
      numberOfRooms: (json['numberOfRooms'] as num).toInt(),
      totalRn: (json['totalRn'] as num).toInt(),
      roomType: json['roomType'] as String,
      mealPlan: json['mealPlan'] as String,
      pax: (json['pax'] as num).toInt(),
      totalSale: json['totalSale'] as String,
      totalCost: json['totalCost'] as String,
    );

Map<String, dynamic> _$CreateAgentReservationRoomSummaryDtoToJson(
  CreateAgentReservationRoomSummaryDto instance,
) => <String, dynamic>{
  'numberOfRooms': instance.numberOfRooms,
  'totalRn': instance.totalRn,
  'roomType': instance.roomType,
  'mealPlan': instance.mealPlan,
  'pax': instance.pax,
  'totalSale': instance.totalSale,
  'totalCost': instance.totalCost,
};
