import 'package:json_annotation/json_annotation.dart';
import 'package:rms_clone/features/reservations/data/models/agent_reservation_draft.dart';

part 'create_agent_reservation_payload_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateAgentReservationPayloadDto {
  const CreateAgentReservationPayloadDto({
    required this.arrivalDate,
    required this.departureDate,
    required this.isManualRate,
    required this.isPricesWithoutVat,
    required this.hotelId,
    required this.hotelName,
    required this.hotelCity,
    required this.supplierId,
    required this.supplierName,
    required this.selectedRoomType,
    required this.selectedMealPlan,
    required this.roomRates,
    required this.roomsSummary,
    required this.totalPax,
    required this.totalSale,
    required this.totalCost,
  });

  factory CreateAgentReservationPayloadDto.fromDomain(
    AgentReservationDraft draft,
  ) {
    return CreateAgentReservationPayloadDto(
      arrivalDate: draft.arrivalDate.toIso8601String(),
      departureDate: draft.departureDate.toIso8601String(),
      isManualRate: draft.isManualRate,
      isPricesWithoutVat: draft.isPricesWithoutVat,
      hotelId: draft.hotelId,
      hotelName: draft.hotelName,
      hotelCity: draft.hotelCity,
      supplierId: draft.supplierId,
      supplierName: draft.supplierName,
      selectedRoomType: draft.selectedRoomType,
      selectedMealPlan: draft.selectedMealPlan,
      roomRates: draft.roomRates
          .map(CreateAgentReservationRoomRateDto.fromDomain)
          .toList(growable: false),
      roomsSummary: draft.roomsSummary
          .map(CreateAgentReservationRoomSummaryDto.fromDomain)
          .toList(growable: false),
      totalPax: draft.totalPax,
      totalSale: draft.totalSale.toString(),
      totalCost: draft.totalCost.toString(),
    );
  }

  factory CreateAgentReservationPayloadDto.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateAgentReservationPayloadDtoFromJson(json);

  final String arrivalDate;
  final String departureDate;
  final bool isManualRate;
  final bool isPricesWithoutVat;
  final int? hotelId;
  final String? hotelName;
  final String? hotelCity;
  final int? supplierId;
  final String? supplierName;
  final String? selectedRoomType;
  final String? selectedMealPlan;
  final List<CreateAgentReservationRoomRateDto> roomRates;
  final List<CreateAgentReservationRoomSummaryDto> roomsSummary;
  final int totalPax;
  final String totalSale;
  final String totalCost;

  Map<String, dynamic> toJson() =>
      _$CreateAgentReservationPayloadDtoToJson(this);
}

@JsonSerializable()
class CreateAgentReservationRoomRateDto {
  const CreateAgentReservationRoomRateDto({
    required this.date,
    required this.saleRoom,
    required this.saleMealPerPax,
    required this.costRoom,
    required this.costMealPerPax,
  });

  factory CreateAgentReservationRoomRateDto.fromDomain(
    AgentReservationRoomRate rate,
  ) {
    return CreateAgentReservationRoomRateDto(
      date: rate.date.toIso8601String(),
      saleRoom: rate.saleRoom,
      saleMealPerPax: rate.saleMealPerPax,
      costRoom: rate.costRoom,
      costMealPerPax: rate.costMealPerPax,
    );
  }

  factory CreateAgentReservationRoomRateDto.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateAgentReservationRoomRateDtoFromJson(json);

  final String date;
  final String saleRoom;
  final String saleMealPerPax;
  final String costRoom;
  final String costMealPerPax;

  Map<String, dynamic> toJson() =>
      _$CreateAgentReservationRoomRateDtoToJson(this);
}

@JsonSerializable()
class CreateAgentReservationRoomSummaryDto {
  const CreateAgentReservationRoomSummaryDto({
    required this.numberOfRooms,
    required this.totalRn,
    required this.roomType,
    required this.mealPlan,
    required this.pax,
    required this.totalSale,
    required this.totalCost,
  });

  factory CreateAgentReservationRoomSummaryDto.fromDomain(
    AgentReservationRoomSummary summary,
  ) {
    return CreateAgentReservationRoomSummaryDto(
      numberOfRooms: summary.numberOfRooms,
      totalRn: summary.totalRn,
      roomType: summary.roomType,
      mealPlan: summary.mealPlan,
      pax: summary.pax,
      totalSale: summary.totalSale.toString(),
      totalCost: summary.totalCost.toString(),
    );
  }

  factory CreateAgentReservationRoomSummaryDto.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateAgentReservationRoomSummaryDtoFromJson(json);

  final int numberOfRooms;
  final int totalRn;
  final String roomType;
  final String mealPlan;
  final int pax;
  final String totalSale;
  final String totalCost;

  Map<String, dynamic> toJson() =>
      _$CreateAgentReservationRoomSummaryDtoToJson(this);
}
