import 'dart:math';

import 'package:pps/features/reservations/data/data_sources/reservations_remote_data_source.dart';
import 'package:pps/features/reservations/data/dto/create_agent_reservation_payload_dto.dart';
import 'package:pps/features/reservations/data/dto/general_service_payload_dto.dart';
import 'package:pps/features/reservations/data/dto/transportation_service_payload_dto.dart';
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
import 'package:decimal/decimal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  ReservationsRepositoryImpl({
    required ReservationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ReservationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Client>> listClients() async {
    try {
      final rows = await _remoteDataSource.listClients();
      return rows
          .map(
            (row) => Client(
              id: (row['id'] as num).toInt(),
              name: (row['name'] as String?)?.trim() ?? '',
              code: row['code'] as String?,
            ),
          )
          .where((client) => client.name.isNotEmpty)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<List<Hotel>> listHotels() async {
    try {
      final rows = await _remoteDataSource.listHotels();
      return rows
          .map(
            (row) => Hotel(
              id: (row['id'] as num).toInt(),
              name: (row['name'] as String?)?.trim() ?? '',
              code: row['code'] as String?,
              city: (row['city'] as String?)?.trim(),
            ),
          )
          .where((hotel) => hotel.name.isNotEmpty)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<List<Supplier>> listSuppliers() async {
    try {
      final rows = await _remoteDataSource.listSuppliers();
      return rows
          .map(
            (row) => Supplier(
              id: (row['id'] as num).toInt(),
              name: (row['name'] as String?)?.trim() ?? '',
              code: row['code'] as String?,
            ),
          )
          .where((supplier) => supplier.name.isNotEmpty)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<List<String>> listGeneralServices() async {
    try {
      final rows = await _remoteDataSource.listGeneralServices();
      final nameKeys = <String>[
        'name',
        'service_name',
        'title',
        'label',
        'type_name',
      ];
      return rows
          .map((row) {
            for (final key in nameKeys) {
              final value = row[key];
              if (value is String && value.trim().isNotEmpty) {
                return value.trim();
              }
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<List<ReservationOrder>> listReservationOrders({int limit = 50}) async {
    try {
      final rows = await _remoteDataSource.listReservationOrders(limit: limit);
      return rows.map(_mapOrder).toList(growable: false);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<String?> findReservationOrderIdByNo(int reservationNo) async {
    try {
      return await _remoteDataSource.findReservationOrderIdByNo(reservationNo);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<ReservationOrder> createReservationOrder(
    CreateReservationOrderDraft draft,
  ) async {
    try {
      final created = await _remoteDataSource.createReservationOrder(
        clientId: draft.clientId,
        guestName: draft.guestName,
        guestNationality: draft.guestNationality,
        clientOptionDateIso: draft.clientOptionDate?.toIso8601String(),
      );
      return _mapOrder(created);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> addAgentService({
    required String reservationId,
    required AgentReservationDraft draft,
  }) async {
    try {
      final payload = CreateAgentReservationPayloadDto.fromDomain(draft);
      final payloadJson = payload.toJson();
      payloadJson['roomsSummaryRates'] = draft.roomsSummary
          .map((room) {
            return room.roomRates
                .map(
                  (rate) => <String, dynamic>{
                    'date': rate.date.toIso8601String(),
                    'saleRoom': rate.saleRoom,
                    'saleMealPerPax': rate.saleMealPerPax,
                    'costRoom': rate.costRoom,
                    'costMealPerPax': rate.costMealPerPax,
                  },
                )
                .toList(growable: false);
          })
          .toList(growable: false);
      final created = await _remoteDataSource.addAgentService(
        reservationId: reservationId,
        payload: payloadJson,
        totalSale: payload.totalSale,
        totalCost: payload.totalCost,
      );
      return _mapSavedService(created);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> addGeneralService({
    required String reservationId,
    required GeneralServiceDraft draft,
  }) async {
    try {
      final payload = GeneralServicePayloadDto.fromDomain(draft);
      final created = await _remoteDataSource.addGeneralService(
        reservationId: reservationId,
        payload: payload,
      );
      return _mapSavedService(created);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> addTransportationService({
    required String reservationId,
    required TransportationServiceDraft draft,
  }) async {
    try {
      final payload = TransportationServicePayloadDto.fromDomain(draft);
      final created = await _remoteDataSource.addTransportationService(
        reservationId: reservationId,
        payload: payload,
      );
      return _mapSavedService(created);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> updateAgentService({
    required String serviceId,
    required AgentReservationDraft draft,
  }) async {
    try {
      final payload = CreateAgentReservationPayloadDto.fromDomain(draft);
      final payloadJson = payload.toJson();
      payloadJson['roomsSummaryRates'] = draft.roomsSummary
          .map((room) {
            return room.roomRates
                .map(
                  (rate) => <String, dynamic>{
                    'date': rate.date.toIso8601String(),
                    'saleRoom': rate.saleRoom,
                    'saleMealPerPax': rate.saleMealPerPax,
                    'costRoom': rate.costRoom,
                    'costMealPerPax': rate.costMealPerPax,
                  },
                )
                .toList(growable: false);
          })
          .toList(growable: false);
      final updated = await _remoteDataSource.updateAgentService(
        serviceId: serviceId,
        payload: payloadJson,
        totalSale: payload.totalSale,
        totalCost: payload.totalCost,
      );
      return _mapSavedService(updated);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> updateGeneralService({
    required String serviceId,
    required GeneralServiceDraft draft,
  }) async {
    try {
      final payload = GeneralServicePayloadDto.fromDomain(draft);
      final updated = await _remoteDataSource.updateGeneralService(
        serviceId: serviceId,
        payload: payload,
      );
      return _mapSavedService(updated);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<SavedReservationService> updateTransportationService({
    required String serviceId,
    required TransportationServiceDraft draft,
  }) async {
    try {
      final payload = TransportationServicePayloadDto.fromDomain(draft);
      final updated = await _remoteDataSource.updateTransportationService(
        serviceId: serviceId,
        payload: payload,
      );
      return _mapSavedService(updated);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<AgentReservationDraft> fetchAgentServiceDraft(String serviceId) async {
    try {
      final row = await _remoteDataSource.fetchReservationServiceById(
        serviceId,
      );
      final rawPayload = row['payload'];
      if (rawPayload is! Map) {
        throw const ReservationDataException('Invalid agent payload.');
      }
      final map = Map<String, dynamic>.from(rawPayload);
      final payload = CreateAgentReservationPayloadDto.fromJson(map);
      return _mapAgentDraft(payload, map);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<GeneralServiceDraft> fetchGeneralServiceDraft(String serviceId) async {
    try {
      final row = await _remoteDataSource.fetchReservationServiceById(
        serviceId,
      );
      final rawPayload = row['payload'];
      if (rawPayload is! Map) {
        throw const ReservationDataException('Invalid general payload.');
      }
      final payload = GeneralServicePayloadDto.fromJson(
        Map<String, dynamic>.from(rawPayload),
      );
      return _mapGeneralDraft(payload);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<TransportationServiceDraft> fetchTransportationServiceDraft(
    String serviceId,
  ) async {
    try {
      final row = await _remoteDataSource.fetchReservationServiceById(
        serviceId,
      );
      final rawPayload = row['payload'];
      if (rawPayload is! Map) {
        throw const ReservationDataException('Invalid transportation payload.');
      }
      final payload = TransportationServicePayloadDto.fromJson(
        Map<String, dynamic>.from(rawPayload),
      );
      return _mapTransportationDraft(payload);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<ReservationDetails> fetchReservationDetails(
    String reservationId,
  ) async {
    try {
      final orderRow = await _remoteDataSource.fetchReservationOrder(
        reservationId,
      );
      final servicesRows = await _remoteDataSource.fetchReservationServices(
        reservationId,
      );
      final order = _mapOrder(orderRow);
      final services = servicesRows
          .map(_mapServiceSummary)
          .toList(growable: false);

      final needsCity = services.any((service) {
        if (service.type != ReservationServiceType.agent) {
          return false;
        }
        final agent = service.agentDetails;
        return agent != null &&
            (agent.hotelCity == null || agent.hotelCity!.trim().isEmpty) &&
            agent.hotelId != null;
      });

      if (!needsCity) {
        return ReservationDetails(order: order, services: services);
      }

      final hotels = await listHotels();
      final cityByHotelId = <int, String>{
        for (final hotel in hotels)
          if (hotel.city != null && hotel.city!.trim().isNotEmpty)
            hotel.id: hotel.city!.trim(),
      };

      final enrichedServices = services
          .map((service) {
            if (service.type != ReservationServiceType.agent) {
              return service;
            }
            final agent = service.agentDetails;
            if (agent == null) {
              return service;
            }
            final currentCity = agent.hotelCity?.trim();
            if (currentCity != null && currentCity.isNotEmpty) {
              return service;
            }
            final hotelId = agent.hotelId;
            final resolvedCity = hotelId == null
                ? null
                : cityByHotelId[hotelId];
            if (resolvedCity == null || resolvedCity.trim().isEmpty) {
              return service;
            }
            final updatedAgent = AgentReservationDraft(
              arrivalDate: agent.arrivalDate,
              departureDate: agent.departureDate,
              isManualRate: agent.isManualRate,
              isPricesWithoutVat: agent.isPricesWithoutVat,
              hotelId: agent.hotelId,
              hotelName: agent.hotelName,
              hotelCity: resolvedCity,
              supplierId: agent.supplierId,
              supplierName: agent.supplierName,
              selectedRoomType: agent.selectedRoomType,
              selectedMealPlan: agent.selectedMealPlan,
              roomRates: agent.roomRates,
              roomsSummary: agent.roomsSummary,
              totalPax: agent.totalPax,
              totalSale: agent.totalSale,
              totalCost: agent.totalCost,
            );
            return ReservationServiceSummary(
              id: service.id,
              reservationId: service.reservationId,
              serviceNo: service.serviceNo,
              type: service.type,
              displayNo: service.displayNo,
              totalSale: service.totalSale,
              totalCost: service.totalCost,
              createdAt: service.createdAt,
              agentDetails: updatedAgent,
              generalDetails: service.generalDetails,
              transportationDetails: service.transportationDetails,
            );
          })
          .toList(growable: false);

      return ReservationDetails(order: order, services: enrichedServices);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<ReservationOrder> updateReservationMainInfo({
    required String reservationId,
    required int clientId,
    required String? guestName,
    required String? guestNationality,
    required DateTime? clientOptionDate,
    String? rmsInvoiceNo,
  }) async {
    try {
      final updated = await _remoteDataSource.updateReservationMainInfo(
        reservationId: reservationId,
        clientId: clientId,
        guestName: guestName,
        guestNationality: guestNationality,
        clientOptionDateIso: clientOptionDate?.toIso8601String(),
        rmsInvoiceNo: rmsInvoiceNo,
      );
      return _mapOrder(updated);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<void> deleteReservationService({required String serviceId}) async {
    try {
      await _remoteDataSource.deleteReservationService(serviceId: serviceId);
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  @override
  Future<void> deleteReservationOrder({required String reservationId}) async {
    try {
      await _remoteDataSource.deleteReservationOrder(
        reservationId: reservationId,
      );
    } on PostgrestException catch (error) {
      throw ReservationDataException(error.message);
    } on AuthException catch (error) {
      throw ReservationDataException(error.message);
    } on StorageException catch (error) {
      throw ReservationDataException(error.message);
    }
  }

  ReservationOrder _mapOrder(Map<String, dynamic> row) {
    final rawClient = row['clients'];
    final clientRow = rawClient is Map
        ? Map<String, dynamic>.from(rawClient)
        : const <String, dynamic>{};
    final clientId = (clientRow['id'] as num?)?.toInt() ?? 0;
    final clientName = (clientRow['name'] as String?)?.trim() ?? '';
    final clientCode = clientRow['code'] as String?;

    final reservationNo = (row['reservation_no'] as num?)?.toInt() ?? 0;
    final createdAt =
        DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    final clientOptionDate = DateTime.tryParse(
      row['client_option_date']?.toString() ?? '',
    );

    String? rmsInvoiceNo;
    const rmsKeys = <String>[
      'rms_invoice_no',
      'rms_invoice_number',
      'rms_invoice_id',
    ];
    for (final key in rmsKeys) {
      final raw = row[key];
      if (raw == null) {
        continue;
      }
      final text = raw.toString().trim();
      if (text.isNotEmpty) {
        rmsInvoiceNo = text;
        break;
      }
    }

    return ReservationOrder(
      id: row['id']?.toString() ?? '',
      reservationNo: reservationNo,
      client: Client(id: clientId, name: clientName, code: clientCode),
      guestName: row['guest_name'] as String?,
      guestNationality: row['guest_nationality'] as String?,
      clientOptionDate: clientOptionDate,
      rmsInvoiceNo: rmsInvoiceNo,
      createdAt: createdAt,
    );
  }

  ReservationServiceSummary _mapServiceSummary(Map<String, dynamic> row) {
    final type = reservationServiceTypeFromDb(row['service_type']?.toString());
    if (type == null) {
      throw const ReservationDataException('Unknown service type.');
    }
    final totalSaleFromColumns =
        Decimal.tryParse(row['total_sale']?.toString() ?? '') ??
        Decimal.parse('0');
    final totalCostFromColumns =
        Decimal.tryParse(row['total_cost']?.toString() ?? '') ??
        Decimal.parse('0');
    final payloadTotals = _tryParseServiceTotalsFromPayload(
      type,
      row['payload'],
    );
    //CALCULATIONS إجمالي البيع النهائي للخدمة المقروءة = مجموع payload إذا وُجد، وإلا قيمة total_sale من الأعمدة.
    final totalSale = payloadTotals?.totalSale ?? totalSaleFromColumns;
    //CALCULATIONS إجمالي التكلفة النهائي للخدمة المقروءة = مجموع payload إذا وُجد، وإلا قيمة total_cost من الأعمدة.
    final totalCost = payloadTotals?.totalCost ?? totalCostFromColumns;
    final createdAt =
        DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    AgentReservationDraft? agentDetails;
    GeneralServiceDraft? generalDetails;
    TransportationServiceDraft? transportationDetails;
    final rawPayload = row['payload'];
    if (rawPayload is Map) {
      final map = Map<String, dynamic>.from(rawPayload);
      try {
        switch (type) {
          case ReservationServiceType.agent:
            final dto = CreateAgentReservationPayloadDto.fromJson(map);
            agentDetails = _mapAgentDraft(dto, map);
          case ReservationServiceType.general:
            final dto = GeneralServicePayloadDto.fromJson(map);
            generalDetails = _mapGeneralDraft(dto);
          case ReservationServiceType.transportation:
            final dto = TransportationServicePayloadDto.fromJson(map);
            transportationDetails = _mapTransportationDraft(dto);
        }
      } catch (_) {
        agentDetails = null;
        generalDetails = null;
        transportationDetails = null;
      }
    }
    return ReservationServiceSummary(
      id: row['id']?.toString() ?? '',
      reservationId: row['reservation_id']?.toString() ?? '',
      serviceNo: (row['service_no'] as num?)?.toInt() ?? 0,
      type: type,
      displayNo: row['display_no']?.toString() ?? '',
      totalSale: totalSale,
      totalCost: totalCost,
      createdAt: createdAt,
      agentDetails: agentDetails,
      generalDetails: generalDetails,
      transportationDetails: transportationDetails,
    );
  }

  Decimal _parseDecimalOrZero(String raw) {
    return Decimal.tryParse(raw.trim()) ?? Decimal.parse('0');
  }

  AgentReservationDraft _mapAgentDraft(
    CreateAgentReservationPayloadDto dto,
    Map<String, dynamic> rawPayload,
  ) {
    final arrivalDate =
        DateTime.tryParse(dto.arrivalDate)?.toLocal() ?? DateTime.now();
    final departureDate =
        DateTime.tryParse(dto.departureDate)?.toLocal() ?? DateTime.now();
    final nightsCount = max(1, departureDate.difference(arrivalDate).inDays);

    final roomRates = dto.roomRates
        .map((rate) {
          final date =
              DateTime.tryParse(rate.date)?.toLocal() ?? DateTime.now();
          return AgentReservationRoomRate(
            date: date,
            saleRoom: rate.saleRoom,
            saleMealPerPax: rate.saleMealPerPax,
            costRoom: rate.costRoom,
            costMealPerPax: rate.costMealPerPax,
          );
        })
        .toList(growable: false);

    List<AgentReservationRoomRate> parseRoomRatesList(Object? raw) {
      if (raw is! List) {
        return const <AgentReservationRoomRate>[];
      }
      final parsed = <AgentReservationRoomRate>[];
      for (final item in raw) {
        if (item is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(item);
        final date =
            DateTime.tryParse(map['date']?.toString() ?? '')?.toLocal() ??
            DateTime.now();
        parsed.add(
          AgentReservationRoomRate(
            date: date,
            saleRoom: map['saleRoom']?.toString() ?? '',
            saleMealPerPax: map['saleMealPerPax']?.toString() ?? '',
            costRoom: map['costRoom']?.toString() ?? '',
            costMealPerPax: map['costMealPerPax']?.toString() ?? '',
          ),
        );
      }
      return parsed.toList(growable: false);
    }

    List<AgentReservationRoomRate> generateFallbackRoomRates({
      required Decimal totalSale,
      required int totalRn,
    }) {
      if (totalRn <= 0) {
        return const <AgentReservationRoomRate>[];
      }
      final perRn = (totalSale / Decimal.fromInt(totalRn)).toDecimal(
        scaleOnInfinitePrecision: 6,
      );
      return List<AgentReservationRoomRate>.generate(
        nightsCount,
        (i) => AgentReservationRoomRate(
          date: arrivalDate.add(Duration(days: i)),
          saleRoom: perRn.toString(),
          saleMealPerPax: '',
          costRoom: '',
          costMealPerPax: '',
        ),
        growable: false,
      );
    }

    final rawRoomsSummaryRates = rawPayload['roomsSummaryRates'];
    final roomsSummaryRatesByIndex = rawRoomsSummaryRates is List
        ? rawRoomsSummaryRates
        : const <dynamic>[];

    final roomsSummary = dto.roomsSummary
        .asMap()
        .entries
        .map((entry) {
          final summary = entry.value;
          final index = entry.key;
          final totalSale = _parseDecimalOrZero(summary.totalSale);
          final totalCost = _parseDecimalOrZero(summary.totalCost);
          final extractedRates = index < roomsSummaryRatesByIndex.length
              ? parseRoomRatesList(roomsSummaryRatesByIndex[index])
              : const <AgentReservationRoomRate>[];
          final roomRatesForSummary = extractedRates.isEmpty
              ? generateFallbackRoomRates(
                  totalSale: totalSale,
                  totalRn: summary.totalRn,
                )
              : extractedRates;
          return AgentReservationRoomSummary(
            numberOfRooms: summary.numberOfRooms,
            totalRn: summary.totalRn,
            roomType: summary.roomType,
            mealPlan: summary.mealPlan,
            pax: summary.pax,
            totalSale: totalSale,
            totalCost: totalCost,
            roomRates: roomRatesForSummary,
          );
        })
        .toList(growable: false);

    return AgentReservationDraft(
      arrivalDate: arrivalDate,
      departureDate: departureDate,
      isManualRate: dto.isManualRate,
      isPricesWithoutVat: dto.isPricesWithoutVat,
      hotelId: dto.hotelId,
      hotelName: dto.hotelName,
      hotelCity: dto.hotelCity,
      supplierId: dto.supplierId,
      supplierName: dto.supplierName,
      selectedRoomType: dto.selectedRoomType,
      selectedMealPlan: dto.selectedMealPlan,
      roomRates: roomRates,
      roomsSummary: roomsSummary,
      totalPax: dto.totalPax,
      totalSale: _parseDecimalOrZero(dto.totalSale),
      totalCost: _parseDecimalOrZero(dto.totalCost),
    );
  }

  GeneralServiceDraft _mapGeneralDraft(GeneralServicePayloadDto dto) {
    //CALCULATIONS الكمية الافتراضية للخدمة العامة = 1 إذا كانت الكمية المحفوظة غير صالحة أو أقل من/تساوي صفر.
    final quantity = dto.quantity <= 0 ? 1 : dto.quantity;
    final totalSale = _parseDecimalOrZero(dto.totalSale);
    final totalCost = _parseDecimalOrZero(dto.totalCost);

    //CALCULATIONS سعر البيع للوحدة يرجع إلى totalSale عند غياب salePerItem من payload القديم.
    final salePerItem =
        dto.salePerItem == null || dto.salePerItem!.trim().isEmpty
        ? totalSale
        : _parseDecimalOrZero(dto.salePerItem!);
    //CALCULATIONS سعر التكلفة للوحدة يرجع إلى totalCost عند غياب costPerItem من payload القديم.
    final costPerItem =
        dto.costPerItem == null || dto.costPerItem!.trim().isEmpty
        ? totalCost
        : _parseDecimalOrZero(dto.costPerItem!);

    return GeneralServiceDraft(
      dateOfService:
          DateTime.tryParse(dto.dateOfService)?.toLocal() ?? DateTime.now(),
      endDate: DateTime.tryParse(dto.endDate)?.toLocal() ?? DateTime.now(),
      serviceName: dto.serviceName,
      description: dto.description,
      quantity: quantity,
      supplierId: dto.supplierId,
      salePerItem: salePerItem,
      costPerItem: costPerItem,
      totalSale: totalSale,
      totalCost: totalCost,
      termsAndConditions: dto.termsAndConditions,
      providerRemarks: dto.providerRemarks,
      notes: dto.notes,
    );
  }

  TransportationServiceDraft _mapTransportationDraft(
    TransportationServicePayloadDto dto,
  ) {
    final trips = dto.trips
        .map((trip) {
          return TransportationTripDraft(
            type: trip.type,
            fromDestination: trip.fromDestination,
            toDestination: trip.toDestination,
            vehicle: trip.vehicle,
            date: DateTime.tryParse(trip.date)?.toLocal() ?? DateTime.now(),
            time: trip.time,
            quantity: trip.quantity,
            pax: trip.pax,
            notes: trip.notes,
            salePerItem: _parseDecimalOrZero(trip.salePerItem),
            costPerItem: _parseDecimalOrZero(trip.costPerItem),
          );
        })
        .toList(growable: false);

    return TransportationServiceDraft(
      pricingPerTrip: dto.pricingPerTrip,
      routeType: dto.routeType,
      serviceRoute: dto.serviceRoute,
      supplierId: dto.supplierId,
      supplierName: dto.supplierName,
      termsAndConditions: dto.termsAndConditions,
      transactionNotes: dto.transactionNotes,
      providerRemarks: dto.providerRemarks,
      providerOptionDate: dto.providerOptionDate == null
          ? null
          : DateTime.tryParse(dto.providerOptionDate!)?.toLocal(),
      trips: trips,
      totalSale: _parseDecimalOrZero(dto.totalSale),
      totalCost: _parseDecimalOrZero(dto.totalCost),
    );
  }

  _ServiceTotals? _tryParseServiceTotalsFromPayload(
    ReservationServiceType type,
    Object? rawPayload,
  ) {
    if (rawPayload is! Map) {
      return null;
    }
    final payload = Map<String, dynamic>.from(rawPayload);
    switch (type) {
      case ReservationServiceType.agent:
        return _tryParseAgentTotals(payload) ?? _tryParseFlatTotals(payload);
      case ReservationServiceType.transportation:
        return _tryParseTransportationTotals(payload) ??
            _tryParseFlatTotals(payload);
      case ReservationServiceType.general:
        return _tryParseFlatTotals(payload);
    }
  }

  _ServiceTotals? _tryParseAgentTotals(Map<String, dynamic> payload) {
    final rawList = payload['roomsSummary'];
    if (rawList is! List) {
      return null;
    }
    var sale = Decimal.parse('0');
    var cost = Decimal.parse('0');
    var hasAny = false;
    for (final item in rawList) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final itemSale = Decimal.tryParse(map['totalSale']?.toString() ?? '');
      final itemCost = Decimal.tryParse(map['totalCost']?.toString() ?? '');
      if (itemSale != null) {
        //CALCULATIONS إجمالي بيع Agent من payload = جمع totalSale لكل صف غرفة محفوظ.
        sale += itemSale;
        hasAny = true;
      }
      if (itemCost != null) {
        //CALCULATIONS إجمالي تكلفة Agent من payload = جمع totalCost لكل صف غرفة محفوظ.
        cost += itemCost;
        hasAny = true;
      }
    }
    if (!hasAny) {
      return null;
    }
    return _ServiceTotals(totalSale: sale, totalCost: cost);
  }

  _ServiceTotals? _tryParseTransportationTotals(Map<String, dynamic> payload) {
    final rawList = payload['trips'];
    if (rawList is! List) {
      return null;
    }
    var sale = Decimal.parse('0');
    var cost = Decimal.parse('0');
    var hasAny = false;
    for (final item in rawList) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final quantity = (map['quantity'] as num?)?.toInt() ?? 0;
      final salePerItem = Decimal.tryParse(
        map['salePerItem']?.toString() ?? '',
      );
      final costPerItem = Decimal.tryParse(
        map['costPerItem']?.toString() ?? '',
      );
      if (salePerItem != null) {
        //CALCULATIONS إجمالي بيع Transportation من payload = جمع (salePerItem × quantity) لكل رحلة.
        sale += salePerItem * Decimal.fromInt(quantity);
        hasAny = true;
      }
      if (costPerItem != null) {
        //CALCULATIONS إجمالي تكلفة Transportation من payload = جمع (costPerItem × quantity) لكل رحلة.
        cost += costPerItem * Decimal.fromInt(quantity);
        hasAny = true;
      }
    }
    if (!hasAny) {
      return null;
    }
    return _ServiceTotals(totalSale: sale, totalCost: cost);
  }

  _ServiceTotals? _tryParseFlatTotals(Map<String, dynamic> payload) {
    final saleRaw = payload['totalSale'];
    final costRaw = payload['totalCost'];
    final sale = Decimal.tryParse(saleRaw?.toString() ?? '');
    final cost = Decimal.tryParse(costRaw?.toString() ?? '');
    if (sale == null && cost == null) {
      return null;
    }
    return _ServiceTotals(
      totalSale: sale ?? Decimal.parse('0'),
      totalCost: cost ?? Decimal.parse('0'),
    );
  }

  SavedReservationService _mapSavedService(Map<String, dynamic> row) {
    final rawId = row['service_id'] ?? row['id'];
    final id = rawId == null ? '' : rawId.toString();
    final displayNo = row['display_no']?.toString() ?? '';
    if (id.isEmpty || displayNo.isEmpty) {
      throw const ReservationDataException(
        'Supabase response does not include service id/display no.',
      );
    }
    return SavedReservationService(id: id, displayNo: displayNo);
  }
}

class _ServiceTotals {
  const _ServiceTotals({required this.totalSale, required this.totalCost});

  final Decimal totalSale;
  final Decimal totalCost;
}
