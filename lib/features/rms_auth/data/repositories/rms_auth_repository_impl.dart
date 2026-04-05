import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/rms_api/rms_local_storage.dart';
import '../../../../core/rms_api/rms_runtime_state_providers.dart';
import '../data_sources/rms_auth_remote_data_source.dart';
import '../models/rms_user_info.dart';
import 'rms_auth_repository.dart';

class RmsAuthRepositoryImpl implements RmsAuthRepository {
  const RmsAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.ref,
  });

  final RmsAuthRemoteDataSource remoteDataSource;
  final Ref ref;

  @override
  Future<RmsUserInfo> login({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
  }) async {
    if (kIsWeb) {
      final sessionId = await remoteDataSource.proxyLogin(
        usernameOrEmailAddress: usernameOrEmailAddress,
        password: password,
        rememberMe: rememberMe,
      );
      ref.read(rmsRuntimeStateProvider.notifier).setSessionId(sessionId);
      await RmsLocalStorage.writeSessionId(sessionId);

      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Login succeeded but user info is not available.');
      }
      return user;
    }

    final token = await remoteDataSource.fetchRequestVerificationToken();
    if (token == null || token.isEmpty) {
      throw Exception('Failed to fetch verification token.');
    }

    ref.read(rmsRuntimeStateProvider.notifier).setXsrfToken(token);
    await RmsLocalStorage.writeXsrfToken(token);

    await remoteDataSource.login(
      usernameOrEmailAddress: usernameOrEmailAddress,
      password: password,
      rememberMe: rememberMe,
      requestVerificationToken: token,
    );

    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Login succeeded but user info is not available.');
    }
    return user;
  }

  @override
  Future<RmsUserInfo?> getCurrentUser() async {
    final data = await remoteDataSource.getCurrentLoginInformations();
    if (data == null) {
      return null;
    }
    final result = data['result'];
    if (result is! Map<String, Object?>) {
      return null;
    }
    final user = result['user'];
    if (user is! Map<String, Object?>) {
      return null;
    }

    final userName = (user['userName'] as String?)?.trim();
    final name = (user['name'] as String?)?.trim();
    final surname = (user['surname'] as String?)?.trim();
    if (userName == null || userName.isEmpty) {
      return null;
    }
    final fullName = <String>[
      if (name != null && name.isNotEmpty) name,
      if (surname != null && surname.isNotEmpty) surname,
    ].join(' ');
    return RmsUserInfo(userName: userName, fullName: fullName);
  }

  @override
  Future<void> logout() async {
    if (kIsWeb) {
      final sessionId = ref.read(rmsRuntimeStateProvider).sessionId?.trim();
      if (sessionId != null && sessionId.isNotEmpty) {
        await remoteDataSource.proxyLogout(sessionId: sessionId);
      }
    } else {
      await remoteDataSource.logout();
    }
    ref.read(rmsRuntimeStateProvider.notifier).clear();
    await RmsLocalStorage.writeCookieHeader(null);
    await RmsLocalStorage.writeXsrfToken(null);
    await RmsLocalStorage.writeSessionId(null);
  }
}
