import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:pps/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:pps/features/reservations/data/models/general_service_draft.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';

enum ReservationServiceType { agent, general, transportation }

ReservationServiceType? reservationServiceTypeFromDb(String? raw) {
  switch (raw) {
    case 'agent':
      return ReservationServiceType.agent;
    case 'general':
      return ReservationServiceType.general;
    case 'transportation':
      return ReservationServiceType.transportation;
  }
  return null;
}

String reservationServiceTypeToDb(ReservationServiceType type) {
  switch (type) {
    case ReservationServiceType.agent:
      return 'agent';
    case ReservationServiceType.general:
      return 'general';
    case ReservationServiceType.transportation:
      return 'transportation';
  }
}

class ReservationServiceSummary extends Equatable {
  const ReservationServiceSummary({
    required this.id,
    required this.reservationId,
    required this.serviceNo,
    required this.type,
    required this.displayNo,
    required this.totalSale,
    required this.totalCost,
    required this.createdAt,
    required this.agentDetails,
    required this.generalDetails,
    required this.transportationDetails,
  });

  final String id;
  final String reservationId;
  final int serviceNo;
  final ReservationServiceType type;
  final String displayNo;
  final Decimal totalSale;
  final Decimal totalCost;
  final DateTime createdAt;
  final AgentReservationDraft? agentDetails;
  final GeneralServiceDraft? generalDetails;
  final TransportationServiceDraft? transportationDetails;

  @override
  List<Object?> get props => <Object?>[
    id,
    reservationId,
    serviceNo,
    type,
    displayNo,
    totalSale,
    totalCost,
    createdAt,
    agentDetails,
    generalDetails,
    transportationDetails,
  ];
}

class SavedReservationService extends Equatable {
  const SavedReservationService({required this.id, required this.displayNo});

  final String id;
  final String displayNo;

  @override
  List<Object?> get props => <Object?>[id, displayNo];
}
