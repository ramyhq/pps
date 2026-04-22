import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rms_api/rms_dio_provider.dart';
import '../../../core/rms_api/rms_runtime_state_providers.dart';
import '../data/models/rms_user_info.dart';
import 'rms_auth_providers.dart';

final rmsSessionProvider =
    NotifierProvider<RmsSessionNotifier, RmsSessionState>(
      RmsSessionNotifier.new,
    );

class RmsSessionError {
  const RmsSessionError._(this.code, this.message);

  final String code;
  final String? message;

  static const invalidCredentials = RmsSessionError._(
    'invalidCredentials',
    null,
  );

  factory RmsSessionError.message(String message) =>
      RmsSessionError._('message', message);
}

class RmsSessionState {
  const RmsSessionState({
    required this.isChecking,
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.user,
    required this.error,
  });

  final bool isChecking;
  final bool isAuthenticated;
  final bool isSubmitting;
  final RmsUserInfo? user;
  final RmsSessionError? error;

  RmsSessionState copyWith({
    bool? isChecking,
    bool? isAuthenticated,
    bool? isSubmitting,
    RmsUserInfo? user,
    RmsSessionError? error,
  }) {
    return RmsSessionState(
      isChecking: isChecking ?? this.isChecking,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      user: user ?? this.user,
      error: error,
    );
  }

  static const initial = RmsSessionState(
    isChecking: true,
    isAuthenticated: false,
    isSubmitting: false,
    user: null,
    error: null,
  );
}

class RmsSessionNotifier extends Notifier<RmsSessionState> {
  bool _didRestoreFromStorage = false;

  RmsSessionError _mapAuthError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return RmsSessionError.invalidCredentials;
      }
      final data = error.response?.data;
      if (data is Map<String, Object?>) {
        final serverError = data['error'];
        if (serverError is String &&
            serverError.toLowerCase().contains('login')) {
          return RmsSessionError.invalidCredentials;
        }
      }
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('login succeeded but user info is not available')) {
      return RmsSessionError.invalidCredentials;
    }
    if (raw.contains('proxy login failed')) {
      return RmsSessionError.invalidCredentials;
    }

    return RmsSessionError.message(error.toString());
  }

  @override
  RmsSessionState build() {
    ref.read(rmsRuntimeBootstrapProvider);

    ref.listen(rmsRuntimeBootstrapProvider, (_, next) {
      next.whenData((_) {
        if (_didRestoreFromStorage) {
          return;
        }
        _didRestoreFromStorage = true;
        () async {
          if (state.isAuthenticated) {
            state = state.copyWith(isChecking: false);
            return;
          }
          final sessionId = ref.read(rmsRuntimeStateProvider).sessionId;
          if (sessionId == null || sessionId.trim().isEmpty) {
            state = state.copyWith(isChecking: false);
            return;
          }
          state = state.copyWith(isChecking: true);
          final repo = ref.read(rmsAuthRepositoryProvider);
          try {
            final user = await repo.getCurrentUser();
            if (user == null) {
              await repo.logout();
              state = const RmsSessionState(
                isChecking: false,
                isAuthenticated: false,
                isSubmitting: false,
                user: null,
                error: null,
              );
              return;
            }
            state = state.copyWith(
              isChecking: false,
              isAuthenticated: true,
              isSubmitting: false,
              user: user,
              error: null,
            );
          } catch (_) {
            try {
              await repo.logout();
            } catch (_) {}
            state = const RmsSessionState(
              isChecking: false,
              isAuthenticated: false,
              isSubmitting: false,
              user: null,
              error: null,
            );
          }
        }();
      });
    });

    ref.listen(rmsRuntimeStateProvider, (previous, next) {
      final prevSessionId = previous?.sessionId;
      final nextSessionId = next.sessionId;
      if (prevSessionId != null &&
          (nextSessionId == null || nextSessionId.isEmpty)) {
        state = const RmsSessionState(
          isChecking: false,
          isAuthenticated: false,
          isSubmitting: false,
          user: null,
          error: null,
        );
      }
    });

    return RmsSessionState.initial;
  }

  Future<void> login({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(
      isChecking: false,
      isSubmitting: true,
      error: null,
    );
    try {
      final repo = ref.read(rmsAuthRepositoryProvider);
      final user = await repo.login(
        usernameOrEmailAddress: usernameOrEmailAddress,
        password: password,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        isChecking: false,
        isSubmitting: false,
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        isSubmitting: false,
        isAuthenticated: false,
        user: null,
        error: _mapAuthError(e),
      );
    }
  }

  Future<void> logout() async {
    final repo = ref.read(rmsAuthRepositoryProvider);
    await repo.logout();
    state = const RmsSessionState(
      isChecking: false,
      isAuthenticated: false,
      isSubmitting: false,
      user: null,
      error: null,
    );
  }
}
