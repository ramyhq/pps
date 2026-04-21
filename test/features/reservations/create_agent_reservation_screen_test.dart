import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:pps/features/reservations/data/models/client.dart';
import 'package:pps/features/reservations/data/models/general_service_draft.dart';
import 'package:pps/features/reservations/data/models/hotel.dart';
import 'package:pps/features/reservations/data/models/reservation_details.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/reservation_service.dart';
import 'package:pps/features/reservations/data/models/supplier.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';
import 'package:pps/features/reservations/data/repositories/reservations_repository.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';
import 'package:pps/features/reservations/ui/screens/create_agent_reservation_screen.dart';

class _FakeReservationsRepository implements ReservationsRepository {
  _FakeReservationsRepository({required this.details});

  final ReservationDetails details;

  @override
  Future<List<Client>> listClients() async => const [];

  @override
  Future<List<Hotel>> listHotels() async => const [];

  @override
  Future<List<Supplier>> listSuppliers() async => const [];

  @override
  Future<List<String>> listGeneralServices() async => const [];

  @override
  Future<List<ReservationOrder>> listReservationOrders({int limit = 50}) {
    throw UnimplementedError();
  }

  @override
  Future<String?> findReservationOrderIdByNo(int reservationNo) {
    throw UnimplementedError();
  }

  @override
  Future<ReservationOrder> createReservationOrder(
    CreateReservationOrderDraft draft,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> addAgentService({
    required String reservationId,
    required AgentReservationDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> updateAgentService({
    required String serviceId,
    required AgentReservationDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> addGeneralService({
    required String reservationId,
    required GeneralServiceDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> updateGeneralService({
    required String serviceId,
    required GeneralServiceDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> addTransportationService({
    required String reservationId,
    required TransportationServiceDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SavedReservationService> updateTransportationService({
    required String serviceId,
    required TransportationServiceDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AgentReservationDraft> fetchAgentServiceDraft(String serviceId) {
    throw UnimplementedError();
  }

  @override
  Future<GeneralServiceDraft> fetchGeneralServiceDraft(String serviceId) {
    throw UnimplementedError();
  }

  @override
  Future<TransportationServiceDraft> fetchTransportationServiceDraft(
    String serviceId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ReservationOrder> updateReservationMainInfo({
    required String reservationId,
    required int clientId,
    required String? guestName,
    required String? guestNationality,
    required DateTime? clientOptionDate,
    String? rmsInvoiceNo,
    bool setRmsInvoiceNo = false,
    int? partyPaxManual,
    bool setPartyPaxManual = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReservationService({required String serviceId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReservationOrder({required String reservationId}) {
    throw UnimplementedError();
  }

  @override
  Future<ReservationDetails> fetchReservationDetails(
    String reservationId,
  ) async {
    return details;
  }
}

void main() {
  testWidgets('Add button adds room row and updates pax summary', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final exceptionText = details.exceptionAsString();
      if (exceptionText.contains('A RenderFlex overflowed by')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateAgentReservationScreen(reservationId: 'r1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();

    final roomDetailsHeader = find.text('Room details');
    final roomDetailsCard = find
        .ancestor(of: roomDetailsHeader, matching: find.byType(Card))
        .first;
    final noRoomsInput = find.descendant(
      of: roomDetailsCard,
      matching: find.byType(TextField),
    );
    await tester.enterText(noRoomsInput.first, '2');
    await tester.pumpAndSettle();

    final roomTypeDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Room type',
    );
    final roomTypeTapTarget = find.descendant(
      of: roomTypeDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(roomTypeTapTarget.first);
    await tester.tap(roomTypeTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Double').first);
    await tester.pumpAndSettle();

    final mealPlanDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Meal plan',
    );
    final mealPlanTapTarget = find.descendant(
      of: mealPlanDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(mealPlanTapTarget.first);
    await tester.tap(mealPlanTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BB').first);
    await tester.pumpAndSettle();

    final applyButton = find.text('Apply');
    await tester.ensureVisible(applyButton);
    final applyRow = find
        .ancestor(of: applyButton, matching: find.byType(Row))
        .first;
    final applyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    await tester.enterText(applyInputs.first, '200');
    await tester.pumpAndSettle();
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Double'), findsAtLeastNWidgets(1));
    expect(find.text('BB'), findsAtLeastNWidgets(1));
    final rnCheckIcon = find.descendant(
      of: roomDetailsCard,
      matching: find.byIcon(Icons.check_circle),
    );
    expect(rnCheckIcon, findsAtLeastNWidgets(1));
    expect(find.text('2'), findsAtLeastNWidgets(1));
  });

  testWidgets('Edit restores daily rates and apply inputs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final exceptionText = details.exceptionAsString();
      if (exceptionText.contains('A RenderFlex overflowed by')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateAgentReservationScreen(reservationId: 'r1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();

    final roomDetailsHeader = find.text('Room details');
    final roomDetailsCard = find
        .ancestor(of: roomDetailsHeader, matching: find.byType(Card))
        .first;
    final noRoomsInput = find.descendant(
      of: roomDetailsCard,
      matching: find.byType(TextField),
    );
    await tester.enterText(noRoomsInput.first, '2');
    await tester.pumpAndSettle();

    final roomTypeDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Room type',
    );
    final roomTypeTapTarget = find.descendant(
      of: roomTypeDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(roomTypeTapTarget.first);
    await tester.tap(roomTypeTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Double').first);
    await tester.pumpAndSettle();

    final mealPlanDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Meal plan',
    );
    final mealPlanTapTarget = find.descendant(
      of: mealPlanDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(mealPlanTapTarget.first);
    await tester.tap(mealPlanTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BB').first);
    await tester.pumpAndSettle();

    final applyButton = find.text('Apply');
    await tester.ensureVisible(applyButton);
    final applyRow = find
        .ancestor(of: applyButton, matching: find.byType(Row))
        .first;
    final applyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    await tester.enterText(applyInputs.first, '200');
    await tester.pumpAndSettle();
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final editIcon = find
        .byIcon(Icons.edit_outlined, skipOffstage: false)
        .first;
    await tester.ensureVisible(editIcon);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    final refreshedApplyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    final firstApplyTextField = tester.widget<TextField>(
      refreshedApplyInputs.first,
    );
    expect(firstApplyTextField.controller?.text, '200');
    expect(find.text('200'), findsAtLeastNWidgets(1));
  });

  testWidgets('Add more defaults arrival date to latest hotel departure', (
    tester,
  ) async {
    final details = ReservationDetails(
      order: ReservationOrder(
        id: 'r1',
        reservationNo: 100,
        client: const Client(id: 1, name: 'Client 1', code: 'C1'),
        guestName: 'Guest',
        guestNationality: null,
        clientOptionDate: null,
        rmsInvoiceNo: null,
        createdAt: DateTime(2026, 4, 1),
      ),
      services: [
        ReservationServiceSummary(
          id: 's1',
          reservationId: 'r1',
          serviceNo: 1,
          type: ReservationServiceType.agent,
          displayNo: 'A1',
          totalSale: Decimal.parse('0'),
          totalCost: Decimal.parse('0'),
          createdAt: DateTime(2026, 4, 1),
          agentDetails: AgentReservationDraft(
            arrivalDate: DateTime(2026, 4, 12),
            departureDate: DateTime(2026, 4, 16),
            isManualRate: false,
            isPricesWithoutVat: false,
            hotelId: 1,
            hotelName: 'Hotel 1',
            hotelCity: null,
            hotelLocation: null,
            supplierId: null,
            supplierName: null,
            selectedRoomType: null,
            selectedMealPlan: null,
            roomRates: const [],
            roomsSummary: const [],
            totalPax: 0,
            totalSale: Decimal.parse('0'),
            totalCost: Decimal.parse('0'),
          ),
          generalDetails: null,
          transportationDetails: null,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reservationsRepositoryProvider.overrideWithValue(
            _FakeReservationsRepository(details: details),
          ),
        ],
        child: const MaterialApp(
          home: CreateAgentReservationScreen(reservationId: 'r1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final arrivalField = find.byWidgetPredicate(
      (widget) =>
          widget is CustomDatePickerField && widget.label == 'Arrival date',
    );
    expect(arrivalField, findsOneWidget);
    expect(
      find.descendant(of: arrivalField, matching: find.text('17/04/2026')),
      findsOneWidget,
    );
  });
}
