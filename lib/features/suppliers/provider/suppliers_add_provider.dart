import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/supabase/supabase_client_provider.dart';
import 'package:pps/features/suppliers/data/data_sources/suppliers_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuppliersAddState {
  static const _unset = Object();

  final bool isSaving;
  final String? errorMessage;

  const SuppliersAddState({this.isSaving = false, this.errorMessage});

  SuppliersAddState copyWith({bool? isSaving, Object? errorMessage = _unset}) {
    return SuppliersAddState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

final suppliersAddRemoteDataSourceProvider =
    Provider<SuppliersRemoteDataSource>((ref) {
      final supabaseClient = ref.watch(supabaseClientProvider);
      return SuppliersRemoteDataSource(supabaseClient: supabaseClient);
    });

final suppliersAddProvider =
    NotifierProvider.autoDispose<SuppliersAddNotifier, SuppliersAddState>(
      SuppliersAddNotifier.new,
    );

class SuppliersAddNotifier extends Notifier<SuppliersAddState> {
  @override
  SuppliersAddState build() => const SuppliersAddState();

  Future<String?> submit({required String name, String? code}) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final dataSource = ref.read(suppliersAddRemoteDataSourceProvider);
      await dataSource.createSupplier(name: name, code: code);
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
      return 'Supplier code already exists.';
    }
    return 'Supabase error: ${e.message}';
  }
}
