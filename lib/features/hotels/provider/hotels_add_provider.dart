import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/hotels/data/data_sources/hotels_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HotelsAddState {
  static const _unset = Object();

  final bool isSaving;
  final String? errorMessage;

  const HotelsAddState({this.isSaving = false, this.errorMessage});

  HotelsAddState copyWith({bool? isSaving, Object? errorMessage = _unset}) {
    return HotelsAddState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

final hotelsAddRemoteDataSourceProvider = Provider<HotelsRemoteDataSource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HotelsRemoteDataSource(supabaseClient: supabaseClient);
});

final hotelsAddProvider =
    NotifierProvider.autoDispose<HotelsAddNotifier, HotelsAddState>(
      HotelsAddNotifier.new,
    );

class HotelsAddNotifier extends Notifier<HotelsAddState> {
  @override
  HotelsAddState build() => const HotelsAddState();

  Future<String?> submit({
    required String name,
    String? code,
    String? city,
    String? category,
    int? supplierId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final dataSource = ref.read(hotelsAddRemoteDataSourceProvider);
      await dataSource.createHotel(
        name: name,
        code: code,
        city: city,
        category: category,
        supplierId: supplierId,
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

    if (combined.contains('duplicate') && combined.contains('code')) {
      return 'Hotel code already exists.';
    }
    return 'Supabase error: ${e.message}';
  }
}
