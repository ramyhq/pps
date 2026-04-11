import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/clients/data/data_sources/clients_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsAddState {
  static const _unset = Object();

  final bool isSaving;
  final String? errorMessage;

  const ClientsAddState({this.isSaving = false, this.errorMessage});

  ClientsAddState copyWith({bool? isSaving, Object? errorMessage = _unset}) {
    return ClientsAddState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

final clientsAddRemoteDataSourceProvider = Provider<ClientsRemoteDataSource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ClientsRemoteDataSource(supabaseClient: supabaseClient);
});

final clientsAddProvider =
    NotifierProvider.autoDispose<ClientsAddNotifier, ClientsAddState>(
      ClientsAddNotifier.new,
    );

class ClientsAddNotifier extends Notifier<ClientsAddState> {
  @override
  ClientsAddState build() => const ClientsAddState();

  Future<String?> submit({required String name, String? code}) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final dataSource = ref.read(clientsAddRemoteDataSourceProvider);
      await dataSource.createClient(name: name, code: code);
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
      return 'Client code already exists.';
    }
    return 'Supabase error: ${e.message}';
  }
}
