import 'package:dio/dio.dart';

import '../../../../core/rms_api/rms_api_config.dart';

class RmsBridgeRemoteDataSource {
  const RmsBridgeRemoteDataSource({required this.dio});

  final Dio dio;

  Future<Map<String, Object?>> extractReservationView({
    required String sessionId,
    required String reservationId,
  }) async {
    try {
      final response = await dio.post<Map<String, Object?>>(
        RmsApiPaths.proxy,
        data: <String, Object?>{
          'action': 'extractReservationView',
          'reservationId': reservationId,
        },
        options: Options(
          headers: <String, Object?>{'x-rms-session': sessionId},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('RMS Bridge: empty response.');
      }
      return data;
    } on DioException catch (e) {
      throw Exception(_formatDioException(e));
    }
  }

  Future<Map<String, Object?>> extractCreateOrEditLookups({
    required String sessionId,
    required String rms,
  }) async {
    try {
      final response = await dio.post<Map<String, Object?>>(
        RmsApiPaths.proxy,
        data: <String, Object?>{
          'action': 'extractCreateOrEditLookups',
          'rms': rms,
        },
        options: Options(
          headers: <String, Object?>{'x-rms-session': sessionId},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('RMS Bridge: empty response.');
      }
      return data;
    } on DioException catch (e) {
      throw Exception(_formatDioException(e));
    }
  }

  Future<Map<String, Object?>> extractAdditionalLookups({
    required String sessionId,
  }) async {
    try {
      final response = await dio.post<Map<String, Object?>>(
        RmsApiPaths.proxy,
        data: <String, Object?>{'action': 'extractAdditionalLookups'},
        options: Options(
          headers: <String, Object?>{'x-rms-session': sessionId},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('RMS Bridge: empty response.');
      }
      return data;
    } on DioException catch (e) {
      throw Exception(_formatDioException(e));
    }
  }
}

String _formatDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;
  final data = exception.response?.data;

  String? serverError;
  String? serverHint;
  if (data is Map) {
    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) {
      serverError = error.trim();
    }
    final hint = data['hint'];
    if (hint is String && hint.trim().isNotEmpty) {
      serverHint = hint.trim();
    }
  } else if (data is String && data.trim().isNotEmpty) {
    serverError = data.trim();
  }

  final codeLabel = statusCode == null ? '' : ' ($statusCode)';
  if (serverError != null) {
    if (serverHint != null) {
      return 'RMS Proxy error$codeLabel: $serverError ($serverHint)';
    }
    return 'RMS Proxy error$codeLabel: $serverError';
  }
  return 'RMS Proxy request failed$codeLabel.';
}
