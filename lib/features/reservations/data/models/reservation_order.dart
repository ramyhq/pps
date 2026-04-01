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
    required this.createdAt,
  });

  final String id;
  final int reservationNo;
  final Client client;
  final String? guestName;
  final String? guestNationality;
  final DateTime? clientOptionDate;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    reservationNo,
    client,
    guestName,
    guestNationality,
    clientOptionDate,
    createdAt,
  ];
}

class CreateReservationOrderDraft extends Equatable {
  const CreateReservationOrderDraft({
    required this.clientId,
    required this.guestName,
    required this.guestNationality,
    required this.clientOptionDate,
  });

  final int clientId;
  final String? guestName;
  final String? guestNationality;
  final DateTime? clientOptionDate;

  @override
  List<Object?> get props => <Object?>[
    clientId,
    guestName,
    guestNationality,
    clientOptionDate,
  ];
}
