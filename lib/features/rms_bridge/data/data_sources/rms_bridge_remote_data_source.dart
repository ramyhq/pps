import 'package:dio/dio.dart';

import '../../../../core/rms_api/rms_api_config.dart';

class RmsBridgeRemoteDataSource {
  const RmsBridgeRemoteDataSource({required this.dio});

  final Dio dio;

  Future<Map<String, Object?>> extractReservationView({
    required String sessionId,
    required String reservationId,
  }) async {
    final response = await dio.post<Map<String, Object?>>(
      RmsApiPaths.proxy,
      data: <String, Object?>{
        'action': 'extractReservationView',
        'reservationId': reservationId,
      },
      options: Options(headers: <String, Object?>{'x-rms-session': sessionId}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('RMS Bridge: empty response.');
    }
    return data;
  }
}
