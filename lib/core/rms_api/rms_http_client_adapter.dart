import 'package:dio/dio.dart';

import 'rms_http_client_adapter_stub.dart'
    if (dart.library.html) 'rms_http_client_adapter_web.dart'
    if (dart.library.io) 'rms_http_client_adapter_io.dart'
    as adapter;

HttpClientAdapter createRmsHttpClientAdapter() {
  return adapter.createRmsHttpClientAdapter();
}
