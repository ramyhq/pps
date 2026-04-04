import '../models/rms_bridge_reservation_preview.dart';

abstract class RmsBridgeRepository {
  Future<RmsBridgeReservationPreview> fetchReservationPreview({
    required String reservationId,
  });
}

