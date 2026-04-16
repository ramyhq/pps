import 'package:equatable/equatable.dart';

import 'client.dart';

class ReservationOrder extends Equatable {
  const ReservationOrder({
    required this.id,
    required this.reservationNo,
    required this.client,
    required this.guestName,
    required this.guestNationality,
    required this.clientOptionDate,
    required this.rmsInvoiceNo,
    this.partyPaxManual,
    required this.createdAt,
  });

  final String id;
  final int reservationNo;
  final Client client;
  final String? guestName;
  final String? guestNationality;
  final DateTime? clientOptionDate;
  final String? rmsInvoiceNo;
  final int? partyPaxManual;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    reservationNo,
    client,
    guestName,
    guestNationality,
    clientOptionDate,
    rmsInvoiceNo,
    partyPaxManual,
    createdAt,
  ];
}

class CreateReservationOrderDraft extends Equatable {
  const CreateReservationOrderDraft({
    required this.clientId,
    required this.guestName,
    required this.guestNationality,
    required this.clientOptionDate,
    this.partyPaxManual,
  });

  final int clientId;
  final String? guestName;
  final String? guestNationality;
  final DateTime? clientOptionDate;
  final int? partyPaxManual;

  @override
  List<Object?> get props => <Object?>[
    clientId,
    guestName,
    guestNationality,
    clientOptionDate,
    partyPaxManual,
  ];
}
