// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rms_extract_reservation_view_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RmsExtractReservationViewResponseDto
_$RmsExtractReservationViewResponseDtoFromJson(Map<String, dynamic> json) =>
    RmsExtractReservationViewResponseDto(
      result: json['result'] == null
          ? null
          : RmsExtractReservationViewResultDto.fromJson(
              json['result'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RmsExtractReservationViewResponseDtoToJson(
  RmsExtractReservationViewResponseDto instance,
) => <String, dynamic>{'result': instance.result?.toJson()};

RmsExtractReservationViewResultDto _$RmsExtractReservationViewResultDtoFromJson(
  Map<String, dynamic> json,
) => RmsExtractReservationViewResultDto(
  details: json['details'] == null
      ? null
      : RmsReservationDetailsDto.fromJson(
          json['details'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$RmsExtractReservationViewResultDtoToJson(
  RmsExtractReservationViewResultDto instance,
) => <String, dynamic>{'details': instance.details?.toJson()};

RmsReservationDetailsDto _$RmsReservationDetailsDtoFromJson(
  Map<String, dynamic> json,
) => RmsReservationDetailsDto(
  reservation: json['reservation'] == null
      ? null
      : RmsReservationInfoDto.fromJson(
          json['reservation'] as Map<String, dynamic>,
        ),
  hotelSegments: (json['hotelSegments'] as List<dynamic>?)
      ?.map((e) => RmsHotelSegmentDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RmsReservationDetailsDtoToJson(
  RmsReservationDetailsDto instance,
) => <String, dynamic>{
  'reservation': instance.reservation?.toJson(),
  'hotelSegments': instance.hotelSegments?.map((e) => e.toJson()).toList(),
};

RmsReservationInfoDto _$RmsReservationInfoDtoFromJson(
  Map<String, dynamic> json,
) => RmsReservationInfoDto(
  reservationId: json['reservationId'] as String?,
  reservationNo: json['reservationNo'] as String?,
  clientId: json['clientId'] as String?,
);

Map<String, dynamic> _$RmsReservationInfoDtoToJson(
  RmsReservationInfoDto instance,
) => <String, dynamic>{
  'reservationId': instance.reservationId,
  'reservationNo': instance.reservationNo,
  'clientId': instance.clientId,
};

RmsHotelSegmentDto _$RmsHotelSegmentDtoFromJson(Map<String, dynamic> json) =>
    RmsHotelSegmentDto(
      referenceId: json['referenceId'] as String?,
      hotelId: json['hotelId'] as String?,
      arrivalDate: json['arrivalDate'] as String?,
      departureDate: json['departureDate'] as String?,
      label: json['label'] as String?,
      type: json['type'] as String?,
      totals: json['totals'] == null
          ? null
          : RmsHotelTotalsDto.fromJson(json['totals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RmsHotelSegmentDtoToJson(RmsHotelSegmentDto instance) =>
    <String, dynamic>{
      'referenceId': instance.referenceId,
      'hotelId': instance.hotelId,
      'arrivalDate': instance.arrivalDate,
      'departureDate': instance.departureDate,
      'label': instance.label,
      'type': instance.type,
      'totals': instance.totals?.toJson(),
    };

RmsHotelTotalsDto _$RmsHotelTotalsDtoFromJson(Map<String, dynamic> json) =>
    RmsHotelTotalsDto(
      totalSale: json['totalSale'] as String?,
      totalCost: json['totalCost'] as String?,
    );

Map<String, dynamic> _$RmsHotelTotalsDtoToJson(RmsHotelTotalsDto instance) =>
    <String, dynamic>{
      'totalSale': instance.totalSale,
      'totalCost': instance.totalCost,
    };
