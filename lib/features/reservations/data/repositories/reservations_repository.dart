import 'package:rms_clone/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:rms_clone/features/reservations/data/models/client.dart';
import 'package:rms_clone/features/reservations/data/models/general_service_draft.dart';
import 'package:rms_clone/features/reservations/data/models/hotel.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_details.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_order.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_service.dart';
import 'package:rms_clone/features/reservations/data/models/supplier.dart';
import 'package:rms_clone/features/reservations/data/models/transportation_service_draft.dart';

abstract class ReservationsRepository {
  Future<List<Client>> listClients();

  Future<List<Hotel>> listHotels();

  Future<List<Supplier>> listSuppliers();

  Future<List<String>> listGeneralServices();

  Future<List<ReservationOrder>> listReservationOrders({int limit = 50});

  Future<String?> findReservationOrderIdByNo(int reservationNo);

  Future<ReservationOrder> createReservationOrder(
    CreateReservationOrderDraft draft,
  );

  Future<SavedReservationService> addAgentService({
    required String reservationId,
    required AgentReservationDraft draft,
  });

  Future<SavedReservationService> updateAgentService({
    required String serviceId,
    required AgentReservationDraft draft,
  });

  Future<SavedReservationService> addGeneralService({
    required String reservationId,
    required GeneralServiceDraft draft,
  });

  Future<SavedReservationService> updateGeneralService({
    required String serviceId,
    required GeneralServiceDraft draft,
  });

  Future<SavedReservationService> addTransportationService({
    required String reservationId,
    required TransportationServiceDraft draft,
  });

  Future<SavedReservationService> updateTransportationService({
    required String serviceId,
    required TransportationServiceDraft draft,
  });

  Future<AgentReservationDraft> fetchAgentServiceDraft(String serviceId);

  Future<GeneralServiceDraft> fetchGeneralServiceDraft(String serviceId);

  Future<TransportationServiceDraft> fetchTransportationServiceDraft(
    String serviceId,
  );

  Future<ReservationOrder> updateReservationMainInfo({
    required String reservationId,
    required int clientId,
    required String? guestName,
    required String? guestNationality,
    required DateTime? clientOptionDate,
  });

  Future<void> deleteReservationService({required String serviceId});

  Future<void> deleteReservationOrder({required String reservationId});

  Future<ReservationDetails> fetchReservationDetails(String reservationId);
}
