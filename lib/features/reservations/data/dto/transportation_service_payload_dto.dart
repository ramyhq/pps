import 'package:json_annotation/json_annotation.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';

part 'transportation_service_payload_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TransportationServicePayloadDto {
  const TransportationServicePayloadDto({
    required this.pricingPerTrip,
    required this.routeType,
    required this.serviceRoute,
    required this.supplierId,
    required this.supplierName,
    required this.termsAndConditions,
    required this.transactionNotes,
    required this.providerRemarks,
    required this.providerOptionDate,
    required this.trips,
    required this.totalSale,
    required this.totalCost,
  });

  factory TransportationServicePayloadDto.fromDomain(
    TransportationServiceDraft draft,
  ) {
    return TransportationServicePayloadDto(
      pricingPerTrip: draft.pricingPerTrip,
      routeType: draft.routeType,
      serviceRoute: draft.serviceRoute,
      supplierId: draft.supplierId,
      supplierName: draft.supplierName,
      termsAndConditions: draft.termsAndConditions,
      transactionNotes: draft.transactionNotes,
      providerRemarks: draft.providerRemarks,
      providerOptionDate: draft.providerOptionDate?.toIso8601String(),
      trips: draft.trips
          .map(TransportationTripPayloadDto.fromDomain)
          .toList(growable: false),
      totalSale: draft.totalSale.toString(),
      totalCost: draft.totalCost.toString(),
    );
  }

  factory TransportationServicePayloadDto.fromJson(Map<String, dynamic> json) =>
      _$TransportationServicePayloadDtoFromJson(json);

  final bool pricingPerTrip;
  final String routeType;
  final String? serviceRoute;
  final int? supplierId;
  final String? supplierName;
  final String? termsAndConditions;
  final String? transactionNotes;
  final String? providerRemarks;
  final String? providerOptionDate;
  final List<TransportationTripPayloadDto> trips;
  final String totalSale;
  final String totalCost;

  Map<String, dynamic> toJson() =>
      _$TransportationServicePayloadDtoToJson(this);
}

@JsonSerializable()
class TransportationTripPayloadDto {
  const TransportationTripPayloadDto({
    required this.type,
    required this.fromDestination,
    required this.toDestination,
    required this.vehicle,
    required this.date,
    required this.time,
    required this.quantity,
    required this.pax,
    required this.notes,
    required this.salePerItem,
    required this.costPerItem,
  });

  factory TransportationTripPayloadDto.fromDomain(
    TransportationTripDraft trip,
  ) {
    return TransportationTripPayloadDto(
      type: trip.type,
      fromDestination: trip.fromDestination,
      toDestination: trip.toDestination,
      vehicle: trip.vehicle,
      date: trip.date.toIso8601String(),
      time: trip.time,
      quantity: trip.quantity,
      pax: trip.pax,
      notes: trip.notes,
      salePerItem: trip.salePerItem.toString(),
      costPerItem: trip.costPerItem.toString(),
    );
  }

  factory TransportationTripPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$TransportationTripPayloadDtoFromJson(json);

  final String type;
  final String fromDestination;
  final String toDestination;
  final String vehicle;
  final String date;
  final String time;
  final int quantity;
  final int pax;
  final String? notes;
  final String salePerItem;
  final String costPerItem;

  Map<String, dynamic> toJson() => _$TransportationTripPayloadDtoToJson(this);
}
