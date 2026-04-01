import 'package:json_annotation/json_annotation.dart';
import 'package:pps/features/reservations/data/models/general_service_draft.dart';

part 'general_service_payload_dto.g.dart';

@JsonSerializable()
class GeneralServicePayloadDto {
  const GeneralServicePayloadDto({
    required this.dateOfService,
    required this.endDate,
    required this.serviceName,
    required this.description,
    required this.quantity,
    required this.supplierId,
    required this.salePerItem,
    required this.costPerItem,
    required this.totalSale,
    required this.totalCost,
    required this.termsAndConditions,
    required this.providerRemarks,
    required this.notes,
  });

  factory GeneralServicePayloadDto.fromDomain(GeneralServiceDraft draft) {
    return GeneralServicePayloadDto(
      dateOfService: draft.dateOfService.toIso8601String(),
      endDate: draft.endDate.toIso8601String(),
      serviceName: draft.serviceName,
      description: draft.description,
      quantity: draft.quantity,
      supplierId: draft.supplierId,
      salePerItem: draft.salePerItem.toString(),
      costPerItem: draft.costPerItem.toString(),
      totalSale: draft.totalSale.toString(),
      totalCost: draft.totalCost.toString(),
      termsAndConditions: draft.termsAndConditions,
      providerRemarks: draft.providerRemarks,
      notes: draft.notes,
    );
  }

  factory GeneralServicePayloadDto.fromJson(Map<String, dynamic> json) =>
      _$GeneralServicePayloadDtoFromJson(json);

  final String dateOfService;
  final String endDate;
  final String serviceName;
  final String description;
  @JsonKey(defaultValue: 1)
  final int quantity;
  final int? supplierId;
  final String? salePerItem;
  final String? costPerItem;
  final String totalSale;
  final String totalCost;
  final String? termsAndConditions;
  final String? providerRemarks;
  final String? notes;

  Map<String, dynamic> toJson() => _$GeneralServicePayloadDtoToJson(this);
}
