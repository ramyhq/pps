import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rms_api_config.dart';
import 'rms_cookie_utils.dart';
import 'rms_http_client_adapter.dart';
import 'rms_local_storage.dart';
import 'rms_runtime_state_providers.dart';

final rmsDioProvider = Provider<Dio>((ref) {
  final baseUrl = kIsWeb
      ? (rmsProxyOrigin.isNotEmpty ? rmsProxyOrigin : Uri.base.origin)
      : rmsBaseUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: <String, Object?>{
        'accept': 'application/json, text/javascript, */*; q=0.01',
        'x-requested-with': 'XMLHttpRequest',
      },
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    ),
  );

  dio.httpClientAdapter = createRmsHttpClientAdapter();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final runtimeState = ref.read(rmsRuntimeStateProvider);
        if (!kIsWeb) {
          final xsrfToken = runtimeState.xsrfToken;
          if (xsrfToken != null && xsrfToken.isNotEmpty) {
            options.headers['x-xsrf-token'] = xsrfToken;
          }
        }

        final cookieHeader = runtimeState.cookieHeader;
        if (!kIsWeb && cookieHeader != null && cookieHeader.isNotEmpty) {
          options.headers['cookie'] = cookieHeader;
        }

        if (kIsWeb) {
          final path = options.path;
          if (!path.startsWith('/rms/')) {
            final isAllowedPath =
                path.startsWith('/api/') ||
                path.startsWith('/Account/') ||
                path.startsWith('/App/Reservations/');
            if (isAllowedPath) {
              final sessionId = runtimeState.sessionId;
              if (sessionId != null && sessionId.isNotEmpty) {
                options.headers['x-rms-session'] = sessionId;
              }

              final originalMethod = options.method;
              final originalPath = path;
              final originalQuery = options.queryParameters;
              final originalBody = options.data;

              options.method = 'POST';
              options.path = RmsApiPaths.proxy;
              options.queryParameters = <String, dynamic>{};
              options.headers[Headers.contentTypeHeader] =
                  Headers.jsonContentType;
              options.data = <String, Object?>{
                'path': originalPath,
                'method': originalMethod,
                'query': originalQuery,
                'body': originalBody,
              };
            }
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) async {
        if (!kIsWeb) {
          final runtimeState = ref.read(rmsRuntimeStateProvider);
          final setCookieValues = response.headers.map['set-cookie'];
          if (setCookieValues != null && setCookieValues.isNotEmpty) {
            final merged = mergeCookieHeader(
              currentCookieHeader: runtimeState.cookieHeader,
              setCookieHeaders: setCookieValues,
            );
            ref.read(rmsRuntimeStateProvider.notifier).setCookieHeader(merged);
            await RmsLocalStorage.writeCookieHeader(merged);
          }
        }
        handler.next(response);
      },
      onError: (err, handler) async {
        if (kIsWeb) {
          final statusCode = err.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            ref.read(rmsRuntimeStateProvider.notifier).clear();
          }
        }
        handler.next(err);
      },
    ),
  );

  ref.listen(rmsRuntimeStateProvider, (_, next) async {
    await RmsLocalStorage.writeXsrfToken(next.xsrfToken);
    await RmsLocalStorage.writeSessionId(next.sessionId);
  });

  return dio;
});

final rmsRuntimeBootstrapProvider = FutureProvider<void>((ref) async {
  final cookieHeader = await RmsLocalStorage.readCookieHeader();
  final xsrfToken = await RmsLocalStorage.readXsrfToken();
  final sessionId = await RmsLocalStorage.readSessionId();
  ref.read(rmsRuntimeStateProvider.notifier).setCookieHeader(cookieHeader);
  ref.read(rmsRuntimeStateProvider.notifier).setXsrfToken(xsrfToken);
  ref.read(rmsRuntimeStateProvider.notifier).setSessionId(sessionId);
});
