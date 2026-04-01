import 'package:equatable/equatable.dart';

import 'reservation_order.dart';
import 'reservation_service.dart';

class ReservationDetails extends Equatable {
  const ReservationDetails({
    required this.order,
    required this.services,
  });

  final ReservationOrder order;
  final List<ReservationServiceSummary> services;

  @override
  List<Object?> get props => <Object?>[order, services];
}

