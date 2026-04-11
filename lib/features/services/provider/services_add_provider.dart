import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/services/data/data_sources/services_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesAddState {
  static const _unset = Object();

  final bool isSaving;
  final String? errorMessage;

  const ServicesAddState({this.isSaving = false, this.errorMessage});

  ServicesAddState copyWith({bool? isSaving, Object? errorMessage = _unset}) {
    return ServicesAddState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

final servicesAddRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ServicesRemoteDataSource(supabaseClient: supabaseClient);
});

final servicesAddProvider =
    NotifierProvider.autoDispose<ServicesAddNotifier, ServicesAddState>(
      ServicesAddNotifier.new,
    );

class ServicesAddNotifier extends Notifier<ServicesAddState> {
  @override
  ServicesAddState build() => const ServicesAddState();

  Future<String?> submit({
    required String keyValue,
    String? label,
    String? code,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final dataSource = ref.read(servicesAddRemoteDataSourceProvider);
      await dataSource.createReservationServiceType(
        keyValue: keyValue,
        label: label,
        code: code,
      );
      state = state.copyWith(isSaving: false, errorMessage: null);
      return null;
    } on PostgrestException catch (e) {
      final message = _friendlyPostgrestMessage(e);
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(isSaving: false, errorMessage: message);
      return message;
    }
  }

  String _friendlyPostgrestMessage(PostgrestException e) {
    final msg = e.message.toLowerCase();
    final details = (e.details?.toString() ?? '').toLowerCase();
    final combined = '$msg $details';

    if (combined.contains('duplicate') &&
        (combined.contains('key') || combined.contains('code'))) {
      return 'Service type key already exists.';
    }
    return 'Supabase error: ${e.message}';
  }
}
