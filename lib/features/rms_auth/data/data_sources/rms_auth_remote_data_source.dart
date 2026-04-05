import 'package:dio/dio.dart';

import '../../../../core/rms_api/rms_api_config.dart';

class RmsAuthRemoteDataSource {
  const RmsAuthRemoteDataSource({required this.dio});

  final Dio dio;

  Future<String> proxyLogin({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await dio.post<Map<String, Object?>>(
      RmsApiPaths.proxyLogin,
      data: <String, Object?>{
        'username': usernameOrEmailAddress,
        'password': password,
        'rememberMe': rememberMe,
      },
    );

    final data = response.data;
    final sessionId = data?['sessionId'];
    if (sessionId is! String || sessionId.trim().isEmpty) {
      throw Exception('Proxy login failed (missing sessionId).');
    }
    return sessionId.trim();
  }

  Future<void> proxyLogout({required String sessionId}) async {
    await dio.post<void>(
      RmsApiPaths.proxyLogout,
      options: Options(headers: <String, Object?>{'x-rms-session': sessionId}),
    );
  }

  Future<String?> fetchRequestVerificationToken() async {
    final response = await dio.get<String>(
      RmsApiPaths.loginPage,
      options: Options(responseType: ResponseType.plain),
    );
    final html = response.data;
    if (html == null || html.isEmpty) {
      return null;
    }
    final match = RegExp(
      r'name=\"__RequestVerificationToken\"[^>]*value=\"([^\"]+)\"',
    ).firstMatch(html);
    return match?.group(1);
  }

  Future<void> login({
    required String usernameOrEmailAddress,
    required String password,
    required bool rememberMe,
    required String requestVerificationToken,
  }) async {
    final form = <String, String>{
      'returnUrl': '/App',
      'returnUrlHash': '',
      'ss': '',
      'usernameOrEmailAddress': usernameOrEmailAddress,
      'password': password,
      '__RequestVerificationToken': requestVerificationToken,
    };
    if (rememberMe) {
      form['rememberMe'] = 'true';
    }

    await dio.post<void>(
      RmsApiPaths.loginPost,
      data: form,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  Future<Map<String, Object?>?> getCurrentLoginInformations() async {
    final response = await dio.get<Map<String, Object?>>(
      RmsApiPaths.getCurrentLoginInformations,
    );
    return response.data;
  }

  Future<void> logout() async {
    await dio.get<void>(RmsApiPaths.logout);
  }
}
