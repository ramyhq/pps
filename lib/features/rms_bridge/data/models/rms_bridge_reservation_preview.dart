import 'package:equatable/equatable.dart';

import 'rms_bridge_hotel_segment.dart';

class RmsBridgeReservationPreview extends Equatable {
  const RmsBridgeReservationPreview({
    required this.reservationId,
    required this.reservationNo,
    required this.clientId,
    required this.hotelSegments,
  });

  final String reservationId;
  final String? reservationNo;
  final String? clientId;
  final List<RmsBridgeHotelSegment> hotelSegments;

  @override
  List<Object?> get props => [reservationId, reservationNo, clientId, hotelSegments];
}

