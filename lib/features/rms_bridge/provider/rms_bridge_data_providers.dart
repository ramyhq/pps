import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rms_api/rms_dio_provider.dart';
import '../data/data_sources/rms_bridge_remote_data_source.dart';
import '../data/models/rms_bridge_reservation_preview.dart';
import '../data/repositories/rms_bridge_repository.dart';
import '../data/repositories/rms_bridge_repository_impl.dart';

final rmsBridgeRemoteDataSourceProvider = Provider<RmsBridgeRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(rmsDioProvider);
  return RmsBridgeRemoteDataSource(dio: dio);
});

final rmsBridgeRepositoryProvider = Provider<RmsBridgeRepository>((ref) {
  final remote = ref.watch(rmsBridgeRemoteDataSourceProvider);
  return RmsBridgeRepositoryImpl(remoteDataSource: remote, ref: ref);
});

final rmsBridgeReservationPreviewProvider =
    FutureProvider.family<RmsBridgeReservationPreview, String>((
      ref,
      reservationId,
    ) async {
      final repo = ref.watch(rmsBridgeRepositoryProvider);
      return repo.fetchReservationPreview(reservationId: reservationId);
    });

final rmsBridgeCreateOrEditLookupsProvider =
    FutureProvider.family<RmsBridgeLookups, String>((ref, rms) async {
      final repo = ref.watch(rmsBridgeRepositoryProvider);
      return repo.fetchCreateOrEditLookups(rms: rms);
    });

final rmsBridgeAdditionalLookupsProvider =
    FutureProvider<RmsBridgeAdditionalLookups>((ref) async {
      final repo = ref.watch(rmsBridgeRepositoryProvider);
      return repo.fetchAdditionalLookups();
    });
