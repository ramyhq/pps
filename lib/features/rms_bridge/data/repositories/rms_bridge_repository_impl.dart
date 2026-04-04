import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/rms_api/rms_runtime_state_providers.dart';
import '../data_sources/rms_bridge_remote_data_source.dart';
import '../dto/rms_extract_reservation_view_response_dto.dart';
import '../models/rms_bridge_hotel_segment.dart';
import '../models/rms_bridge_reservation_preview.dart';
import 'rms_bridge_repository.dart';

class RmsBridgeRepositoryImpl implements RmsBridgeRepository {
  const RmsBridgeRepositoryImpl({
    required this.remoteDataSource,
    required this.ref,
  });

  final RmsBridgeRemoteDataSource remoteDataSource;
  final Ref ref;

  @override
  Future<RmsBridgeReservationPreview> fetchReservationPreview({
    required String reservationId,
  }) async {
    final sessionId = ref.read(rmsRuntimeStateProvider).sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('RMS Bridge requires RMS login first.');
    }

    final json = await remoteDataSource.extractReservationView(
      sessionId: sessionId,
      reservationId: reservationId,
    );

    final dto = RmsExtractReservationViewResponseDto.fromJson(json);
    final details = dto.result?.details;
    final reservation = details?.reservation;

    final normalizedReservationId =
        reservation?.reservationId?.trim().isNotEmpty == true
            ? reservation!.reservationId!.trim()
            : reservationId.trim();

    final segments = (details?.hotelSegments ?? const <RmsHotelSegmentDto>[])
        .where((segment) => (segment.referenceId ?? '').trim().isNotEmpty)
        .map(
          (segment) => RmsBridgeHotelSegment(
            referenceId: segment.referenceId!.trim(),
            hotelId: segment.hotelId?.trim(),
            arrivalDate: segment.arrivalDate?.trim(),
            departureDate: segment.departureDate?.trim(),
            label: segment.label?.trim(),
            type: segment.type?.trim(),
            totalSale: segment.totals?.totalSale?.trim(),
            totalCost: segment.totals?.totalCost?.trim(),
          ),
        )
        .toList(growable: false);

    return RmsBridgeReservationPreview(
      reservationId: normalizedReservationId,
      reservationNo: reservation?.reservationNo?.trim(),
      clientId: reservation?.clientId?.trim(),
      hotelSegments: segments,
    );
  }
}

