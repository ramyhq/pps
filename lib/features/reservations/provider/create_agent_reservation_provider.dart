import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';

final createAgentReservationProvider =
    NotifierProvider<
      CreateAgentReservationNotifier,
      CreateAgentReservationState
    >(CreateAgentReservationNotifier.new);

class CreateAgentReservationNotifier
    extends Notifier<CreateAgentReservationState> {
  static const List<String> roomTypeOptions = <String>[
    'Double',
    'Triple',
    'Quad',
    'Quent',
  ];

  static const List<String> mealPlanOptions = <String>[
    'BB',
    'HB',
    'FB',
    'AI',
    'RO',
  ];

  static const Map<String, int> _roomTypePaxMap = <String, int>{
    'Double': 2,
    'Triple': 3,
    'Trip': 3,
    'Quad': 4,
    'Quent': 5,
    'Quint': 5,
  };

  static int paxPerRoomFor(String? roomType) {
    return _roomTypePaxMap[roomType] ?? 2;
  }

  @override
  CreateAgentReservationState build() {
    final initial = CreateAgentReservationState.initial();
    return _syncRoomRatesWithDates(initial);
  }

  void onArrivalDateChanged({
    required DateTime date,
    required int desiredNights,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final next = state.copyWith(
      arrivalDate: normalizedDate,
      //CALCULATIONS تاريخ المغادرة = تاريخ الوصول + عدد الليالي المطلوبة.
      departureDate: normalizedDate.add(Duration(days: desiredNights)),
    );
    state = _syncRoomRatesWithDates(next);
  }

  void onArrivalDateChangedPreserveRates({
    required DateTime date,
    required int desiredNights,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final next = state.copyWith(
      arrivalDate: normalizedDate,
      departureDate: normalizedDate.add(Duration(days: desiredNights)),
    );
    state = _preserveRoomRatesAfterDatesChange(next);
  }

  void onArrivalDateChangedWithRateReset({
    required DateTime date,
    required int desiredNights,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final next = state.copyWith(
      arrivalDate: normalizedDate,
      departureDate: normalizedDate.add(Duration(days: desiredNights)),
    );
    state = _resetRoomRatesAfterDateChange(next);
  }

  void onDepartureDateChanged(DateTime date) {
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null || !date.isAfter(arrivalDate)) {
      return;
    }
    final next = state.copyWith(
      departureDate: DateTime(date.year, date.month, date.day),
    );
    state = _syncRoomRatesWithDates(next);
  }

  void onDepartureDateChangedPreserveRates(DateTime date) {
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null || !date.isAfter(arrivalDate)) {
      return;
    }
    final next = state.copyWith(
      departureDate: DateTime(date.year, date.month, date.day),
    );
    state = _preserveRoomRatesAfterDatesChange(next);
  }

  void onDepartureDateChangedWithRateReset(DateTime date) {
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null || !date.isAfter(arrivalDate)) {
      return;
    }
    final next = state.copyWith(
      departureDate: DateTime(date.year, date.month, date.day),
    );
    state = _resetRoomRatesAfterDateChange(next);
  }

  void onNightsChanged(int nights) {
    if (nights < 1) {
      return;
    }
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null) {
      return;
    }
    final next = state.copyWith(
      //CALCULATIONS عند تعديل عدد الليالي يتم اشتقاق تاريخ المغادرة = تاريخ الوصول + عدد الليالي.
      departureDate: arrivalDate.add(Duration(days: nights)),
    );
    state = _syncRoomRatesWithDates(next);
  }

  void onNightsChangedPreserveRates(int nights) {
    if (nights < 1) {
      return;
    }
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null) {
      return;
    }
    final next = state.copyWith(
      departureDate: arrivalDate.add(Duration(days: nights)),
    );
    state = _preserveRoomRatesAfterDatesChange(next);
  }

  void onNightsChangedWithRateReset(int nights) {
    if (nights < 1) {
      return;
    }
    final arrivalDate = state.arrivalDate;
    if (arrivalDate == null) {
      return;
    }
    final next = state.copyWith(
      departureDate: arrivalDate.add(Duration(days: nights)),
    );
    state = _resetRoomRatesAfterDateChange(next);
  }

  void setManualRate(bool value) {
    state = state.copyWith(isManualRate: false);
  }

  void setReservationContext({
    required String? reservationId,
    required int? reservationNo,
    required int? clientId,
    required DateTime? clientOptionDate,
    String? guestName,
  }) {
    state = state.copyWith(
      reservationId: reservationId,
      reservationNo: reservationNo,
      selectedClientId: clientId,
      clientOptionDate: clientOptionDate,
      guestName: guestName,
    );
  }

  void startEditingService({
    required String serviceId,
    required AgentReservationDraft draft,
  }) {
    final draftRates = draft.roomRates
        .map(
          (rate) => RoomDayRate(
            date: rate.date,
            saleRoom: rate.saleRoom,
            saleMealPerPax: rate.saleMealPerPax,
            costRoom: rate.costRoom,
            costMealPerPax: rate.costMealPerPax,
          ),
        )
        .toList(growable: false);
    final clearedDraftRates = draftRates
        .map(
          (rate) => rate.copyWith(
            saleRoom: '',
            saleMealPerPax: '',
            costRoom: '',
            costMealPerPax: '',
          ),
        )
        .toList(growable: false);

    List<RoomDayRate> toRoomDayRates(List<AgentReservationRoomRate> rates) {
      return rates
          .map(
            (rate) => RoomDayRate(
              date: rate.date,
              saleRoom: rate.saleRoom,
              saleMealPerPax: rate.saleMealPerPax,
              costRoom: rate.costRoom,
              costMealPerPax: rate.costMealPerPax,
            ),
          )
          .toList(growable: false);
    }

    final next = state.copyWith(
      editingServiceId: serviceId,
      arrivalDate: draft.arrivalDate,
      departureDate: draft.departureDate,
      isManualRate: false,
      isPricesWithoutVat: draft.isPricesWithoutVat,
      hotelId: draft.hotelId,
      hotelName: draft.hotelName,
      hotelCity: draft.hotelCity,
      supplierId: draft.supplierId,
      supplierName: draft.supplierName,
      selectedRoomType: null,
      selectedMealPlan: null,
      selectedWeekdays: <int>{},
      roomRates: clearedDraftRates,
      addedRooms: draft.roomsSummary
          .map(
            (room) => AddedRoomSummary(
              numberOfRooms: room.numberOfRooms,
              totalRn: room.totalRn,
              roomType: room.roomType,
              mealPlan: room.mealPlan,
              pax: room.pax,
              totalSale: room.totalSale,
              totalCost: room.totalCost,
              roomRates: room.roomRates.isEmpty
                  ? draftRates
                  : toRoomDayRates(room.roomRates),
              isManualRate: false,
            ),
          )
          .toList(growable: false),
      clearLastSaveError: true,
      clearLastSavedServiceDisplayNo: true,
      clearEditingRoomIndex: true,
    );
    state = _syncRoomRatesWithDates(next);
  }

  void startNewReservation() {
    final next = _syncRoomRatesWithDates(CreateAgentReservationState.initial());
    state = next;
  }

  void startNewServiceEntry() {
    final now = DateTime.now();
    final arrivalDate = DateTime(now.year, now.month, now.day);
    final next = CreateAgentReservationState(
      reservationId: null,
      reservationNo: null,
      editingServiceId: null,
      editingRoomIndex: null,
      roomRatesRevision: state.roomRatesRevision + 1,
      selectedClientId: state.selectedClientId,
      clientOptionDate: state.clientOptionDate,
      guestName: state.guestName,
      guestNationality: state.guestNationality,
      arrivalDate: arrivalDate,
      departureDate: arrivalDate.add(const Duration(days: 1)),
      isManualRate: false,
      isPricesWithoutVat: false,
      hotelId: null,
      hotelName: null,
      hotelCity: null,
      supplierId: null,
      supplierName: null,
      selectedRoomType: null,
      selectedMealPlan: null,
      selectedWeekdays: <int>{},
      roomRates: const <RoomDayRate>[],
      addedRooms: const <AddedRoomSummary>[],
      isSaving: false,
      requiresRoomRatesReentry: false,
      lastSaveError: null,
      lastSavedReservationId: state.lastSavedReservationId,
      lastSavedServiceDisplayNo: null,
    );
    state = _syncRoomRatesWithDates(next);
  }

  void setSelectedClientId(int? value) {
    state = state.copyWith(selectedClientId: value);
  }

  void setClientOptionDate(DateTime? value) {
    state = state.copyWith(clientOptionDate: value);
  }

  void setGuestName(String? value) {
    final next = value?.trim();
    state = state.copyWith(
      guestName: next == null || next.isEmpty ? null : next,
    );
  }

  void setHotelSelection({
    required int? hotelId,
    required String? hotelName,
    required String? hotelCity,
  }) {
    state = state.copyWith(
      hotelId: hotelId,
      hotelName: hotelName,
      hotelCity: hotelCity,
    );
  }

  void setSupplierSelection({
    required int? supplierId,
    required String? supplierName,
  }) {
    state = state.copyWith(supplierId: supplierId, supplierName: supplierName);
  }

  void setPricesWithoutVat(bool value) {
    state = state.copyWith(isPricesWithoutVat: value);
  }

  void setSelectedRoomType(String? value) {
    state = state.copyWith(selectedRoomType: value);
  }

  void setSelectedMealPlan(String? value) {
    state = state.copyWith(selectedMealPlan: value);
  }

  void applyRatesToAllDays({
    required String saleRoom,
    required String saleMealPerPax,
    required String costRoom,
    required String costMealPerPax,
  }) {
    if (state.roomRates.isEmpty) {
      return;
    }
    final selectedWeekdays = state.selectedWeekdays;
    final nextRates = state.roomRates
        .map((rate) {
          if (selectedWeekdays.isNotEmpty &&
              !selectedWeekdays.contains(rate.date.weekday)) {
            return rate;
          }
          return rate.copyWith(
            saleRoom: saleRoom,
            saleMealPerPax: saleMealPerPax,
            costRoom: costRoom,
            costMealPerPax: costMealPerPax,
          );
        })
        .toList(growable: false);
    final nextRequiresReentry =
        state.requiresRoomRatesReentry && !_hasAnyRateValue(nextRates);
    state = state.copyWith(
      roomRates: nextRates,
      roomRatesRevision: state.roomRatesRevision + 1,
      requiresRoomRatesReentry: nextRequiresReentry,
    );
  }

  void setSelectedWeekdays(Set<int> weekdays) {
    state = state.copyWith(selectedWeekdays: weekdays);
  }

  void updateSaleRoom({required DateTime date, required String value}) {
    _updateRoomRate(
      date: date,
      mapper: (rate) => rate.copyWith(saleRoom: value),
    );
  }

  void updateSaleMealPerPax({required DateTime date, required String value}) {
    _updateRoomRate(
      date: date,
      mapper: (rate) => rate.copyWith(saleMealPerPax: value),
    );
  }

  void updateCostRoom({required DateTime date, required String value}) {
    _updateRoomRate(
      date: date,
      mapper: (rate) => rate.copyWith(costRoom: value),
    );
  }

  void updateCostMealPerPax({required DateTime date, required String value}) {
    _updateRoomRate(
      date: date,
      mapper: (rate) => rate.copyWith(costMealPerPax: value),
    );
  }

  void clearRoomFormState() {
    final clearedRates = state.roomRates
        .map(
          (rate) => rate.copyWith(
            saleRoom: '',
            saleMealPerPax: '',
            costRoom: '',
            costMealPerPax: '',
          ),
        )
        .toList(growable: false);
    state = state.copyWith(
      clearEditingRoomIndex: true,
      isManualRate: false,
      selectedRoomType: null,
      selectedMealPlan: null,
      selectedWeekdays: <int>{},
      roomRates: clearedRates,
      roomRatesRevision: state.roomRatesRevision + 1,
      requiresRoomRatesReentry: false,
    );
  }

  void clearRoomDetailsForNextEntry() {
    state = state.copyWith(
      clearEditingRoomIndex: true,
      isManualRate: false,
      selectedRoomType: null,
      selectedMealPlan: null,
      selectedWeekdays: <int>{},
    );
  }

  void startEditingRoom({required int index}) {
    if (index < 0 || index >= state.addedRooms.length) {
      return;
    }
    state = state.copyWith(editingRoomIndex: index);
  }

  void restoreRoomRatesFromSummary({required List<RoomDayRate> roomRates}) {
    if (roomRates.isEmpty) {
      return;
    }
    if (state.roomRates.isEmpty) {
      final next = _syncRoomRatesWithDates(
        state.copyWith(
          roomRates: roomRates.toList(growable: false),
          roomRatesRevision: state.roomRatesRevision + 1,
          requiresRoomRatesReentry:
              state.requiresRoomRatesReentry && !_hasAnyRateValue(roomRates),
        ),
      );
      state = next;
      return;
    }
    final byDateKey = <int, RoomDayRate>{
      for (final rate in roomRates)
        DateTime(
          rate.date.year,
          rate.date.month,
          rate.date.day,
        ).millisecondsSinceEpoch: rate,
    };
    final nextRates = state.roomRates
        .map((rate) {
          final key = DateTime(
            rate.date.year,
            rate.date.month,
            rate.date.day,
          ).millisecondsSinceEpoch;
          final snapshot = byDateKey[key];
          if (snapshot == null) {
            return rate;
          }
          return rate.copyWith(
            saleRoom: snapshot.saleRoom,
            saleMealPerPax: snapshot.saleMealPerPax,
            costRoom: snapshot.costRoom,
            costMealPerPax: snapshot.costMealPerPax,
          );
        })
        .toList(growable: false);
    final nextRequiresReentry =
        state.requiresRoomRatesReentry && !_hasAnyRateValue(nextRates);
    state = state.copyWith(
      roomRates: nextRates,
      roomRatesRevision: state.roomRatesRevision + 1,
      requiresRoomRatesReentry: nextRequiresReentry,
    );
  }

  bool addRoomToSummary({required int roomsCount}) {
    if (roomsCount < 1 ||
        state.nightsCount < 1 ||
        state.selectedRoomType == null ||
        state.selectedMealPlan == null) {
      return false;
    }
    final paxPerRoom = _roomTypePaxMap[state.selectedRoomType] ?? 2;
    //CALCULATIONS إجمالي الركاب = عدد الغرف × عدد الأفراد لكل غرفة حسب نوع الغرفة.
    final pax = roomsCount * paxPerRoom;
    //CALCULATIONS إجمالي RN = عدد الغرف × عدد الليالي الحالية.
    final totalRn = roomsCount * state.nightsCount;
    final totals = _calculateTotals(roomCount: roomsCount, pax: pax);
    final snapshotRates = state.roomRates.toList(growable: false);
    final nextRooms = <AddedRoomSummary>[
      ...state.addedRooms,
      AddedRoomSummary(
        numberOfRooms: roomsCount,
        totalRn: totalRn,
        roomType: state.selectedRoomType!,
        mealPlan: state.selectedMealPlan!,
        pax: pax,
        totalSale: totals.totalSale,
        totalCost: totals.totalCost,
        roomRates: snapshotRates,
        isManualRate: state.isManualRate,
      ),
    ];
    state = state.copyWith(addedRooms: nextRooms, clearEditingRoomIndex: true);
    return true;
  }

  bool updateRoomInSummary({required int index, required int roomsCount}) {
    if (index < 0 || index >= state.addedRooms.length) {
      return false;
    }
    if (roomsCount < 1 ||
        state.nightsCount < 1 ||
        state.selectedRoomType == null ||
        state.selectedMealPlan == null) {
      return false;
    }
    final paxPerRoom = _roomTypePaxMap[state.selectedRoomType] ?? 2;
    final pax = roomsCount * paxPerRoom;
    final totalRn = roomsCount * state.nightsCount;
    final totals = _calculateTotals(roomCount: roomsCount, pax: pax);
    final snapshotRates = state.roomRates.toList(growable: false);
    final nextRooms = <AddedRoomSummary>[...state.addedRooms];
    nextRooms[index] = AddedRoomSummary(
      numberOfRooms: roomsCount,
      totalRn: totalRn,
      roomType: state.selectedRoomType!,
      mealPlan: state.selectedMealPlan!,
      pax: pax,
      totalSale: totals.totalSale,
      totalCost: totals.totalCost,
      roomRates: snapshotRates,
      isManualRate: state.isManualRate,
    );
    state = state.copyWith(addedRooms: nextRooms, clearEditingRoomIndex: true);
    return true;
  }

  void removeRoomFromSummary(int index) {
    if (index < 0 || index >= state.addedRooms.length) {
      return;
    }
    final nextRooms = <AddedRoomSummary>[...state.addedRooms]..removeAt(index);
    final editingIndex = state.editingRoomIndex;
    final nextEditingIndex = editingIndex == null
        ? null
        : editingIndex == index
        ? null
        : editingIndex > index
        ? editingIndex - 1
        : editingIndex;
    state = state.copyWith(
      addedRooms: nextRooms,
      editingRoomIndex: nextEditingIndex,
    );
  }

  Future<bool> saveReservation({required bool clearForNewEntry}) async {
    final existingReservationId = state.reservationId;
    final editingServiceId = state.editingServiceId;
    if (editingServiceId != null && existingReservationId == null) {
      state = state.copyWith(
        lastSaveError: 'Missing reservation id for edit.',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
    if (existingReservationId == null && state.selectedClientId == null) {
      state = state.copyWith(
        lastSaveError: 'Please select client before save.',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
    if (state.arrivalDate == null ||
        state.departureDate == null ||
        state.nightsCount < 1) {
      state = state.copyWith(
        lastSaveError: 'Please select arrival and departure dates.',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
    if (state.addedRooms.isEmpty) {
      state = state.copyWith(
        lastSaveError: 'Please add at least one room before save.',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
    if (state.requiresRoomRatesReentry) {
      state = state.copyWith(
        lastSaveError: 'errorRoomPricesReset',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
    final zero = Decimal.parse('0');
    if (state.totalSale == zero && state.totalCost == zero) {
      state = state.copyWith(
        lastSaveError: 'errorRoomPricesZero',
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearLastSaveError: true,
      clearLastSavedReservationId: true,
      clearLastSavedServiceDisplayNo: true,
    );

    final repository = ref.read(reservationsRepositoryProvider);

    try {
      var reservationId = existingReservationId;
      if (reservationId == null) {
        final createdOrder = await repository.createReservationOrder(
          CreateReservationOrderDraft(
            clientId: state.selectedClientId!,
            guestName: state.guestName,
            guestNationality: state.guestNationality,
            clientOptionDate: state.clientOptionDate,
          ),
        );
        reservationId = createdOrder.id;
      } else {
        await repository.updateReservationMainInfo(
          reservationId: reservationId,
          clientId: state.selectedClientId!,
          guestName: state.guestName,
          guestNationality: state.guestNationality,
          clientOptionDate: state.clientOptionDate,
        );
      }

      final savedService = editingServiceId != null
          ? await repository.updateAgentService(
              serviceId: editingServiceId,
              draft: _toDomainDraft(state),
            )
          : await repository.addAgentService(
              reservationId: reservationId,
              draft: _toDomainDraft(state),
            );

      var nextState = state.copyWith(
        isSaving: false,
        reservationId: reservationId,
        lastSavedReservationId: reservationId,
        lastSavedServiceDisplayNo: savedService.displayNo,
        clearLastSaveError: true,
      );
      if (clearForNewEntry) {
        nextState = _clearServiceForNewEntry(nextState);
      }
      state = nextState;
      return true;
    } on Exception catch (error) {
      state = state.copyWith(
        isSaving: false,
        lastSaveError: error.toString(),
        clearLastSavedReservationId: true,
        clearLastSavedServiceDisplayNo: true,
      );
      return false;
    }
  }

  void _updateRoomRate({
    required DateTime date,
    required RoomDayRate Function(RoomDayRate rate) mapper,
  }) {
    final dateKey = DateTime(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;
    final nextRates = state.roomRates
        .map((rate) {
          final currentKey = DateTime(
            rate.date.year,
            rate.date.month,
            rate.date.day,
          ).millisecondsSinceEpoch;
          if (currentKey == dateKey) {
            return mapper(rate);
          }
          return rate;
        })
        .toList(growable: false);
    final nextRequiresReentry =
        state.requiresRoomRatesReentry && !_hasAnyRateValue(nextRates);
    state = state.copyWith(
      roomRates: nextRates,
      requiresRoomRatesReentry: nextRequiresReentry,
    );
  }

  CreateAgentReservationState _preserveRoomRatesAfterDatesChange(
    CreateAgentReservationState source,
  ) {
    if (source.arrivalDate == null || source.nightsCount < 1) {
      return source.copyWith(roomRates: const <RoomDayRate>[]);
    }

    final arrivalDate = source.arrivalDate!;
    final nightsCount = source.nightsCount;
    final previousRates = state.roomRates;
    final preserved = <RoomDayRate>[];
    for (var i = 0; i < nightsCount; i++) {
      final date = arrivalDate.add(Duration(days: i));
      final previous = i < previousRates.length ? previousRates[i] : null;
      preserved.add(
        RoomDayRate(
          date: date,
          saleRoom: previous?.saleRoom ?? '',
          saleMealPerPax: previous?.saleMealPerPax ?? '',
          costRoom: previous?.costRoom ?? '',
          costMealPerPax: previous?.costMealPerPax ?? '',
        ),
      );
    }

    final nextRooms = state.addedRooms
        .map((room) {
          final previousRoomRates = room.roomRates;
          final preservedRoomRates = <RoomDayRate>[];
          for (var i = 0; i < nightsCount; i++) {
            final date = arrivalDate.add(Duration(days: i));
            final previous = i < previousRoomRates.length
                ? previousRoomRates[i]
                : null;
            preservedRoomRates.add(
              RoomDayRate(
                date: date,
                saleRoom: previous?.saleRoom ?? '',
                saleMealPerPax: previous?.saleMealPerPax ?? '',
                costRoom: previous?.costRoom ?? '',
                costMealPerPax: previous?.costMealPerPax ?? '',
              ),
            );
          }
          final paxPerRoom = paxPerRoomFor(room.roomType);
          final pax = room.numberOfRooms * paxPerRoom;
          final totalRn = room.numberOfRooms * nightsCount;
          final totals = _calculateTotalsForRates(
            roomRates: preservedRoomRates,
            roomCount: room.numberOfRooms,
            pax: pax,
          );
          return AddedRoomSummary(
            numberOfRooms: room.numberOfRooms,
            totalRn: totalRn,
            roomType: room.roomType,
            mealPlan: room.mealPlan,
            pax: pax,
            totalSale: totals.totalSale,
            totalCost: totals.totalCost,
            roomRates: preservedRoomRates,
            isManualRate: room.isManualRate,
          );
        })
        .toList(growable: false);

    return source.copyWith(
      roomRates: preserved,
      addedRooms: nextRooms,
      roomRatesRevision: state.roomRatesRevision + 1,
      requiresRoomRatesReentry: false,
      clearLastSaveError: true,
    );
  }

  CreateAgentReservationState _resetRoomRatesAfterDateChange(
    CreateAgentReservationState source,
  ) {
    final synced = _syncRoomRatesWithDates(source);
    final clearedRates = synced.roomRates
        .map(
          (rate) => rate.copyWith(
            saleRoom: '',
            saleMealPerPax: '',
            costRoom: '',
            costMealPerPax: '',
          ),
        )
        .toList(growable: false);

    final nextRooms = synced.addedRooms
        .map((room) {
          final clearedRoomRates = room.roomRates
              .map(
                (rate) => rate.copyWith(
                  saleRoom: '',
                  saleMealPerPax: '',
                  costRoom: '',
                  costMealPerPax: '',
                ),
              )
              .toList(growable: false);
          final totals = _calculateTotalsForRates(
            roomRates: clearedRoomRates,
            roomCount: room.numberOfRooms,
            pax: room.pax,
          );
          return AddedRoomSummary(
            numberOfRooms: room.numberOfRooms,
            totalRn: room.totalRn,
            roomType: room.roomType,
            mealPlan: room.mealPlan,
            pax: room.pax,
            totalSale: totals.totalSale,
            totalCost: totals.totalCost,
            roomRates: clearedRoomRates,
            isManualRate: room.isManualRate,
          );
        })
        .toList(growable: false);

    return synced.copyWith(
      roomRates: clearedRates,
      addedRooms: nextRooms,
      roomRatesRevision: synced.roomRatesRevision + 1,
      requiresRoomRatesReentry: true,
      clearLastSaveError: true,
    );
  }

  CreateAgentReservationState _syncRoomRatesWithDates(
    CreateAgentReservationState source,
  ) {
    if (source.arrivalDate == null || source.nightsCount < 1) {
      return source.copyWith(roomRates: const <RoomDayRate>[]);
    }
    final arrivalDate = source.arrivalDate!;
    final nightsCount = source.nightsCount;
    final existingByDate = <int, RoomDayRate>{
      for (final rate in source.roomRates)
        DateTime(
          rate.date.year,
          rate.date.month,
          rate.date.day,
        ).millisecondsSinceEpoch: rate,
    };
    final nextRates = <RoomDayRate>[];
    for (var i = 0; i < nightsCount; i++) {
      //CALCULATIONS تاريخ صف الليلة = تاريخ الوصول + رقم الليلة داخل الحلقة.
      final date = arrivalDate.add(Duration(days: i));
      final dateKey = DateTime(
        date.year,
        date.month,
        date.day,
      ).millisecondsSinceEpoch;
      nextRates.add(existingByDate[dateKey] ?? RoomDayRate(date: date));
    }

    final nextRooms = source.addedRooms.isEmpty
        ? source.addedRooms
        : source.addedRooms
              .map(
                (room) => _syncAddedRoomSummaryWithDates(
                  room,
                  arrivalDate: arrivalDate,
                  nightsCount: nightsCount,
                  fallbackRates: nextRates,
                ),
              )
              .toList(growable: false);

    return source.copyWith(roomRates: nextRates, addedRooms: nextRooms);
  }

  AddedRoomSummary _syncAddedRoomSummaryWithDates(
    AddedRoomSummary room, {
    required DateTime arrivalDate,
    required int nightsCount,
    required List<RoomDayRate> fallbackRates,
  }) {
    final paxPerRoom = paxPerRoomFor(room.roomType);
    final pax = room.numberOfRooms * paxPerRoom;
    final totalRn = room.numberOfRooms * nightsCount;
    final baseRates = room.roomRates.isEmpty ? fallbackRates : room.roomRates;
    final syncedRates = _syncRoomRatesListWithDates(
      roomRates: baseRates,
      arrivalDate: arrivalDate,
      nightsCount: nightsCount,
    );
    final totals = _calculateTotalsForRates(
      roomRates: syncedRates,
      roomCount: room.numberOfRooms,
      pax: pax,
    );
    return AddedRoomSummary(
      numberOfRooms: room.numberOfRooms,
      totalRn: totalRn,
      roomType: room.roomType,
      mealPlan: room.mealPlan,
      pax: pax,
      totalSale: totals.totalSale,
      totalCost: totals.totalCost,
      roomRates: syncedRates,
      isManualRate: room.isManualRate,
    );
  }

  List<RoomDayRate> _syncRoomRatesListWithDates({
    required List<RoomDayRate> roomRates,
    required DateTime arrivalDate,
    required int nightsCount,
  }) {
    if (nightsCount < 1) {
      return const <RoomDayRate>[];
    }
    final byDateKey = <int, RoomDayRate>{
      for (final rate in roomRates)
        DateTime(
          rate.date.year,
          rate.date.month,
          rate.date.day,
        ).millisecondsSinceEpoch: rate,
    };
    final nextRates = <RoomDayRate>[];
    for (var i = 0; i < nightsCount; i++) {
      final date = arrivalDate.add(Duration(days: i));
      final dateKey = DateTime(
        date.year,
        date.month,
        date.day,
      ).millisecondsSinceEpoch;
      nextRates.add(byDateKey[dateKey] ?? RoomDayRate(date: date));
    }
    return nextRates;
  }

  RoomTotals _calculateTotalsForRates({
    required List<RoomDayRate> roomRates,
    required int roomCount,
    required int pax,
  }) {
    var totalSale = Decimal.parse('0');
    var totalCost = Decimal.parse('0');
    final roomCountDecimal = Decimal.fromInt(roomCount);
    final paxDecimal = Decimal.fromInt(pax);

    for (final rate in roomRates) {
      final saleRoom = _parseMoney(rate.saleRoom);
      final saleMealPerPax = _parseMoney(rate.saleMealPerPax);
      final costRoom = _parseMoney(rate.costRoom);
      final costMealPerPax = _parseMoney(rate.costMealPerPax);

      totalSale =
          totalSale +
          (saleRoom * roomCountDecimal) +
          (saleMealPerPax * paxDecimal);
      totalCost =
          totalCost +
          (costRoom * roomCountDecimal) +
          (costMealPerPax * paxDecimal);
    }

    return RoomTotals(totalSale: totalSale, totalCost: totalCost);
  }

  RoomTotals _calculateTotals({required int roomCount, required int pax}) {
    var totalSale = Decimal.parse('0');
    var totalCost = Decimal.parse('0');

    for (final rate in state.roomRates) {
      final saleRoom = _parseMoney(rate.saleRoom);
      final saleMealPerPax = _parseMoney(rate.saleMealPerPax);
      final costRoom = _parseMoney(rate.costRoom);
      final costMealPerPax = _parseMoney(rate.costMealPerPax);

      //CALCULATIONS تحويل عدد الغرف إلى Decimal لاستخدامه في الضرب المالي الدقيق.
      final roomCountDecimal = Decimal.fromInt(roomCount);
      //CALCULATIONS تحويل إجمالي الركاب إلى Decimal لاستخدامه في ضرب الوجبة لكل راكب.
      final paxDecimal = Decimal.fromInt(pax);

      //CALCULATIONS إجمالي البيع لليوم = إجمالي البيع السابق + (سعر الغرفة × عدد الغرف) + (سعر الوجبة لكل راكب × إجمالي الركاب).
      totalSale =
          totalSale +
          (saleRoom * roomCountDecimal) +
          (saleMealPerPax * paxDecimal);
      //CALCULATIONS إجمالي التكلفة لليوم = إجمالي التكلفة السابق + (تكلفة الغرفة × عدد الغرف) + (تكلفة الوجبة لكل راكب × إجمالي الركاب).
      totalCost =
          totalCost +
          (costRoom * roomCountDecimal) +
          (costMealPerPax * paxDecimal);
    }

    return RoomTotals(totalSale: totalSale, totalCost: totalCost);
  }

  Decimal _parseMoney(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return Decimal.parse('0');
    }
    return Decimal.tryParse(normalized) ?? Decimal.parse('0');
  }

  AgentReservationDraft _toDomainDraft(CreateAgentReservationState source) {
    List<RoomDayRate> fallbackRoomRates() {
      if (_hasAnyRateValue(source.roomRates)) {
        return source.roomRates;
      }
      for (final room in source.addedRooms) {
        if (_hasAnyRateValue(room.roomRates)) {
          return room.roomRates;
        }
      }
      return source.roomRates;
    }

    final roomRatesSnapshot = fallbackRoomRates();
    return AgentReservationDraft(
      arrivalDate: source.arrivalDate!,
      departureDate: source.departureDate!,
      isManualRate: source.isManualRate,
      isPricesWithoutVat: source.isPricesWithoutVat,
      hotelId: source.hotelId,
      hotelName: source.hotelName,
      hotelCity: source.hotelCity,
      supplierId: source.supplierId,
      supplierName: source.supplierName,
      selectedRoomType: source.selectedRoomType,
      selectedMealPlan: source.selectedMealPlan,
      roomRates: roomRatesSnapshot
          .map(
            (rate) => AgentReservationRoomRate(
              date: rate.date,
              saleRoom: rate.saleRoom,
              saleMealPerPax: rate.saleMealPerPax,
              costRoom: rate.costRoom,
              costMealPerPax: rate.costMealPerPax,
            ),
          )
          .toList(growable: false),
      roomsSummary: source.addedRooms
          .map(
            (room) => AgentReservationRoomSummary(
              numberOfRooms: room.numberOfRooms,
              totalRn: room.totalRn,
              roomType: room.roomType,
              mealPlan: room.mealPlan,
              pax: room.pax,
              totalSale: room.totalSale,
              totalCost: room.totalCost,
              roomRates: room.roomRates
                  .map(
                    (rate) => AgentReservationRoomRate(
                      date: rate.date,
                      saleRoom: rate.saleRoom,
                      saleMealPerPax: rate.saleMealPerPax,
                      costRoom: rate.costRoom,
                      costMealPerPax: rate.costMealPerPax,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      totalPax: source.totalPax,
      totalSale: source.totalSale,
      totalCost: source.totalCost,
    );
  }

  bool _hasAnyRateValue(List<RoomDayRate> rates) {
    for (final rate in rates) {
      if (rate.saleRoom.trim().isNotEmpty ||
          rate.saleMealPerPax.trim().isNotEmpty ||
          rate.costRoom.trim().isNotEmpty ||
          rate.costMealPerPax.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  CreateAgentReservationState _clearServiceForNewEntry(
    CreateAgentReservationState source,
  ) {
    final clearedRates = source.roomRates
        .map(
          (rate) => rate.copyWith(
            saleRoom: '',
            saleMealPerPax: '',
            costRoom: '',
            costMealPerPax: '',
          ),
        )
        .toList(growable: false);
    return source.copyWith(
      clearEditingServiceId: true,
      clearHotelId: true,
      clearHotelName: true,
      clearHotelCity: true,
      clearSupplierId: true,
      clearSupplierName: true,
      selectedRoomType: null,
      selectedMealPlan: null,
      roomRates: clearedRates,
      addedRooms: const <AddedRoomSummary>[],
      roomRatesRevision: source.roomRatesRevision + 1,
      clearLastSaveError: true,
      requiresRoomRatesReentry: false,
    );
  }
}

class CreateAgentReservationState {
  const CreateAgentReservationState({
    required this.reservationId,
    required this.reservationNo,
    required this.editingServiceId,
    required this.editingRoomIndex,
    required this.roomRatesRevision,
    required this.selectedClientId,
    required this.clientOptionDate,
    required this.guestName,
    required this.guestNationality,
    required this.arrivalDate,
    required this.departureDate,
    required this.isManualRate,
    required this.isPricesWithoutVat,
    required this.hotelId,
    required this.hotelName,
    required this.hotelCity,
    required this.supplierId,
    required this.supplierName,
    required this.selectedRoomType,
    required this.selectedMealPlan,
    required this.selectedWeekdays,
    required this.roomRates,
    required this.addedRooms,
    required this.isSaving,
    required this.requiresRoomRatesReentry,
    required this.lastSaveError,
    required this.lastSavedReservationId,
    required this.lastSavedServiceDisplayNo,
  });

  factory CreateAgentReservationState.initial() {
    final now = DateTime.now();
    final arrivalDate = DateTime(now.year, now.month, now.day);
    return CreateAgentReservationState(
      reservationId: null,
      reservationNo: null,
      editingServiceId: null,
      editingRoomIndex: null,
      roomRatesRevision: 0,
      selectedClientId: null,
      clientOptionDate: null,
      guestName: null,
      guestNationality: null,
      arrivalDate: arrivalDate,
      departureDate: arrivalDate.add(const Duration(days: 1)),
      isManualRate: false,
      isPricesWithoutVat: false,
      hotelId: null,
      hotelName: null,
      hotelCity: null,
      supplierId: null,
      supplierName: null,
      selectedRoomType: null,
      selectedMealPlan: null,
      selectedWeekdays: <int>{},
      roomRates: <RoomDayRate>[],
      addedRooms: <AddedRoomSummary>[],
      isSaving: false,
      requiresRoomRatesReentry: false,
      lastSaveError: null,
      lastSavedReservationId: null,
      lastSavedServiceDisplayNo: null,
    );
  }

  final String? reservationId;
  final int? reservationNo;
  final String? editingServiceId;
  final int? editingRoomIndex;
  final int roomRatesRevision;
  final int? selectedClientId;
  final DateTime? clientOptionDate;
  final String? guestName;
  final String? guestNationality;
  final DateTime? arrivalDate;
  final DateTime? departureDate;
  final bool isManualRate;
  final bool isPricesWithoutVat;
  final int? hotelId;
  final String? hotelName;
  final String? hotelCity;
  final int? supplierId;
  final String? supplierName;
  final String? selectedRoomType;
  final String? selectedMealPlan;
  final Set<int> selectedWeekdays;
  final List<RoomDayRate> roomRates;
  final List<AddedRoomSummary> addedRooms;
  final bool isSaving;
  final bool requiresRoomRatesReentry;
  final String? lastSaveError;
  final String? lastSavedReservationId;
  final String? lastSavedServiceDisplayNo;

  int get nightsCount {
    final arrivalDate = this.arrivalDate;
    final departureDate = this.departureDate;
    if (arrivalDate == null || departureDate == null) {
      return 0;
    }
    //CALCULATIONS عدد الليالي = تاريخ المغادرة - تاريخ الوصول بالأيام.
    final diff = departureDate.difference(arrivalDate).inDays;
    return diff > 0 ? diff : 0;
  }

  //CALCULATIONS إجمالي الركاب في الخدمة = مجموع pax لكل صف غرفة مضاف.
  int get totalPax => addedRooms.fold<int>(0, (sum, room) => sum + room.pax);

  //CALCULATIONS إجمالي البيع في الخدمة = مجموع totalSale لكل صف غرفة مضاف.
  Decimal get totalSale => addedRooms.fold<Decimal>(
    Decimal.parse('0'),
    (sum, room) => sum + room.totalSale,
  );

  //CALCULATIONS إجمالي التكلفة في الخدمة = مجموع totalCost لكل صف غرفة مضاف.
  Decimal get totalCost => addedRooms.fold<Decimal>(
    Decimal.parse('0'),
    (sum, room) => sum + room.totalCost,
  );

  CreateAgentReservationState copyWith({
    String? reservationId,
    bool clearReservationId = false,
    int? reservationNo,
    bool clearReservationNo = false,
    String? editingServiceId,
    bool clearEditingServiceId = false,
    int? editingRoomIndex,
    bool clearEditingRoomIndex = false,
    int? roomRatesRevision,
    int? selectedClientId,
    bool clearSelectedClientId = false,
    DateTime? clientOptionDate,
    bool clearClientOptionDate = false,
    String? guestName,
    bool clearGuestName = false,
    String? guestNationality,
    bool clearGuestNationality = false,
    DateTime? arrivalDate,
    bool clearArrivalDate = false,
    DateTime? departureDate,
    bool clearDepartureDate = false,
    bool? isManualRate,
    bool? isPricesWithoutVat,
    int? hotelId,
    bool clearHotelId = false,
    String? hotelName,
    bool clearHotelName = false,
    String? hotelCity,
    bool clearHotelCity = false,
    int? supplierId,
    bool clearSupplierId = false,
    String? supplierName,
    bool clearSupplierName = false,
    String? selectedRoomType,
    bool clearSelectedRoomType = false,
    String? selectedMealPlan,
    bool clearSelectedMealPlan = false,
    Set<int>? selectedWeekdays,
    List<RoomDayRate>? roomRates,
    List<AddedRoomSummary>? addedRooms,
    bool? isSaving,
    bool? requiresRoomRatesReentry,
    String? lastSaveError,
    bool clearLastSaveError = false,
    String? lastSavedReservationId,
    bool clearLastSavedReservationId = false,
    String? lastSavedServiceDisplayNo,
    bool clearLastSavedServiceDisplayNo = false,
  }) {
    return CreateAgentReservationState(
      reservationId: clearReservationId
          ? null
          : reservationId ?? this.reservationId,
      reservationNo: clearReservationNo
          ? null
          : reservationNo ?? this.reservationNo,
      editingServiceId: clearEditingServiceId
          ? null
          : editingServiceId ?? this.editingServiceId,
      editingRoomIndex: clearEditingRoomIndex
          ? null
          : editingRoomIndex ?? this.editingRoomIndex,
      roomRatesRevision: roomRatesRevision ?? this.roomRatesRevision,
      selectedClientId: clearSelectedClientId
          ? null
          : selectedClientId ?? this.selectedClientId,
      clientOptionDate: clearClientOptionDate
          ? null
          : clientOptionDate ?? this.clientOptionDate,
      guestName: clearGuestName ? null : guestName ?? this.guestName,
      guestNationality: clearGuestNationality
          ? null
          : guestNationality ?? this.guestNationality,
      arrivalDate: clearArrivalDate ? null : arrivalDate ?? this.arrivalDate,
      departureDate: clearDepartureDate
          ? null
          : departureDate ?? this.departureDate,
      isManualRate: isManualRate ?? this.isManualRate,
      isPricesWithoutVat: isPricesWithoutVat ?? this.isPricesWithoutVat,
      hotelId: clearHotelId ? null : hotelId ?? this.hotelId,
      hotelName: clearHotelName ? null : hotelName ?? this.hotelName,
      hotelCity: clearHotelCity ? null : hotelCity ?? this.hotelCity,
      supplierId: clearSupplierId ? null : supplierId ?? this.supplierId,
      supplierName: clearSupplierName
          ? null
          : supplierName ?? this.supplierName,
      selectedRoomType: clearSelectedRoomType
          ? null
          : selectedRoomType ?? this.selectedRoomType,
      selectedMealPlan: clearSelectedMealPlan
          ? null
          : selectedMealPlan ?? this.selectedMealPlan,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      roomRates: roomRates ?? this.roomRates,
      addedRooms: addedRooms ?? this.addedRooms,
      isSaving: isSaving ?? this.isSaving,
      requiresRoomRatesReentry:
          requiresRoomRatesReentry ?? this.requiresRoomRatesReentry,
      lastSaveError: clearLastSaveError
          ? null
          : lastSaveError ?? this.lastSaveError,
      lastSavedReservationId: clearLastSavedReservationId
          ? null
          : lastSavedReservationId ?? this.lastSavedReservationId,
      lastSavedServiceDisplayNo: clearLastSavedServiceDisplayNo
          ? null
          : lastSavedServiceDisplayNo ?? this.lastSavedServiceDisplayNo,
    );
  }
}

class RoomDayRate {
  const RoomDayRate({
    required this.date,
    this.saleRoom = '',
    this.saleMealPerPax = '',
    this.costRoom = '',
    this.costMealPerPax = '',
  });

  final DateTime date;
  final String saleRoom;
  final String saleMealPerPax;
  final String costRoom;
  final String costMealPerPax;

  RoomDayRate copyWith({
    String? saleRoom,
    String? saleMealPerPax,
    String? costRoom,
    String? costMealPerPax,
  }) {
    return RoomDayRate(
      date: date,
      saleRoom: saleRoom ?? this.saleRoom,
      saleMealPerPax: saleMealPerPax ?? this.saleMealPerPax,
      costRoom: costRoom ?? this.costRoom,
      costMealPerPax: costMealPerPax ?? this.costMealPerPax,
    );
  }
}

class RoomTotals {
  const RoomTotals({required this.totalSale, required this.totalCost});

  final Decimal totalSale;
  final Decimal totalCost;
}

class AddedRoomSummary {
  const AddedRoomSummary({
    required this.numberOfRooms,
    required this.totalRn,
    required this.roomType,
    required this.mealPlan,
    required this.pax,
    required this.totalSale,
    required this.totalCost,
    required this.roomRates,
    required this.isManualRate,
  });

  final int numberOfRooms;
  final int totalRn;
  final String roomType;
  final String mealPlan;
  final int pax;
  final Decimal totalSale;
  final Decimal totalCost;
  final List<RoomDayRate> roomRates;
  final bool isManualRate;
}
