import '../models/rms_user_info.dart';

abstract class RmsAuthRepository {
  Future<RmsUserInfo> login({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
  });

  Future<RmsUserInfo?> getCurrentUser();

  Future<void> logout();
}
