import 'package:json_annotation/json_annotation.dart';

part 'rms_extract_reservation_view_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class RmsExtractReservationViewResponseDto {
  const RmsExtractReservationViewResponseDto({required this.result});

  final RmsExtractReservationViewResultDto? result;

  factory RmsExtractReservationViewResponseDto.fromJson(
    Map<String, Object?> json,
  ) =>
      _$RmsExtractReservationViewResponseDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsExtractReservationViewResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RmsExtractReservationViewResultDto {
  const RmsExtractReservationViewResultDto({required this.details});

  final RmsReservationDetailsDto? details;

  factory RmsExtractReservationViewResultDto.fromJson(
    Map<String, Object?> json,
  ) =>
      _$RmsExtractReservationViewResultDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsExtractReservationViewResultDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RmsReservationDetailsDto {
  const RmsReservationDetailsDto({
    required this.reservation,
    required this.hotelSegments,
  });

  final RmsReservationInfoDto? reservation;
  final List<RmsHotelSegmentDto>? hotelSegments;

  factory RmsReservationDetailsDto.fromJson(Map<String, Object?> json) =>
      _$RmsReservationDetailsDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsReservationDetailsDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RmsReservationInfoDto {
  const RmsReservationInfoDto({
    required this.reservationId,
    required this.reservationNo,
    required this.clientId,
  });

  final String? reservationId;
  final String? reservationNo;
  final String? clientId;

  factory RmsReservationInfoDto.fromJson(Map<String, Object?> json) =>
      _$RmsReservationInfoDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsReservationInfoDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RmsHotelSegmentDto {
  const RmsHotelSegmentDto({
    required this.referenceId,
    required this.hotelId,
    required this.arrivalDate,
    required this.departureDate,
    required this.label,
    required this.type,
    required this.totals,
  });

  final String? referenceId;
  final String? hotelId;
  final String? arrivalDate;
  final String? departureDate;
  final String? label;
  final String? type;
  final RmsHotelTotalsDto? totals;

  factory RmsHotelSegmentDto.fromJson(Map<String, Object?> json) =>
      _$RmsHotelSegmentDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsHotelSegmentDtoToJson(this);
}

@JsonSerializable()
class RmsHotelTotalsDto {
  const RmsHotelTotalsDto({required this.totalSale, required this.totalCost});

  final String? totalSale;
  final String? totalCost;

  factory RmsHotelTotalsDto.fromJson(Map<String, Object?> json) =>
      _$RmsHotelTotalsDtoFromJson(json);

  Map<String, Object?> toJson() => _$RmsHotelTotalsDtoToJson(this);
}

