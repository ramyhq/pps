import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/rms_api/rms_runtime_state_providers.dart';
import '../data_sources/rms_bridge_remote_data_source.dart';
import '../dto/rms_extract_reservation_view_response_dto.dart';
import '../models/rms_bridge_hotel_segment.dart';
import '../models/rms_bridge_reservation_preview.dart';
import '../../../reservations/data/models/client.dart';
import '../../../reservations/data/models/hotel.dart';
import '../../../reservations/data/models/supplier.dart';
import '../models/rms_lookup_item.dart';
import 'rms_bridge_repository.dart';

class RmsBridgeRepositoryImpl implements RmsBridgeRepository {
  const RmsBridgeRepositoryImpl({
    required this.remoteDataSource,
    required this.ref,
  });

  final RmsBridgeRemoteDataSource remoteDataSource;
  final Ref ref;

  @override
  Future<RmsBridgeReservationPreview> fetchReservationPreview({
    required String reservationId,
  }) async {
    final sessionId = ref.read(rmsRuntimeStateProvider).sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('RMS Bridge requires RMS login first.');
    }

    final json = await remoteDataSource.extractReservationView(
      sessionId: sessionId,
      reservationId: reservationId,
    );

    final dto = RmsExtractReservationViewResponseDto.fromJson(json);
    final details = dto.result?.details;
    final reservation = details?.reservation;

    final normalizedReservationId =
        reservation?.reservationId?.trim().isNotEmpty == true
        ? reservation!.reservationId!.trim()
        : reservationId.trim();

    final segments = (details?.hotelSegments ?? const <RmsHotelSegmentDto>[])
        .where((segment) => (segment.referenceId ?? '').trim().isNotEmpty)
        .map(
          (segment) => RmsBridgeHotelSegment(
            referenceId: segment.referenceId!.trim(),
            hotelId: segment.hotelId?.trim(),
            arrivalDate: segment.arrivalDate?.trim(),
            departureDate: segment.departureDate?.trim(),
            label: segment.label?.trim(),
            type: segment.type?.trim(),
            totalSale: segment.totals?.totalSale?.trim(),
            totalCost: segment.totals?.totalCost?.trim(),
          ),
        )
        .toList(growable: false);

    return RmsBridgeReservationPreview(
      reservationId: normalizedReservationId,
      reservationNo: reservation?.reservationNo?.trim(),
      clientId: reservation?.clientId?.trim(),
      hotelSegments: segments,
    );
  }

  @override
  Future<RmsBridgeLookups> fetchCreateOrEditLookups({String rms = ''}) async {
    final sessionId = ref.read(rmsRuntimeStateProvider).sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('RMS Bridge requires RMS login first.');
    }

    final json = await remoteDataSource.extractCreateOrEditLookups(
      sessionId: sessionId,
      rms: rms.trim(),
    );

    final result = json['result'];
    if (result is! Map) {
      throw Exception('Invalid RMS lookups response.');
    }

    List<Client> parseClients() {
      final raw = result['clients'];
      if (raw is! List) return const <Client>[];
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, Object?>())
          .map(Client.fromRmsLookupJson)
          .toList(growable: false);
    }

    List<Hotel> parseHotels() {
      final raw = result['hotels'];
      if (raw is! List) return const <Hotel>[];
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, Object?>())
          .map(Hotel.fromRmsLookupJson)
          .toList(growable: false);
    }

    List<Supplier> parseSuppliers() {
      final raw = result['suppliers'];
      if (raw is! List) return const <Supplier>[];
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, Object?>())
          .map(Supplier.fromRmsLookupJson)
          .toList(growable: false);
    }

    return (
      clients: parseClients(),
      hotels: parseHotels(),
      suppliers: parseSuppliers(),
    );
  }

  @override
  Future<RmsBridgeAdditionalLookups> fetchAdditionalLookups() async {
    final sessionId = ref.read(rmsRuntimeStateProvider).sessionId?.trim();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('RMS Bridge requires RMS login first.');
    }

    final json = await remoteDataSource.extractAdditionalLookups(
      sessionId: sessionId,
    );

    final result = json['result'];
    if (result is! Map) {
      throw Exception('Invalid RMS additional lookups response.');
    }

    List<RmsLookupItem> parseItems(String key) {
      final raw = result[key];
      if (raw is! List) return const <RmsLookupItem>[];
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, Object?>())
          .map(RmsLookupItem.fromJson)
          .toList(growable: false);
    }

    return (
      nationalities: parseItems('nationalities'),
      extraServiceTypes: parseItems('extraServiceTypes'),
      termsAndConditions: parseItems('termsAndConditions'),
      routes: parseItems('routes'),
      vehicleTypes: parseItems('vehicleTypes'),
      tripTypes: parseItems('tripTypes'),
    );
  }
}
