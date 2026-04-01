import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_clone/core/supabase/supabase_client_provider.dart';
import 'package:rms_clone/features/reservations/data/data_sources/reservations_remote_data_source.dart';
import 'package:rms_clone/features/reservations/data/models/client.dart';
import 'package:rms_clone/features/reservations/data/models/hotel.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_details.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_order.dart';
import 'package:rms_clone/features/reservations/data/models/supplier.dart';
import 'package:rms_clone/features/reservations/data/repositories/reservations_repository.dart';
import 'package:rms_clone/features/reservations/data/repositories/reservations_repository_impl.dart';

final reservationsRemoteDataSourceProvider =
    Provider<ReservationsRemoteDataSource>((ref) {
      final supabaseClient = ref.watch(supabaseClientProvider);
      return ReservationsRemoteDataSource(supabaseClient: supabaseClient);
    });

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) {
  final remoteDataSource = ref.watch(reservationsRemoteDataSourceProvider);
  return ReservationsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final reservationClientsProvider = FutureProvider<List<Client>>((ref) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.listClients();
});

final reservationHotelsProvider = FutureProvider<List<Hotel>>((ref) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.listHotels();
});

final reservationSuppliersProvider = FutureProvider<List<Supplier>>((
  ref,
) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.listSuppliers();
});

final generalServicesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.listGeneralServices();
});

final reservationOrdersProvider = FutureProvider<List<ReservationOrder>>((
  ref,
) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.listReservationOrders();
});

final reservationDetailsProvider =
    FutureProvider.family<ReservationDetails, String>((ref, reservationId) {
      final repository = ref.watch(reservationsRepositoryProvider);
      return repository.fetchReservationDetails(reservationId);
    });
