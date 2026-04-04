import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/rms_user_info.dart';
import 'rms_auth_providers.dart';

final rmsSessionProvider =
    NotifierProvider<RmsSessionNotifier, RmsSessionState>(
      RmsSessionNotifier.new,
    );

class RmsSessionState {
  const RmsSessionState({
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.user,
    required this.errorMessage,
  });

  final bool isAuthenticated;
  final bool isSubmitting;
  final RmsUserInfo? user;
  final String? errorMessage;

  RmsSessionState copyWith({
    bool? isAuthenticated,
    bool? isSubmitting,
    RmsUserInfo? user,
    String? errorMessage,
  }) {
    return RmsSessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  static const initial = RmsSessionState(
    isAuthenticated: false,
    isSubmitting: false,
    user: null,
    errorMessage: null,
  );
}

class RmsSessionNotifier extends Notifier<RmsSessionState> {
  @override
  RmsSessionState build() {
    return RmsSessionState.initial;
  }

  Future<void> login({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = ref.read(rmsAuthRepositoryProvider);
      final user = await repo.login(
        usernameOrEmailAddress: usernameOrEmailAddress,
        password: password,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        isSubmitting: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isAuthenticated: false,
        user: null,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    final repo = ref.read(rmsAuthRepositoryProvider);
    await repo.logout();
    state = RmsSessionState.initial;
  }
}
