import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/rms_api/rms_dio_provider.dart';
import '../../../core/rms_api/rms_runtime_state_providers.dart';
import '../data/models/rms_user_info.dart';
import 'rms_auth_providers.dart';

final rmsSessionProvider =
    NotifierProvider<RmsSessionNotifier, RmsSessionState>(
      RmsSessionNotifier.new,
    );

class RmsSessionState {
  const RmsSessionState({
    required this.isChecking,
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.user,
    required this.errorMessage,
  });

  final bool isChecking;
  final bool isAuthenticated;
  final bool isSubmitting;
  final RmsUserInfo? user;
  final String? errorMessage;

  RmsSessionState copyWith({
    bool? isChecking,
    bool? isAuthenticated,
    bool? isSubmitting,
    RmsUserInfo? user,
    String? errorMessage,
  }) {
    return RmsSessionState(
      isChecking: isChecking ?? this.isChecking,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  static const initial = RmsSessionState(
    isChecking: true,
    isAuthenticated: false,
    isSubmitting: false,
    user: null,
    errorMessage: null,
  );
}

class RmsSessionNotifier extends Notifier<RmsSessionState> {
  bool _didRestoreFromStorage = false;

  String _mapAuthErrorToUserMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return AppStrings.loginInvalidCredentials;
      }
      final data = error.response?.data;
      if (data is Map<String, Object?>) {
        final serverError = data['error'];
        if (serverError is String &&
            serverError.toLowerCase().contains('login')) {
          return AppStrings.loginInvalidCredentials;
        }
      }
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('login succeeded but user info is not available')) {
      return AppStrings.loginInvalidCredentials;
    }
    if (raw.contains('proxy login failed')) {
      return AppStrings.loginInvalidCredentials;
    }

    return error.toString();
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
                errorMessage: null,
              );
              return;
            }
            state = state.copyWith(
              isChecking: false,
              isAuthenticated: true,
              isSubmitting: false,
              user: user,
              errorMessage: null,
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
              errorMessage: null,
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
          errorMessage: null,
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
      errorMessage: null,
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
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        isSubmitting: false,
        isAuthenticated: false,
        user: null,
        errorMessage: _mapAuthErrorToUserMessage(e),
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
      errorMessage: null,
    );
  }
}
