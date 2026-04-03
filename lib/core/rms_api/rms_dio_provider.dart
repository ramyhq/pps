import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rms_api_config.dart';
import 'rms_cookie_utils.dart';
import 'rms_http_client_adapter.dart';
import 'rms_local_storage.dart';
import 'rms_runtime_state_providers.dart';

final rmsDioProvider = Provider<Dio>((ref) {
  final runtimeState = ref.watch(rmsRuntimeStateProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: rmsBaseUrl,
      headers: <String, Object?>{
        'accept': 'application/json, text/javascript, */*; q=0.01',
        'x-requested-with': 'XMLHttpRequest',
      },
      followRedirects: false,
      validateStatus: (status) => status != null && status >= 200 && status < 400,
    ),
  );

  dio.httpClientAdapter = createRmsHttpClientAdapter();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final xsrfToken = runtimeState.xsrfToken;
        if (xsrfToken != null && xsrfToken.isNotEmpty) {
          options.headers['x-xsrf-token'] = xsrfToken;
        }

        final cookieHeader = runtimeState.cookieHeader;
        if (!kIsWeb && cookieHeader != null && cookieHeader.isNotEmpty) {
          options.headers['cookie'] = cookieHeader;
        }

        handler.next(options);
      },
      onResponse: (response, handler) async {
        if (!kIsWeb) {
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
        handler.next(err);
      },
    ),
  );

  ref.listen(rmsRuntimeStateProvider, (_, next) async {
    await RmsLocalStorage.writeXsrfToken(next.xsrfToken);
  });

  ref.onDispose(dio.close);
  return dio;
});

final rmsRuntimeBootstrapProvider = FutureProvider<void>((ref) async {
  final cookieHeader = await RmsLocalStorage.readCookieHeader();
  final xsrfToken = await RmsLocalStorage.readXsrfToken();
  ref.read(rmsRuntimeStateProvider.notifier).setCookieHeader(cookieHeader);
  ref.read(rmsRuntimeStateProvider.notifier).setXsrfToken(xsrfToken);
});

