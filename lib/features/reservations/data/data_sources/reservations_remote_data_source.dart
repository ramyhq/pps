import 'package:pps/features/reservations/data/dto/general_service_payload_dto.dart';
import 'package:pps/features/reservations/data/dto/transportation_service_payload_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationsRemoteDataSource {
  ReservationsRemoteDataSource({required SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient? _supabaseClient;
  Future<String?>? _hotelsCitySelectPart;
  static const String _reservationOrdersBaseSelect =
      'id,reservation_no,guest_name,guest_nationality,client_option_date,created_at,clients:clients(id,name,code)';
  static const String _reservationOrdersSelectWithRmsInvoiceNo =
      '$_reservationOrdersBaseSelect,rms_invoice_no';
  static const String _reservationOrdersSelectFull =
      '$_reservationOrdersSelectWithRmsInvoiceNo,party_pax_manual';
  static const String _reservationOrdersSelectFullLegacyParty =
      '$_reservationOrdersSelectWithRmsInvoiceNo,manual_party_pax';

  Future<List<Map<String, dynamic>>> listClients() async {
    final client = _requireClient();
    final rows = await client
        .from('clients')
        .select('id,name,code')
        .order('name');
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> listHotels() async {
    final client = _requireClient();
    final citySelectPart = await _resolveHotelsCitySelectPart();
    final selectColumns = citySelectPart == null
        ? 'id,name,code'
        : 'id,name,code,$citySelectPart';
    final rows = await client
        .from('hotels')
        .select(selectColumns)
        .order('name');
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<String?> _resolveHotelsCitySelectPart() async {
    _hotelsCitySelectPart ??= () async {
      try {
        final client = _requireClient();
        final candidates = <String, String>{
          'city': 'city',
          'city_name': 'city:city_name',
          'hotel_city': 'city:hotel_city',
        };
        for (final entry in candidates.entries) {
          final rows = await client
              .from('information_schema.columns')
              .select('column_name')
              .eq('table_schema', 'public')
              .eq('table_name', 'hotels')
              .eq('column_name', entry.key)
              .limit(1);
          final list = rows as List<dynamic>;
          if (list.isNotEmpty) {
            return entry.value;
          }
        }
        return null;
      } catch (_) {
        return null;
      }
    }();
    return _hotelsCitySelectPart!;
  }

  Future<List<Map<String, dynamic>>> listSuppliers() async {
    final client = _requireClient();
    final rows = await client.from('suppliers').select().order('name');
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> listGeneralServices() async {
    final client = _requireClient();
    final rows = await client
        .from('reservation_service_types')
        .select('key,label,code')
        .neq(
          'key',
          'agent',
        ) // reomve transportation و agent بيستبعد الاتنين دول
        .neq(
          'key',
          'transportation',
        ) // reomve transportation و agent بيستبعد الاتنين دول
        .order('label');
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createReservationOrder({
    required int clientId,
    required String? guestName,
    required String? guestNationality,
    required String? clientOptionDateIso,
  }) async {
    final client = _requireClient();
    final payload = <String, dynamic>{
      'client_id': clientId,
      'guest_name': guestName,
      'guest_nationality': guestNationality,
      'client_option_date': clientOptionDateIso,
    };
    try {
      final created = await client
          .from('reservation_orders')
          .insert(payload)
          .select(_reservationOrdersSelectFull)
          .single();
      return Map<String, dynamic>.from(created as Map);
    } on PostgrestException {
      try {
        final created = await client
            .from('reservation_orders')
            .insert(payload)
            .select(_reservationOrdersSelectFullLegacyParty)
            .single();
        return Map<String, dynamic>.from(created as Map);
      } on PostgrestException {
        try {
          final created = await client
              .from('reservation_orders')
              .insert(payload)
              .select(_reservationOrdersSelectWithRmsInvoiceNo)
              .single();
          return Map<String, dynamic>.from(created as Map);
        } on PostgrestException {
          final created = await client
              .from('reservation_orders')
              .insert(payload)
              .select(_reservationOrdersBaseSelect)
              .single();
          return Map<String, dynamic>.from(created as Map);
        }
      }
    }
  }

  Future<Map<String, dynamic>> updateReservationMainInfo({
    required String reservationId,
    required int clientId,
    required String? guestName,
    required String? guestNationality,
    required String? clientOptionDateIso,
    required String? rmsInvoiceNo,
    required bool setRmsInvoiceNo,
    required int? partyPaxManual,
    required bool setPartyPaxManual,
  }) async {
    final client = _requireClient();
    final updatePayload = <String, dynamic>{
      'client_id': clientId,
      'guest_name': guestName,
      'guest_nationality': guestNationality,
      'client_option_date': clientOptionDateIso,
    };
    if (setRmsInvoiceNo) {
      final rmsText = (rmsInvoiceNo ?? '').trim();
      updatePayload['rms_invoice_no'] = rmsText.isEmpty ? null : rmsText;
    }
    try {
      final updated = await client
          .from('reservation_orders')
          .update(<String, dynamic>{
            ...updatePayload,
            if (setPartyPaxManual) 'party_pax_manual': partyPaxManual,
          })
          .eq('id', reservationId)
          .select(_reservationOrdersSelectFull)
          .single();
      return Map<String, dynamic>.from(updated as Map);
    } on PostgrestException {
      try {
        final updated = await client
            .from('reservation_orders')
            .update(<String, dynamic>{
              ...updatePayload,
              if (setPartyPaxManual) 'manual_party_pax': partyPaxManual,
            })
            .eq('id', reservationId)
            .select(_reservationOrdersSelectFullLegacyParty)
            .single();
        return Map<String, dynamic>.from(updated as Map);
      } on PostgrestException {
        final updated = await client
            .from('reservation_orders')
            .update(updatePayload)
            .eq('id', reservationId)
            .select(_reservationOrdersBaseSelect)
            .single();
        return Map<String, dynamic>.from(updated as Map);
      }
    }
  }

  Future<List<Map<String, dynamic>>> listReservationOrders({
    int limit = 50,
  }) async {
    final client = _requireClient();
    late final dynamic rows;
    try {
      rows = await client
          .from('reservation_orders')
          .select(_reservationOrdersSelectFull)
          .order('created_at', ascending: false)
          .limit(limit);
    } on PostgrestException {
      try {
        rows = await client
            .from('reservation_orders')
            .select(_reservationOrdersSelectFullLegacyParty)
            .order('created_at', ascending: false)
            .limit(limit);
      } on PostgrestException {
        rows = await client
            .from('reservation_orders')
            .select(_reservationOrdersBaseSelect)
            .order('created_at', ascending: false)
            .limit(limit);
      }
    }
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<String?> findReservationOrderIdByNo(int reservationNo) async {
    final client = _requireClient();
    final rows = await client
        .from('reservation_orders')
        .select('id')
        .eq('reservation_no', reservationNo)
        .limit(1);
    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return null;
    }
    final row = Map<String, dynamic>.from(list.first as Map);
    final id = row['id']?.toString() ?? '';
    if (id.isEmpty) {
      return null;
    }
    return id;
  }

  Future<Map<String, dynamic>> addAgentService({
    required String reservationId,
    required Map<String, dynamic> payload,
    required String totalSale,
    required String totalCost,
  }) async {
    final client = _requireClient();
    final created = await client
        .from('reservation_services')
        .insert(<String, dynamic>{
          'reservation_id': reservationId,
          'service_type': 'agent',
          'payload': payload,
          'total_sale': totalSale,
          'total_cost': totalCost,
        })
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(created as Map);
  }

  Future<Map<String, dynamic>> addGeneralService({
    required String reservationId,
    required GeneralServicePayloadDto payload,
  }) async {
    final client = _requireClient();
    final created = await client
        .from('reservation_services')
        .insert(<String, dynamic>{
          'reservation_id': reservationId,
          'service_type': 'general',
          'payload': payload.toJson(),
          'total_sale': payload.totalSale,
          'total_cost': payload.totalCost,
        })
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(created as Map);
  }

  Future<Map<String, dynamic>> addTransportationService({
    required String reservationId,
    required TransportationServicePayloadDto payload,
  }) async {
    final client = _requireClient();
    final created = await client
        .from('reservation_services')
        .insert(<String, dynamic>{
          'reservation_id': reservationId,
          'service_type': 'transportation',
          'payload': payload.toJson(),
          'total_sale': payload.totalSale,
          'total_cost': payload.totalCost,
        })
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(created as Map);
  }

  Future<Map<String, dynamic>> fetchReservationOrder(
    String reservationId,
  ) async {
    final client = _requireClient();
    try {
      final row = await client
          .from('reservation_orders')
          .select(_reservationOrdersSelectFull)
          .eq('id', reservationId)
          .single();
      return Map<String, dynamic>.from(row);
    } on PostgrestException {
      try {
        final row = await client
            .from('reservation_orders')
            .select(_reservationOrdersSelectFullLegacyParty)
            .eq('id', reservationId)
            .single();
        return Map<String, dynamic>.from(row);
      } on PostgrestException {
        final row = await client
            .from('reservation_orders')
            .select(_reservationOrdersBaseSelect)
            .eq('id', reservationId)
            .single();
        return Map<String, dynamic>.from(row);
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchReservationServices(
    String reservationId,
  ) async {
    final client = _requireClient();
    final rows = await client
        .from('reservation_services')
        .select(
          'id,reservation_id,service_no,service_type,display_no,total_sale,total_cost,created_at,payload',
        )
        .eq('reservation_id', reservationId)
        .order('service_no');
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchReservationServiceById(
    String serviceId,
  ) async {
    final client = _requireClient();
    final row = await client
        .from('reservation_services')
        .select(
          'id,reservation_id,service_type,display_no,total_sale,total_cost,payload',
        )
        .eq('id', serviceId)
        .single();
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> updateAgentService({
    required String serviceId,
    required Map<String, dynamic> payload,
    required String totalSale,
    required String totalCost,
  }) async {
    final client = _requireClient();
    final updated = await client
        .from('reservation_services')
        .update(<String, dynamic>{
          'payload': payload,
          'total_sale': totalSale,
          'total_cost': totalCost,
        })
        .eq('id', serviceId)
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(updated as Map);
  }

  Future<Map<String, dynamic>> updateGeneralService({
    required String serviceId,
    required GeneralServicePayloadDto payload,
  }) async {
    final client = _requireClient();
    final updated = await client
        .from('reservation_services')
        .update(<String, dynamic>{
          'payload': payload.toJson(),
          'total_sale': payload.totalSale,
          'total_cost': payload.totalCost,
        })
        .eq('id', serviceId)
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(updated as Map);
  }

  Future<Map<String, dynamic>> updateTransportationService({
    required String serviceId,
    required TransportationServicePayloadDto payload,
  }) async {
    final client = _requireClient();
    final updated = await client
        .from('reservation_services')
        .update(<String, dynamic>{
          'payload': payload.toJson(),
          'total_sale': payload.totalSale,
          'total_cost': payload.totalCost,
        })
        .eq('id', serviceId)
        .select('id,display_no')
        .single();
    return Map<String, dynamic>.from(updated as Map);
  }

  Future<void> deleteReservationService({required String serviceId}) async {
    final client = _requireClient();
    await client.from('reservation_services').delete().eq('id', serviceId);
  }

  Future<void> deleteReservationOrder({required String reservationId}) async {
    final client = _requireClient();
    await client.from('reservation_orders').delete().eq('id', reservationId);
  }

  SupabaseClient _requireClient() {
    final client = _supabaseClient;
    if (client == null) {
      throw const ReservationDataException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }
}

class ReservationDataException implements Exception {
  const ReservationDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
