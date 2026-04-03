import 'package:dio/dio.dart';

import '../../../../core/rms_api/rms_api_config.dart';

class RmsAuthRemoteDataSource {
  const RmsAuthRemoteDataSource({
    required this.dio,
  });

  final Dio dio;

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
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
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
